!/bin/bash

echo "Building and pushing bitcoind."
#this step prepares custom images
docker build -t farscapian/bitcoind:latest ./bitcoind/
docker push farscapian/bitcoind:latest

echo "Building and pushing lnd."
#this step prepares custom images
docker build -t farscapian/lnd:latest ./lnd/
docker push farscapian/lnd:latest

echo "Building and pushing lncli-web."
# adds start script for waiting on lnd rpc to come online
docker build -t farscapian/lncliweb:latest ./lncliweb/
docker push farscapian/lncliweb:latest

# echo "Building and pushing onionproxy."
# # adds start script for waiting on lnd rpc to come online
# docker build -t $BCM_ONIONPROXY_IMAGE ./onionproxy/
# docker push $BCM_ONIONPROXY_IMAGE
