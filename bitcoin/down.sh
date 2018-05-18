#!/bin/bash

lxc exec manager1 -- docker stack rm bitcoinstack

lxc delete --force bitcoin >/dev/null

lxc profile delete bitcoinprofile >/dev/null

sudo rm -rf /home/ubuntu/.apps/bitcoin


# wait for the node to go down them remove the node from the stack
sleep 15 && lxc exec manager1 -- docker node rm bitcoin &

