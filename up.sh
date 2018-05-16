#!/bin/bash

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

echo "creating an LXD system container template for running docker applications."
./host_template/up.sh

echo "Deploying proxyhost"
./proxyhost/up.sh

echo "Creating swarm with 3 managers"
./managers/up.sh

echo "deploying an bitcoin infrastructure."
./bitcoin/up.sh

