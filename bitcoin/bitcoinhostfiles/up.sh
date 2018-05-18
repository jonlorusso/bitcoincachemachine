#!/bin/bash

wait-for-it -t 0 manager1:514

docker stack deploy -c /app/bitcoin/bitcoinstack.yml bitcoinstack
