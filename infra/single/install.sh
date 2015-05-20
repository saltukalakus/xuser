#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# Installations
# ===============

# Helpers
apt-get -y install python-pip
pip install docopt

# NodeJs
apt-get update
apt-get -y install nodejs
apt-get -y install npm
npm install gulp -g
mkdir -p /var/log/nodejs
ln -s /usr/bin/nodejs /usr/bin/node

# Install project npms
pushd .
cd ../..
npm install
gulp build
gulp product
popd

# Nginx
apt-get -y install nginx
# Haproxy
apt-add-repository -y ppa:vbernat/haproxy-1.5
apt-get update
apt-get -y --force-yes install haproxy
# MongoDB
# Fix Failed global initialization: BadValue Invalid or no user locale set.
# Please ensure LANG and/or LC_* environment variables are set correctly.
apt-get -y install language-pack-en
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales
# Remove the old mongo
apt-get remove mongodb* --purge
apt-get autoremove
# Install mongo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
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

# Generate the initial mongo data set
pushd .
cd ./mongodb
. init.sh
popd
# Redis
add-apt-repository -y ppa:rwky/redis
apt-get update
apt-get install -y redis-server

# Haproxy conf setup
/etc/init.d/haproxy stop
mv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart
cp -fv ./haproxy/haproxy.cfg /etc/haproxy

# Nginx conf setup
/etc/init.d/nginx stop
cp -fv ./nginx/nginx-* /etc/nginx/sites-available
cp -fv ./nginx/nginx.conf /etc/nginx
rm -Rfv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/nginx-node1 /etc/nginx/sites-enabled/nginx-node1
ln -s /etc/nginx/sites-available/nginx-node2 /etc/nginx/sites-enabled/nginx-node2
mv /etc/init.d/nginx ~ #  Nginx is controlled by upstart

# Redis conf setup
mkdir -p /var/log/redis
cp -fv ./redis/*.conf /etc/redis
chown redis:redis /etc/redis/*.conf

# Copy upstart files
cp -v ./upstart/* /etc/init
initctl reload-configuration

# Stop all if already working
stop nodejs
stop mongod
stop sentinel
stop redis
stop nginx
stop haproxy

#start haproxy
#start nginx
#start redis
#start sentinel
#start mongod
#start nodejs

echo "Hey! Don't forget to install SSL keys!"
read -p "Now I need to reboot. Ok for you? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot -h now
fi