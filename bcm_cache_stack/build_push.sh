#!/bin/bash

# echo "Building and pushing lightningd / lightningd."
docker build -t farscapian/lxd:latest ./lxdcache/
docker push farscapian/lxd:latest