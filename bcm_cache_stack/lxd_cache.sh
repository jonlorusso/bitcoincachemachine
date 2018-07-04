#!/bin/bash

# #configure lxd to listen for requests
lxd init --preseed <<EOF
config:
  core.https_address: '[::]:8443'
cluster: null
networks: []
storage_pools: []
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
EOF

lxc image copy ubuntu:18.04 local: --alias bcm-bionic --public --auto-update

docker stack deploy -c ./bcm_cachestack.yml bcm_cachestack


#Configures an LXD daemon to serve images to remote clients
lxc image copy ubuntu:18.04 local: --alias bcm-bionic --public