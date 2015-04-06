#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# Installations
# ===============

# NodeJs
apt-get install nodejs
apt-get install npm
# Nginx
apt-get install nginx
# Haproxy
apt-add-repository ppa:vbernat/haproxy-1.5
apt-get update
apt-get install haproxy
# MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get install -y mongodb-org
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
mkdir -p /data-mongodb
mkdir -p /data-mongodb/xuser-1
mkdir -p /data-mongodb/xuser-2
mkdir -p /data-mongodb/backup
chown mongodb:mongodb -R /data-mongodb

# Haproxy conf setup
mv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart
cp ./haproxy/haproxy.cfg /etc/haproxy

# Nginx conf setup
cp -v ./nginx/* /etc/nginx/sites-available
ln -s /etc/nginx/sites-enabled/nginx-conf /etc/nginx/sites-available/nginx-conf
ln -s /etc/nginx/sites-enabled/nginx-conf2 /etc/nginx/sites-available/nginx-conf2
mv /etc/init.d/nginx ~ #  Nginx is controlled by upstart

# Copy upstart files
cp -v ./upstart/* /etc/init

# SSL keys
pushd .
cd ./ssl/
./ssl-key-gen.sh
popd

# Restart all
stop xuser
stop nginx
stop haproxy
start xuser
start nginx
start haproxy

