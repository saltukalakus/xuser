Infrastructure for single VM installation
==============

* Haproxy is configured as proxy and load balancer in front of Node and Nginx servers. Running on port 80 and 443
* SSL is terminated in Haproxy. 
* All http is redirected to https by Haproxy.
* Nginx is used as static file server. Nginx sample conf file is nginx-conf. Nginx runs on localhost:809x
* Node app runs on localhost:808x 
* Redis is configured for session management for Node instances.
* Sentinel is used for Redis HA.
* MongoDB with replica set is used for application database.
* Upstart starts the whole stack

Architecture
===================

![ScreenShot](https://github.com/BATYD-Turksat/xuser/blob/master/infra/single/doc/SingleServerHA.jpeg)
