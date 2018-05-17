#!/bin/bash


lxc delete --force dockertemplate >/dev/null

lxc network delete lxdbr0
lxc profile delete dockertemplate >/dev/null
lxc profile delete dockerpriv >/dev/null
lxc profile delete dockerunpriv >/dev/null

# remove ubuntu:artful base image
#lxc image rm 986834fcb5d5

#lxc storage rm bcm_data
