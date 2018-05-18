#!/bin/bash

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set.  Please source a .env file."
  exit 1
fi


# set the working directory to the location where the script is located
cd "$(dirname "$0")"



lxc profile create bitcoinprofile
cat ./bitcoin_lxd_profile.yml | lxc profile edit bitcoinprofile
## start the managers
lxc copy dockertemplate/dockerSnapshot bitcoin
lxc profile apply bitcoin default,bitcoinprofile

# bind mount
mkdir -p /home/ubuntu/.apps/bitcoin
lxc config device add bitcoin dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/bitcoin

# push docker.json for registry mirror settings
lxc file push ./bitcoinhostfiles/daemon.json bitcoin/etc/docker/daemon.json


lxc start bitcoin

sleep 15


WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

lxc exec bitcoin -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN

lxc exec manager1 -- mkdir -p /app/bitcoin
lxc file push ./bitcoinhostfiles/* --recursive --create-dirs manager1/app/bitcoin/

# change permissions and execute /entrypoint.sh
lxc exec manager1 -- chmod +x /app/bitcoin/up.sh
lxc exec manager1 -- bash -c /app/bitcoin/up.sh