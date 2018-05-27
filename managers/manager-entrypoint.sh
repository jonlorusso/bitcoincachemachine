#!/bin/bash

docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data  portainer/portainer
#-e HTTP_PROXY=http://proxyhost:3128 
#docker stack deploy -c /app/mirror.yml mirror

docker stack deploy -c /app/kafka.yml kafka

sleep 3 

docker stack deploy -c /app/kafka-tools.yml kafkatools


# # Wait for necessary services then create a syslog connector on Kafka Connected
# # send REST command to Kafka to configure a TCP syslog connector
# wait-for-it -t 0 manager1:8082 -- wait-for-it -t 0 manager1:8081 -- wait-for-it -t 0 manager1:8083

# sleep 90

# curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d @/app/TCPSyslogSourceConnector.json http://localhost:8083/connectors/


# # run Consul
# # lxc exec manager1 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.10 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8
# # lxc exec manager2 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.11 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8
# # lxc exec manager3 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.12 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8

