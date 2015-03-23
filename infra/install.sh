#!/bin/bash
# TODO: force run as root
apt-get install nginx
apt-add-repository ppa:vbernat/haproxy-1.5
apt-get update
apt-get install haproxy
mv /etc/init.d/haproxy ~ #  Haproxy is controlled by upstart