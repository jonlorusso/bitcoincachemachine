#!/bin/bash

docker run -d -p 9000:9000 \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/portainer:/data \
  portainer/portainer
 
  #-e HTTP_PROXY=proxyhost:3128 \

docker stack deploy -c /app/mirror.yml mirror

docker stack deploy -c /app/kafka.yml kafka

docker stack deploy -c /app/kafka-tools.yml kafkatools

echo "Calling upstack.sh to provision application services."

bash -c /app/upstack.sh

