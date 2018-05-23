#!/bin/bash

echo "Building and kafka-connect with SYSLOG plugin."
#this step prepares custom images
docker build -t farscapian/kafkaconnect:latest ./connect/
docker push farscapian/kafkaconnect:latest


echo "Building and logstash"
#this step prepares custom images
docker build -t farscapian/logstash:latest ./logstash/
docker push farscapian/logstash:latest
