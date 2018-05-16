#!/bin/bash

echo "upstack.sh - waiting for kafka_tools to come online"


# sudo apt install wait-for-it
# must be on machine provisioning lxc stack
wait-for-it -t 0 manager1:8083

# wait for kafka to do its thing
sleep 120

curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d @/app/TCPSyslogSourceConnector.json localhost:8083/connectors
