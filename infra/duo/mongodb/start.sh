 #!/bin/bash

 # First time configuration script, this needs to be executed once.
LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-1.conf
LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-2.conf
LC_ALL=en_US.UTF-8 /usr/bin/mongod --config /data-mongodb/rs0-3.conf

echo "Fork completed. Please wait..."
sleep 5
echo "Now configure all mongos"
LC_ALL=en_US.UTF-8 mongo 127.0.0.1:27001/admin /data-mongodb/init.js
