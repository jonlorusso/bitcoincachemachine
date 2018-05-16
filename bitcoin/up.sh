#!/bin/bash

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

mkdir -p /home/ubuntu/.apps/bitcoin

lxc profile create bitcoinprofile
cat ./bitcoin_lxd_profile.yml | lxc profile edit bitcoinprofile


## start the managers
lxc copy dockertemplate/dockerSnapshot bitcoin
lxc profile apply bitcoin dockerpriv,bitcoinprofile

# bind mount
lxc config device add bitcoin dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/bitcoin

# push docker.json for registry mirror settings
#lxc file push ./proxyhostfiles/daemon.json proxyhost/etc/docker/daemon.json


lxc start bitcoin

sleep 15


WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

lxc exec bitcoin -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN
lxc exec manager1 -- docker stack deploy -c /app/bitcoin.yml

