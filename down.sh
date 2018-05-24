#!/bin/bash

echo "Destrying elastic stuff"
./elastic/down.sh >/dev/null

echo "Destroying bitcoin"
./bitcoin/down.sh >/dev/null

echo "Destroying managers"
./managers/down.sh >/dev/null

echo "Destroying proxyhost"
./proxyhost/down.sh >/dev/null

echo "Destrying host template"
./host_template/down.sh >/dev/null

sudo rm -rf /home/ubuntu/.apps
