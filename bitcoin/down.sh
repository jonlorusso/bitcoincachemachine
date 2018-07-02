#!/bin/bash

lxc exec manager1 -- docker stack rm btcstack

lxc delete --force bitcoin >/dev/null

lxc profile delete bitcoinprofile >/dev/null

lxc network delete lxdbrBitcoin

sudo rm -rf /home/multipass/.apps/bitcoin


# wait for the node to go down them remove the node from the stack
#lxc exec manager1 -- docker node rm bitcoin

