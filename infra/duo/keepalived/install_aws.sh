#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

# Install AWS client
pip install awscli

# Download and build keepalived
wget http://www.keepalived.org/software/keepalived-1.2.19.tar.gz
tar -zxvf keepalived-*
cd keepalived-*
./configure
make
make install
cd ..
rm -Rf keepalived-*

ln -sf /usr/local/sbin/keepalived /usr/sbin/keepalived

# TODO: Make this an upstart script
cp -vf init.d.keepalived /etc/init.d
chmod +x /etc/init.d/keepalived
update-rc.d keepalived defaults

echo "$(tput setaf 1)WARNING...$(tput sgr0)"
echo "$(tput setaf 1)Don't forget to configure keys with \"sudo aws configure\"$(tput sgr0)"
