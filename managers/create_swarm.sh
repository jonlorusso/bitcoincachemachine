#!/bin/bash

lxc exec manager1 -- docker swarm init --advertise-addr=10.0.0.10 >>/dev/null

MANAGER_TOKEN=$(lxc exec manager1 -- docker swarm join-token manager | grep token | awk '{ print $5 }')

lxc exec manager2 -- docker swarm join 10.0.0.10 --advertise-addr 10.0.0.11 --token $MANAGER_TOKEN

lxc exec manager3 -- docker swarm join 10.0.0.10 --advertise-addr 10.0.0.12 --token $MANAGER_TOKEN
