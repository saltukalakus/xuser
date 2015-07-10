#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

apt-get install tcpdump
tcpdump -i eth1 "ip proto 112"
