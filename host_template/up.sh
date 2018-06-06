#!/bin/bash

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

# create resources for managers
lxc network create lxdbr0
lxc storage create bcm_data zfs size=10GB

# create necessary templates
# default profile has our root device listed

cat ./default_lxd_profile.yml | lxc profile edit default

# create necessary templates
lxc profile create dockertemplate_profile
cat ./lxd_profile_docker_template.yml | lxc profile edit dockertemplate_profile

#create the container (ubuntu:18.04)
#lxc init ubuntu:17.10 -p default -p dockertemplate_profile dockertemplate
lxc init ubuntu:18.04 -p default -p dockertemplate_profile dockertemplate

lxc start dockertemplate

sleep 5
# wait for cloud-init to finish

echo "Waiting for the LXC container to start and cloud-init to complete provisioning"
lxc exec dockertemplate -- timeout 180 /bin/bash -c "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done"

sleep 5

# grab the reference snapshot
## checking if this alleviates docker swarm troubles in lxc.
#https://github.com/stgraber/lxd/commit/255b875c37c87572a09e864b4fe6dd05a78b4d01
lxc exec dockertemplate -- touch /.dockerenv

lxc file push ./sysctl.conf dockertemplate/etc/sysctl.conf
lxc exec dockertemplate -- chmod 0644 /etc/sysctl.conf



# # # # stop the template since we don't need it running anymore.
lxc stop dockertemplate

lxc profile remove dockertemplate dockertemplate_profile

lxc snapshot dockertemplate dockerSnapshot

