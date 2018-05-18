#!/bin/bash

bash -f ./stage_managers.sh

sleep 20

bash -c ./create_swarm.sh

# execute /entrypoint.sh
lxc exec manager1 -- chmod +x /entrypoint.sh
lxc exec manager1 -- bash -c /entrypoint.sh
