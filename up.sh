#!/bin/bash

# if we're running in a VM, we assume ENV VARs come from /etc/environment
if [[ $BCM_ENVIRONMENT = 'vm' ]] 
then
  echo "Sourcing vm environment variables."
  source /etc/environment
fi


if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set. Please source a .env file."
  exit 1
fi

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

lxc config set core.proxy_http $BCM_HTTP_PROXY
lxc config set core.proxy_https $BCM_HTTPS_PROXY
lxc config set core.proxy_ignore_hosts image-server.local

echo "creating an LXD system container template for running docker applications."
./host_template/up.sh

echo "Deploying proxyhost"
./proxyhost/up.sh

echo "Creating swarm with 3 managers"
./managers/up.sh

echo "deploying an bitcoin infrastructure."
./bitcoin/up.sh

