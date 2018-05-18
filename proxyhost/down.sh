#!/bin/bash

lxc delete --force proxyhost >/dev/null

lxc network delete proxyhostnet >/dev/null

lxc profile delete proxyhostprofile >/dev/null


lxc storage rm bcm_proxyhost_dockerdata

sudo rm -rf /home/ubuntu/.apps/proxyhost
