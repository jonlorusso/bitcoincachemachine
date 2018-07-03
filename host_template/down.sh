#!/bin/bash

lxc delete --force dockertemplate
lxc profile delete dockertemplate_profile
lxc profile delete docker
lxc network delete lxdbr0
lxc image delete b190d5ec0c53
lxc storage rm bcm_data
