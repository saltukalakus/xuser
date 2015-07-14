#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./install_monitor.sh MASTER_IP"
    exit 1
fi

# Installations
# ===============
MASTER_IP=$1

pushd .
cd ../..
PROJECT_PATH=$(pwd)
popd
echo "Project path:"
echo $PROJECT_PATH

# Add repositories for mongo and redis
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
add-apt-repository -y ppa:rwky/redis
apt-get -y update

# Install Redis
apt-get -y install redis-server

# Install MongoDB
# Fix Failed global initialization: BadValue Invalid or no user locale set.
# Please ensure LANG and/or LC_* environment variables are set correctly.
apt-get -y install language-pack-en
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales
# Remove the old mongo
apt-get -y remove mongodb* --purge
apt-get -y autoremove
# Install mongo
apt-get -y install mongodb-org
# Fix mongo version
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
# For mongodb user increase various limits
python ../helpers/conf_append.py --file=/etc/security/limits.conf --key="#Mongodb User Limits" \
--append=" \
mongodb soft fsize -1 \n \
mongodb hard fsize -1 \n \
mongodb soft cpu   -1 \n \
mongodb hard cpu   -1 \n \
mongodb soft as    -1 \n \
mongodb hard as    -1 \n \
mongodb soft nofile 64000 \n \
mongodb hard nofile 64000 \n \
mongodb soft nproc  64000 \n \
mongodb hard nproc  64000 \n"

# Copy upstart files
rm -Rf /etc/init/redis* \
       /etc/init/nodejs* \
       /etc/init/mongo* \
       /etc/init/sentinel* \
       /etc/init/haproxy* \
       /etc/init/nginx*
cp -fv ./upstart/mongod-* /etc/init
cp -fv ./upstart/mongod.conf /etc/init
cp -fv ./upstart/sentinel-* /etc/init
cp -fv ./upstart/sentinel.conf /etc/init

initctl reload-configuration

# Generate the initial mongo data set
pushd .
cd ./mongodb_monitor
. init.sh
popd

# Redis conf setup
mkdir -p /var/log/redis
cp -fv ./redis_monitor/*.conf /etc/redis
python ../helpers/auto_replace.py --file=/etc/redis/sentinel-26379.conf \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
chown redis:redis /etc/redis/*.conf

# Stop all if already working
stop mongod
stop sentinel
stop redis

echo "Installation completed. Need a reboot for changes to get activated."

