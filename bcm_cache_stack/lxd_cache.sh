#~/bin/bash

#Configures an LXD daemon to serve images to remote clients
lxc image copy ubuntu:18.04 local: --alias bcm-bionic

lxc image copy ubuntu:18.04 local: --alias bcm-bionic --public