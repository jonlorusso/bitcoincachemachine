#!/bin/bash

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

source /etc/environment

docker stack deploy -c kibana-stack.yml kibana
