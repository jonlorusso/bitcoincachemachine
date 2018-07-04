#!/bin/bash


lxc delete --force manager1 >/dev/null
lxc delete --force manager2 >/dev/null
lxc delete --force manager3 >/dev/null
lxc delete --force manager-template > /dev/null

lxc network delete managernet >/dev/null
lxc network delete workernet >/dev/null

lxc profile delete manager1_profile >/dev/null
lxc profile delete manager2_profile >/dev/null
lxc profile delete manager3_profile >/dev/null
lxc profile delete manager_template_profile >/dev/null


sudo rm -rf /home/multipass/.apps/manager1
sudo rm -rf /home/multipass/.apps/manager2
sudo rm -rf /home/multipass/.apps/manager3

