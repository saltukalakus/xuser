#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# First time configuration script, this needs to be executed once.
su -u mongodb mongod -f ./primary.conf
su -u mongodb mongod -f ./secondary.conf
su -u mongodb mongod -f ./backup.conf
su -u mongodb mongo 127.0.0.1:27001/admin init.js