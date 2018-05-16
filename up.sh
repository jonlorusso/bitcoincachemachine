#!/bin/bash

echo "creating an LXD system container template for running docker applications."
./host_template/up.sh

echo "Deploying proxyhost"
./proxyhost/up.sh

echo "Creating swarm with 3 managers"
./managers/up.sh

echo "deploying an lxd host for nextcloud"
./nextcloud/up.sh

