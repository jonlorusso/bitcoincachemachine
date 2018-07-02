#!/bin/bash

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

#for temp files
mkdir -p /tmp/proxyhost

# a network shared by./dep hosts needing outbound http proxy access (e.g., managers)
lxc network create proxyhostnet ipv4.address=10.254.254.1/24 ipv4.nat=false ipv6.nat=false

lxc profile create proxyhostprofile
cat ./lxd_profile_proxy_host.yml | lxc profile edit proxyhostprofile

## start the managers
lxc copy dockertemplate/dockerSnapshot proxyhost
lxc profile apply proxyhost docker,proxyhostprofile

# bind mount for /var/lib/docker
# TODO get this to work with ZFS backend.
mkdir -p /home/multipass/.apps/proxyhost
lxc config device add proxyhost dockerdisk disk path=/var/lib/docker source=/home/multipass/.apps/proxyhost

# push environment variables passed through by provisioner
# if running bare-metal, must source your environment prior to
# execution.

# clear it out first

> /tmp/proxyhost/envtemp
echo "export HTTP_PROXY=$HTTP_PROXY" >> /tmp/proxyhost/envtemp
echo "export HTTPS_PROXY=$HTTPS_PROXY" >> /tmp/proxyhost/envtemp
echo "export REGISTRY_PROXY_REMOTEURL=$BCM_REGISTRY_PROXY_REMOTEURL" >> /tmp/proxyhost/envtemp
lxc file push /tmp/proxyhost/envtemp proxyhost/etc/environment

# configure docker daemon proxy HTTP proxy
> /tmp/proxyhost/https-proxy.conf
echo "[Service]" >> /tmp/proxyhost/https-proxy.conf
echo "Environment=\"HTTPS_PROXY=$HTTPS_PROXY/\"" >> /tmp/proxyhost/https-proxy.conf
#lxc file push /tmp/proxyhost/https-proxy.conf proxyhost/etc/systemd/system/docker.service.d/https-proxy.conf

# generate and push docker.json for registry mirror settings
# BCM_REGISTRY_PROTXY_REMOTEURL must be set
echo "{\"registry-mirrors\": [\"$BCM_REGISTRY_PROXY_REMOTEURL\"] }" > /tmp/proxyhost/daemon.json

# if a registry was provided, modify and push daemon.json for proxyhost.
if [ "$BCM_REGISTRY_PROXY_REMOTEURL" != '' ]
then
  lxc file push /tmp/proxyhost/daemon.json proxyhost/etc/docker/daemon.json
fi

lxc start proxyhost

sleep 10

# this is just so we can use docker deploy commands.
# TODO DISABLE DOCKER DAEMON API FOR SECURITY?
lxc exec proxyhost -- docker swarm init --advertise-addr=10.254.254.2 >> /dev/null

# push relevant files to the proxyhost
lxc exec proxyhost -- mkdir -p /app
lxc file push ./proxyhostfiles/mirror.yml proxyhost/app/mirror.yml
lxc file push ./proxyhostfiles/proxyhost_entrypoint.sh proxyhost/entrypoint.sh


# change permissions and execute /entrypoint.sh
lxc exec proxyhost -- chmod +x /entrypoint.sh
lxc exec proxyhost -- bash -c /entrypoint.sh