#!/bin/bash

cd /app

## provisioning script for proxyhost -- lxc pushes this directory to proxyhost then executes this script.
docker pull minimum2scp/squid:latest
docker run -d -p 3128:3128 minimum2scp/squid:latest

docker stack deploy -c /app/mirror.yml mirror

