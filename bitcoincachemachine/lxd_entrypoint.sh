#!/bin/bash

## provisioning script for proxyhost -- lxc pushes this directory to proxyhost then executes this script.
docker pull minimum2scp/squid:latest
docker run -d -p 3128:3128 minimum2scp/squid:latest

docker pull registry:2.6.2
docker stack deploy -c /app/registry/mirror.yml mirror

