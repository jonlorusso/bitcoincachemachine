#!/bin/bash

echo "Building and pushing kafka."
#this step prepares custom images
docker build -t farscapian/kafka:latest ./kafka/

docker push farscapian/kafka:latest



echo "Building and kafka-connect with SYSLOG plugin."
#this step prepares custom images
docker build -t farscapian/kafkaconnect:latest ./connect/
docker push farscapian/kafkaconnect:latest
