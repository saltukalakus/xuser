#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

MASTER_IP=$1
SLAVE_IP=$2

# remove password for mongodb user
passwd mongodb -d

# Kill all running mongod processes
pkill -9 mongod

rm -Rf /data-mongodb
mkdir -p /data-mongodb/
cp -v start.sh stop.sh init.js /data-mongodb
cp -v *.conf /data-mongodb
chmod 755 /data-mongodb/start.sh
chmod 755 /data-mongodb/stop.sh

python ../../helpers/auto_replace.py --file=/data-mongodb/init.js \
                                     --search="#AUTO_REPLACE_SERVER_1" \
                                     --replace=$MASTER_IP

python ../../helpers/auto_replace.py --file=/data-mongodb/init.js \
                                     --search="#AUTO_REPLACE_SERVER_2" \
                                     --replace=$SLAVE_IP

mkdir -p /data-mongodb/rs0-1
mkdir -p /data-mongodb/rs0-2
mkdir -p /var/log/mongodb

ln -svf /data-mongodb/start.sh /usr/local/bin/mongodb-start.sh
ln -svf /data-mongodb/stop.sh /usr/local/bin/mongodb-stop.sh

mongodb-start.sh
mongodb-stop.sh

chown mongodb:mongodb -Rf /data-mongodb

# Remove the socket temporary files
rm -Rf /tmp/mongodb*
