#!/bin/bash


# set the working directory to the location where the script is located
cd "$(dirname "$0")"

mkdir -p /home/ubuntu/.apps/nextcloud

lxc network create nextcloudBridge ipv4.nat=true 

#lxc profile create worker
lxc profile create nextcloud
cat ./nextcloud.yml | lxc profile edit nextcloud

lxc copy dockertemplate/dockerSnapshot nextcloud
lxc profile apply nextcloud dockerpriv,nextcloud
lxc config device add nextcloud dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/nextcloud

#sets docker daemon to use the managers for registry operations
lxc file push ./daemon.json nextcloud/etc/docker/daemon.json

# push the nextcloud repo
# PUSHING TO MANAGER NODE!!!!
lxc file push --recursive ~/git/keybase/nextcloud/* --create-dirs manager1/app/
lxc file push ./nextcloud-entrypoint.sh manager1/entrypoint.sh

lxc start nextcloud

sleep 15

WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

lxc exec nextcloud -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN

# sleep 5

#lxc exec manager1 -- docker node update --label-add host=nextcloud nextcloud

# # # fix permissions on the startup script and run it.

lxc exec manager1 -- chmod +x /entrypoint.sh
lxc exec manager1 -- bash -c /entrypoint.sh
