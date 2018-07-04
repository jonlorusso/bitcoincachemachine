#!/bin/bash

# exit script if there's an error anywhere
set -e

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set. Please source a .env file."
  exit 1
fi

# set lxd to defaults
lxd init --auto

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

if [[ $BCM_CACHE_STACK = 'gw' ]]; then
  # set BCM_CACHE_STACK_IP to the gateway
  export BCM_CACHE_STACK_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
fi

# if BCM_CACHE_STACK has a value set, configure the rest of the env vars
if [[ ! -z $BCM_CACHE_STACK_IP ]]; then
  export BCM_LXD_IMAGE_CACHE=${BCM_CACHE_STACK_IP}
  export BCM_LXD_HTTP_PROXY=http://${BCM_CACHE_STACK_IP}:3128
  export BCM_LXD_HTTPS_PROXY=http://${BCM_CACHE_STACK_IP}:3128
  export BCM_REGISTRY_PROXY_REMOTEURL=http://${BCM_CACHE_STACK_IP}:5000
  export BCM_ELASTIC_REGISTRY_PROXY_REMOTEURL=http://${BCM_CACHE_STACK_IP}:5001

  # set HTTP and HTTPS proxy environment variables
  export HTTP_PROXY=${BCM_LXD_HTTP_PROXY}
  export HTTPS_PROXY=${BCM_LXD_HTTPS_PROXY}
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
    lxc remote add lxdcache $BCM_LXD_IMAGE_CACHE --public --accept-certificate
    lxc image copy lxdcache:bcm-bionic local: --alias bcm-bionic
  fi
fi

echo "creating a LXD system container template."
./host_template/up.sh

echo "Deploying proxyhost."
./proxyhost/up.sh

sleep 90

echo "Creating managers and docker swarm."
./managers/up.sh

echo "Deploying bitcoin infrastructure."
./bitcoin/up.sh

# # echo "deploying an elastic infrastructure."
# ./elastic/up.sh
