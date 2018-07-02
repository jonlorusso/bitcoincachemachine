#!/bin/bash

# exit script if there's an error anywhere
set -e

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set. Please source a .env file."
  exit 1
fi

# get lxd in auto config state
lxd init --auto

# get the default gateway, set all proxies to DG
CACHE_STACK_IP=""
if [[ $BCM_ENVIRONMENT = 'vm' ]]; then
  CACHE_STACK_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
fi

#configure LXD daemon
if [[ ! -z $BCM_LXD_HTTP_PROXY ]]; then
  echo "Setting HTTP proxy settings in lxc to $BCM_LXD_HTTP_PROXY"
  lxc config set core.proxy_http $BCM_LXD_HTTP_PROXY
  lxc config set core.proxy_ignore_hosts image-server.local
else
  echo "Clearing lxd proxy_http."
  lxc config set core.proxy_http ""
fi

if [[ ! -z $BCM_LXD_HTTPS_PROXY ]]; then
  echo "Setting HTTPS proxy settings on lxc to $BCM_LXD_HTTPS_PROXY"
  lxc config set core.proxy_https $BCM_LXD_HTTPS_PROXY
  lxc config set core.proxy_ignore_hosts image-server.local
else
  echo "Clearing lxd proxy_https."
  lxc config set core.proxy_https ""
fi

if [[ ! -z $BCM_LXD_IMAGE_CACHE ]]; then
  if [[ -z $(lxc remote list | grep lxdcache) ]]; then
    echo "Adding lxd image server $BCM_LXD_IMAGE_CACHE"
    lxc remote add lxdcache $BCM_LXD_IMAGE_CACHE --public
    lxc image copy lxdcache:bcm-bionic local: --alias bcm-bionic
  fi
fi



echo "creating an LXD system container template for running docker applications."
./host_template/up.sh

echo "Deploying proxyhost"
./proxyhost/up.sh

echo "Creating swarm with 3 managers"
./managers/up.sh

# echo "deploying an bitcoin infrastructure."
./bitcoin/up.sh

# # echo "deploying an elastic infrastructure."
# ./elastic/up.sh
