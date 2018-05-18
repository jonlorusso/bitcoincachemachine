#!/bin/bash


lxc delete --force dockertemplate >/dev/null

lxc profile delete dockertemplate_profile >/dev/null
lxc profile delete default >/dev/null

lxc network delete lxdbr0


# # remove ubuntu:artful base image
#lxc image rm 986834fcb5d5

#lxc storage rm bcm_data
