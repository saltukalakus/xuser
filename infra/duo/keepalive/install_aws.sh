#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

wget http://www.keepalived.org/software/keepalived-1.2.19.tar.gz
tar -zxvf keepalived-*
cd keepalived-*
./configure
make
make install

ln -s /usr/local/sbin/keepalived /usr/sbin/keepalived


# TODO: Make this an upstart script
cp -vf init.d.keepalived /etc/init.d/keepalived
chmod +x /etc/init.d/keepalived
update-rc.d keepalived defaults