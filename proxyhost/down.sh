#!/bin/bash

rm -rf /tmp/proxyhost

lxc delete --force proxyhost

lxc network delete proxyhostnet

lxc profile delete proxyhostprofile

sudo rm -rf /home/multipass/.apps/proxyhost
