#!/bin/bash

docker stack rm btcstack

sleep 5

docker system prune -f


sleep 5

docker system prune -f --volumes
