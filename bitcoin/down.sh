#!/bin/bash


lxc delete --force bitcoin >/dev/null

lxc profile delete bitcoinprofile >/dev/null

sudo rm -rf /home/ubuntu/.apps/bitcoin

