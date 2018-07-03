#!/bin/bash

lxc file push ./bitcoinstack/* --recursive --create-dirs manager1/app/bitcoinstack/

# # change permissions and execute /entrypoint.sh
lxc exec manager1 -- chmod +x /app/bitcoinstack/up.sh
lxc exec manager1 -- bash -c /app/bitcoinstack/up.sh
