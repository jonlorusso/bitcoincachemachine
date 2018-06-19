#!/bin/bash

## start the managers
lxc copy dockertemplate/dockerSnapshot manager-template
#lxc profile apply manager-template dockerpriv
# lxc file push ./https-proxy.conf manager-template/etc/systemd/system/docker.service.d/https-proxy.conf
lxc file push ./daemon.json manager-template/etc/docker/daemon.json
lxc file push ./managerfiles/* --recursive --create-dirs manager-template/app/
lxc file push ./manager-entrypoint.sh manager-template/entrypoint.sh

lxc snapshot manager-template "managerTemplate"
