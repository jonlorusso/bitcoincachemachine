#!/bin/bash

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"


if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set. Please source a .env file."
  exit 1
fi


lxc config set core.proxy_http $HTTP_PROXY
lxc config set core.proxy_https $HTTPS_PROXY
lxc config set core.proxy_ignore_hosts image-server.local
 

echo "creating an LXD system container template for running docker applications."
./host_template/up.sh

echo "Deploying proxyhost"
./proxyhost/up.sh

echo "Creating swarm with 3 managers"
./managers/up.sh

sleep 60

echo "deploying an bitcoin infrastructure."
./bitcoin/up.sh

# echo "deploying an elastic infrastructure."
# ./elastic/up.sh
