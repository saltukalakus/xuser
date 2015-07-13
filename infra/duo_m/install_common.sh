#!/bin/bash

# Introduce new repositories
apt-add-repository -y ppa:vbernat/haproxy-1.5
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
add-apt-repository -y ppa:rwky/redis
apt-get -y update

# Helpers
apt-get -y install python-pip
pip install docopt

# NodeJs
apt-get -y install nodejs
apt-get -y install npm
npm install gulp -g
mkdir -p /var/log/nodejs
ln -sfv /usr/bin/nodejs /usr/bin/node

# Install project npms
pushd .
cd ../..
npm install
gulp build
gulp product
popd

# Install keepalived
pushd .
cd ./keepalived
. install.sh
popd

# Nginx
apt-get -y install nginx
# Haproxy
apt-get -y --force-yes install haproxy
# Redis
apt-get -y install redis-server
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

# Copy config template to project root
cp -a ../config ../..
