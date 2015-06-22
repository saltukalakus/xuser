#!/bin/bash
# Stop running mongod processes
LC_ALL=en_US.UTF-8 /usr/bin/mongod --dbpath /data-mongodb/rs0-1 --shutdown

