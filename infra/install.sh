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
apt-get -y install nodejs
apt-get -y install npm
# Nginx
apt-get -y install nginx
# Haproxy
apt-add-repository ppa:vbernat/haproxy-1.5
apt-get update
apt-get -y install haproxy
# MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get -y install mongodb-org
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
# Generate the initial data set
pushd .
cd ./mongodb
./init.sh
popd

# Haproxy conf setup
mv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart
cp ./haproxy/haproxy.cfg /etc/haproxy

# Nginx conf setup
cp -v ./nginx/nginx-* /etc/nginx/sites-available
cp -v ./nginx/nginx.conf /etc/nginx
ln -s /etc/nginx/sites-enabled/nginx-node1 /etc/nginx/sites-available/nginx-node1
ln -s /etc/nginx/sites-enabled/nginx-node2 /etc/nginx/sites-available/nginx-node2
mv /etc/init.d/nginx ~ #  Nginx is controlled by upstart

# Copy upstart files
cp -v ./upstart/* /etc/init
initctl reload-configuration

# SSL keys
pushd .
cd ./ssl/
./ssl-key-gen.sh
popd

# Restart all
stop xuser
stop mongodb
stop nginx
stop haproxy

start haproxy
start nginx
start mongodb
start xuser
