#!/bin/bash

mongod -f ./primary.conf
mongod -f ./secondary.conf
mongod -f ./backup.conf
mongo 127.0.0.1:27001/admin init.js