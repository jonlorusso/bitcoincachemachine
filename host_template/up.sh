#!/bin/bash

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

# create resources for managers
lxc network create lxdbr0
lxc storage create bcm_data zfs size=10GB

# create necessary templates
lxc profile create dockertemplate
cat ./lxd_profile_docker_template.yml | lxc profile edit dockertemplate

lxc profile create dockerpriv
cat ./lxd_profile_docker_privileged.yml | lxc profile edit dockerpriv

# lxc profile create dockerunpriv
# cat ../shared/lxd_profile_docker_unprivileged.yml | lxc profile edit dockerunpriv

#create the container (ubuntu:18.04)
lxc init ubuntu:17.10 -p dockerpriv -p dockertemplate dockertemplate

lxc start dockertemplate

echo "Waiting for the LXC container to start and cloud-init to complete provisioning"
# wait for cloud-init to finish
# search for 'Cloud-init v. 18.2 finished at' waitforit type tail from file?"
lxc exec dockertemplate -- timeout 180 /bin/bash -c "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 2; done"

# grab the reference snapshot
## checking if this alleviates docker swarm troubles in lxc.
#https://github.com/stgraber/lxd/commit/255b875c37c87572a09e864b4fe6dd05a78b4d01
lxc exec dockertemplate -- touch /.dockerenv

lxc file push ./sysctl.conf dockertemplate/etc/sysctl.conf
lxc exec dockertemplate -- chmod 0644 /etc/sysctl.conf

lxc snapshot dockertemplate dockerSnapshot

# stop the template since we don't need it running anymore.
lxc stop dockertemplate


