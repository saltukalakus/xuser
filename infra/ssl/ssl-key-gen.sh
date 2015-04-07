#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

openssl req -x509 -nodes -newkey rsa:2048 -keyout site.key -out site.crt -days 10000
cat site.crt site.key > site.pem
cp -v site.pem /etc/ssl/private/