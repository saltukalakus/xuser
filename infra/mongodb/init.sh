#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# Kill all running mongod processes
pkill -9 mongod

rm -Rf /data-mongodb
mkdir -p /data-mongodb/

mkdir -p /data-mongodb/xuser-1
cp -v primary.conf /data-mongodb/xuser-1

mkdir -p /data-mongodb/xuser-2
cp -v secondary.conf /data-mongodb/xuser-2

mkdir -p /data-mongodb/backup
cp -v backup.conf /data-mongodb/backup

# First time configuration script, this needs to be executed once.
mongod -f ./primary.conf
mongod -f ./secondary.conf
mongod -f ./backup.conf
mongo 127.0.0.1:27001/admin init.js

# Kill all running mongod processes
pkill -9 mongod

chown mongodb:mongodb -Rf /data-mongodb
