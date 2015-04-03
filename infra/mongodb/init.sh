#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"  # Modified as suggested below.
        exit $?
fi

# First time configuration script, this needs to be executed once.
mongod -f ./primary.conf
mongod -f ./secondary.conf
mongod -f ./backup.conf
mongo 127.0.0.1:27001/admin init.js