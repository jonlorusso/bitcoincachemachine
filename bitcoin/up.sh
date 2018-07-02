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

# push docker.json for registry mirror settings
lxc file push ./daemon.json bitcoin/etc/docker/daemon.json

lxc start bitcoin


sleep 15

WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

lxc exec bitcoin -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN

lxc exec manager1 -- mkdir -p /app/bitcoinstack
lxc file push ./bitcoinstack/* --recursive --create-dirs manager1/app/bitcoinstack/

# # change permissions and execute /entrypoint.sh
lxc exec manager1 -- chmod +x /app/bitcoinstack/up.sh
lxc exec manager1 -- bash -c /app/bitcoinstack/up.sh