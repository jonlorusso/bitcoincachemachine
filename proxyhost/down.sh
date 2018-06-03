#!/bin/bash

lxc delete --force proxyhost

lxc network delete proxyhostnet

lxc profile delete proxyhostprofile

sudo rm -rf /home/ubuntu/.apps/proxyhost
