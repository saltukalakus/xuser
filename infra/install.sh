#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"  # Modified as suggested below.
        exit $?
fi

# Installations
# TODO: Add mongodb
apt-get install nodejs
apt-get install npm
apt-get install nginx
apt-add-repository ppa:vbernat/haproxy-1.5
apt-get update
apt-get install haproxy

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

