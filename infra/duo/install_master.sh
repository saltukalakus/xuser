#!/bin/bash

# Force run as root
if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@"
        exit $?
fi

if [ "$#" -ne 4 ]; then
    echo "USAGE: ./install_master.sh SECRET AWS_ID_OF_MASTER MASTER_IP SLAVE_IP"
    exit 1
fi

# Installations
# ===============
SECRET=$1
AWS_ID=$2
MASTER_IP=$3
SLAVE_IP=$4

pushd .
cd ../..
PROJECT_PATH=$(pwd)
popd
echo "Project path:"
echo $PROJECT_PATH

# Install common files.
. install_common.sh

# Copy upstart files
rm -Rf /etc/init/redis* \
       /etc/init/nodejs* \
       /etc/init/mongo* \
       /etc/init/sentinel* \
       /etc/init/haproxy* \
       /etc/init/nginx*
cp -fv ./upstart/* /etc/init
cp -fv ./upstart/master/* /etc/init
python ../helpers/auto_replace.py --file=/etc/init/nodejs-instance.conf \
                                  --search="#AUTO_REPLACE_PR_PATH" \
                                  --replace=$PROJECT_PATH

initctl reload-configuration

# Keepalived conf scripts
if [ $AWS_ID != "0" ]; then
    echo "Keepalived AWS mode enabled"
    pushd .
    cd ./keepalived
    . install_aws.sh
    popd
    ELASTIC_IP='52.28.178.87'
    mkdir -p /etc/keepalived
    cp -vf ./keepalived/keepalived_master_aws.conf /etc/keepalived/keepalived.conf
    cp -vf ./keepalived/master_aws.sh /etc/keepalived
    chmod 755 /etc/keepalived/master_aws.sh
    python ../helpers/auto_replace.py --file=/etc/keepalived/keepalived.conf \
                                      --search="#AUTO_REPLACE_SERVER_1" \
                                      --replace=$MASTER_IP
    python ../helpers/auto_replace.py --file=/etc/keepalived/keepalived.conf \
                                      --search="#AUTO_REPLACE_SERVER_2" \
                                      --replace=$SLAVE_IP
    python ../helpers/auto_replace.py --file=/etc/keepalived/master_aws.sh \
                                      --search="#AUTO_REPLACE_EIP" \
                                      --replace=$ELASTIC_IP
    python ../helpers/auto_replace.py --file=/etc/keepalived/master_aws.sh \
                                      --search="#AUTO_REPLACE_INSTANCE_ID" \
                                     --replace=$AWS_ID
else
    echo "Keepalived virtual IP cluster mode enabled"
    mkdir -p /etc/keepalived
    cp -vf ./keepalived/keepalived_master.conf /etc/keepalived/keepalived.conf
fi

# Generate the initial mongodb data set
pushd .
cd ./mongodb_master
. init.sh $MASTER_IP $SLAVE_IP
popd

# Update the application config settings
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/database.js \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/database.js \
                                  --search="#AUTO_REPLACE_SERVER_2" \
                                  --replace=$SLAVE_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/database.js \
                                  --search="#AUTO_REPLACE_PORT_1" \
                                  --replace="27001"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/database.js \
                                  --search="#AUTO_REPLACE_PORT_2" \
                                  --replace="27001"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/inet.js \
                                  --search="#AUTO_REPLACE_SERVER_IP" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_HOST1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_HOST2" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_HOST3" \
                                  --replace=$SLAVE_IP
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_PORT1" \
                                  --replace="26379"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_PORT2" \
                                  --replace="26380"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_PORT3" \
                                  --replace="26379"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_CLUSTER_NAME" \
                                  --replace="mymaster"
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/session.js \
                                  --search="#AUTO_REPLACE_SESSION_SECRET" \
                                  --replace=$SECRET
python ../helpers/auto_replace.py --file=$PROJECT_PATH/config/token.js \
                                  --search="#AUTO_REPLACE_TOKEN_SECRET" \
                                  --replace=$SECRET

# Haproxy conf setup
/etc/init.d/haproxy stop
mv -fv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart
cp -fv ./haproxy/haproxy.cfg /etc/haproxy
python ../helpers/auto_replace.py --file=/etc/haproxy/haproxy.cfg \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=/etc/haproxy/haproxy.cfg \
                                  --search="#AUTO_REPLACE_SERVER_2" \
                                  --replace=$SLAVE_IP

# Nginx conf setup
/etc/init.d/nginx stop
cp -fv ./nginx/nginx-* /etc/nginx/sites-available
cp -fv ./nginx/nginx.conf /etc/nginx
rm -Rfv /etc/nginx/sites-enabled/*
ln -sfv /etc/nginx/sites-available/nginx-node1 /etc/nginx/sites-enabled/nginx-node1
python ../helpers/auto_replace.py --file=/etc/nginx/sites-available/nginx-node1 \
                                  --search="#AUTO_REPLACE_PR_PATH" \
                                  --replace=$PROJECT_PATH

mv -fv /etc/init.d/nginx ~ #  Nginx is controlled by upstart

# Redis conf setup
mkdir -p /var/log/redis
cp -fv ./redis_master/*.conf /etc/redis
python ../helpers/auto_replace.py --file=/etc/redis/redis-6379.conf \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=/etc/redis/redis-6380.conf \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=/etc/redis/sentinel-26379.conf \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
python ../helpers/auto_replace.py --file=/etc/redis/sentinel-26380.conf \
                                  --search="#AUTO_REPLACE_SERVER_1" \
                                  --replace=$MASTER_IP
chown redis:redis /etc/redis/*.conf


# Stop all if already working
stop nodejs
stop mongod
stop sentinel
stop redis
stop nginx
stop haproxy

echo "Installation completed. Need a reboot for changes to get activated."
echo "Also don't forget to install SSL keys!"
