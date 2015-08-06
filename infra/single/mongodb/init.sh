#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# remove password for mongodb user
passwd mongodb -d

# Kill all running mongod processes
pkill -9 mongod

rm -Rf /data-mongodb
mkdir -p /data-mongodb/
cp -v start.sh stop.sh configure.sh init.js /data-mongodb
cp -v *.conf /data-mongodb
chmod 755 /data-mongodb/start.sh
chmod 755 /data-mongodb/stop.sh
chmod 755 /data-mongodb/configure.sh

mkdir -p /data-mongodb/rs0-1
mkdir -p /data-mongodb/rs0-2
mkdir -p /data-mongodb/rs0-3
mkdir -p /var/log/mongodb

ln -svf /data-mongodb/start.sh /usr/local/bin/mongodb-start.sh
ln -svf /data-mongodb/stop.sh /usr/local/bin/mongodb-stop.sh
ln -svf /data-mongodb/configure.sh /usr/local/bin/mongodb-configure.sh

mongodb-start.sh
mongodb-stop.sh

chown mongodb:mongodb -Rf /data-mongodb

# Remove the socket temporary files
rm -Rf /tmp/mongodb*
