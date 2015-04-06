#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# Kill all running mongod processes
pkill -9 mongod

rm -Rf /data-mongodb/xuser-1
rm -Rf /data-mongodb/xuser-2
rm -Rf /data-mongodb/backup

mkdir -p /data-mongodb/xuser-1
mkdir -p /data-mongodb/xuser-2
mkdir -p /data-mongodb/backup
