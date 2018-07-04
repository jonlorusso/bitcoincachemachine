#!/bin/bash

lxc delete --force nextcloud >/dev/null
 
lxc profile delete nextcloud

lxc network delete nextcloudBridge

sleep 2

sudo rm -rf /home/multipass/.apps/nextcloud

sleep 5

lxc exec manager1 -- docker node rm nextcloud


sleep 10 

lxc exec manager1 -- docker node rm nextcloud

