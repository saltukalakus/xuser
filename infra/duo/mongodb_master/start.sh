 #!/bin/bash

SERVER_USER=#AUTO_REPLACE_SERVER_2
SERVER_IP=#AUTO_REPLACE_SERVER_2_IP
SERVER_KEY=#AUTO_REPLACE_SERVER_KEY

# First time configuration script, this needs to be executed once.
LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-1.conf
ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP -i $SERVER_KEY "LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-2.conf"
LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-3.conf

echo "Fork completed. Please wait..."
sleep 10
echo "Now configure all mongos"
LC_ALL=en_US.UTF-8 mongo 127.0.0.1:27001/admin /data-mongodb/init.js
