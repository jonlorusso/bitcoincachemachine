#!/bin/bash

lxc delete --force proxyhost >/dev/null

lxc network delete proxyhostnet >/dev/null

lxc profile delete proxyhostprofile >/dev/null

sudo rm -rf /home/ubuntu/.apps/proxyhost
