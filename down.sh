#!/bin/bash


echo "Destroying nextcloud"
./nextcloud/down.sh >/dev/null

echo "Destroying managers"
./managers/down.sh >/dev/null

echo "Destroying proxyhost"
./proxyhost/down.sh >/dev/null

echo "Destrying host template"
./host_template/down.sh >/dev/null
