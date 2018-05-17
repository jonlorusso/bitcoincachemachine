#!/bin/bash

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

mkdir -p /home/ubuntu/.apps/proxyhost



touch ./proxyhostfiles/envtemp
echo "" > ./proxyhostfiles/envtemp
echo "export HTTP_PROXY="$HTTP_PROXY"" >> ./proxyhostfiles/envtemp
echo "export HTTPS_PROXY="$HTTPS_PROXY"" >> ./proxyhostfiles/envtemp
echo "export REGISTRY_PROXY_REMOTEURL="$REGISTRY_PROXY_REMOTEURL"" >> ./proxyhostfiles/envtemp

touch ./proxyhostfiles/daemon.json
echo "" > ./proxyhostfiles/daemon.json
echo "{\"registry-mirrors\": [\"$REGISTRY_PROXY_REMOTEURL\"]}" >> ./proxyhostfiles/daemon.json


# a network shared by./dep hosts needing outbound http proxy access (e.g., managers)
lxc network create proxyhostnet ipv4.address=10.254.254.1/24 ipv4.nat=false

lxc profile create proxyhostprofile
cat ./lxd_profile_proxy_host.yml | lxc profile edit proxyhostprofile


## start the managers
lxc copy dockertemplate/dockerSnapshot proxyhost
lxc profile apply proxyhost dockerpriv,proxyhostprofile

# bind mount
lxc config device add proxyhost dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/proxyhost

# push docker.json for registry mirror settings
lxc file push ./proxyhostfiles/daemon.json proxyhost/etc/docker/daemon.json

lxc start proxyhost

sleep 5

# this is just so we can use docker deploy commands.
# TODO DISABLE DOCKER DAEMON API FOR SECURITY?
lxc exec proxyhost -- docker swarm init --advertise-addr=10.254.254.2

# push relevant files to the proxyhost
lxc exec proxyhost -- mkdir -p /app
lxc file push ./proxyhostfiles/envtemp proxyhost/app/env
lxc file push ./proxyhostfiles/mirror.yml proxyhost/app/mirror.yml
lxc file push ./proxyhostfiles/mirror.conf.yml proxyhost/app/mirror.conf.yml
lxc file push ./proxyhost_entrypoint.sh --create-dirs proxyhost/entrypoint.sh

# change permissions and execute /entrypoint.sh
lxc exec proxyhost -- chmod +x /entrypoint.sh
lxc exec proxyhost -- bash -c /entrypoint.sh

