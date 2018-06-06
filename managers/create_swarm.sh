#!/bin/bash

lxc exec manager1 -- docker swarm init --advertise-addr=10.0.0.10

sleep 5

MANAGER_TOKEN=$(lxc exec manager1 -- docker swarm join-token manager | grep token | awk '{ print $5 }')

lxc exec manager2 -- docker swarm join --token $MANAGER_TOKEN 10.0.0.10:2377

sleep 2

lxc exec manager3 -- docker swarm join --token $MANAGER_TOKEN 10.0.0.10:2377
