#!/bin/bash

cd /app

## provisioning script for proxyhost -- lxc pushes this directory to proxyhost then executes this script.
docker pull minimum2scp/squid:latest
docker run -d -p 3128:3128 minimum2scp/squid:latest

source /app/env

# make it so all shell sessions share the proxy config
sudo cat /app/env >> /root/.bashrc

docker stack deploy -c /app/mirror.yml mirror
