#!/bin/bash

lxc delete --force manager1 >/dev/null
lxc delete --force manager2 >/dev/null
lxc delete --force manager3 >/dev/null

lxc network delete managernet >/dev/null
lxc network delete workernet >/dev/null

lxc profile delete manager1 >/dev/null
lxc profile delete manager2 >/dev/null
lxc profile delete manager3 >/dev/null

sudo rm -rf /home/derek/.apps/manager1
sudo rm -rf /home/derek/.apps/manager2
sudo rm -rf /home/derek/.apps/manager3

