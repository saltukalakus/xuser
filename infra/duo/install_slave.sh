#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

if [ "$#" -ne 3 ]; then
    echo "USAGE: ./install_slave.sh MASTER_IP SLAVE_IP"
    exit 1
fi

# Installations
# ===============
MASTER_IP=$1
SLAVE_IP=$2
if [ $(MASTER_IP) == ""
pushd .
cd ../..
PROJECT_PATH=$(pwd)
popd
echo "Project path:"
echo $PROJECT_PATH

# Install common files.
. install_common.sh

# Generate the initial mongo data set
pushd .
cd ./mongodb_slave
. init.sh
popd

exit 1

# Haproxy conf setup
/etc/init.d/haproxy stop
mv -fv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart
cp -fv ./haproxy/haproxy.cfg /etc/haproxy

# Nginx conf setup
/etc/init.d/nginx stop
cp -fv ./nginx/nginx-* /etc/nginx/sites-available
cp -fv ./nginx/nginx.conf /etc/nginx
rm -Rfv /etc/nginx/sites-enabled/*
ln -sfv /etc/nginx/sites-available/nginx-node1 /etc/nginx/sites-enabled/nginx-node1
ln -sfv /etc/nginx/sites-available/nginx-node2 /etc/nginx/sites-enabled/nginx-node2
python ../helpers/auto_replace.py --file=/etc/nginx/sites-available/nginx-node1 \
                                  --search="#AUTO_REPLACE_PR_PATH" \
                                  --replace=$PROJECT_PATH
python ../helpers/auto_replace.py --file=/etc/nginx/sites-available/nginx-node2 \
                                  --search="#AUTO_REPLACE_PR_PATH" \
                                  --replace=$PROJECT_PATH

mv -fv /etc/init.d/nginx ~ #  Nginx is controlled by upstart

# Redis conf setup
mkdir -p /var/log/redis
cp -fv ./redis/*.conf /etc/redis
chown redis:redis /etc/redis/*.conf

# Copy upstart files
cp -fv ./upstart/* /etc/init
python ../helpers/auto_replace.py --file=/etc/init/nodejs-instance.conf \
                                  --search="#AUTO_REPLACE_COOKIE_SECRET" \
                                  --replace="42rerwejfkj9434cds5ewejd"
python ../helpers/auto_replace.py --file=/etc/init/nodejs-instance.conf \
                                  --search="#AUTO_REPLACE_PR_PATH" \
                                  --replace=$PROJECT_PATH

initctl reload-configuration

# Stop all if already working
stop nodejs
stop mongod
stop sentinel
stop redis
stop nginx
stop haproxy

start haproxy
start nginx
start redis
start sentinel
start mongod
start nodejs

echo "Hey! Don't forget to install SSL keys!"
read -p "Now I need to reboot. Ok for you? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot -h now
fi
