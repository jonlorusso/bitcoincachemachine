#!/bin/bash


# set the working directory to the location where the script is located
cd "$(dirname "$0")"

# a network shared by./dep hosts needing outbound http proxy access (e.g., managers)
lxc network create lxdbrBitcoin ipv4.nat=true

lxc profile create bitcoinprofile
cat ./bitcoin_lxd_profile.yml | lxc profile edit bitcoinprofile

lxc copy dockertemplate/dockerSnapshot bitcoin
lxc profile apply bitcoin docker,bitcoinprofile

# bind mount
mkdir -p /home/multipass/.apps/bitcoin
lxc config device add bitcoin dockerdisk disk path=/var/lib/docker source=/home/multipass/.apps/bitcoin

# create a directory for bitcoin bulk data and bind mount into bitcoin LXC container.
mkdir -p /home/multipass/bitcoin

# push docker.json for registry mirror settings
lxc file push ./daemon.json bitcoin/etc/docker/daemon.json

lxc start bitcoin


sleep 15

WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

lxc exec bitcoin -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN

# bind mount the appropriate code directory into the manager lxc container
lxc exec manager1 -- mkdir -p /apps/bitcoin
lxc config device add manager1 code_bitcoin disk path=/apps/bitcoin source=${BCM_CODE_DIRECTORY}/bitcoin/bitcoinstack

# bind mount bitcoin bulk data directory.
lxc exec bitcoin -- mkdir -p /bitcoin
lxc config device add bitcoin bitcoin_bulk_data disk path=/bitcoin source=${BCM_BITCOIN_BULK_DATA_DIRECTORY}


# Execute the up.sh script to bring up bitcoin docker stack.
lxc exec manager1 -- bash -c /apps/bitcoin/up.sh