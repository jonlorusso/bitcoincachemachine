#!/bin/bash

lxc file push ./https-proxy.conf manager-template/etc/systemd/system/docker.service.d/https-proxy.conf
lxc file push ./daemon.json manager-template/etc/docker/daemon.json
lxc file push ./managerfiles/* --recursive --create-dirs manager-template/app/
lxc file push ./manager-entrypoint.sh manager-template/entrypoint.sh

lxc exec manager1 -- docker stack deploy -c /app/kafka-tools.yml kafkatools
