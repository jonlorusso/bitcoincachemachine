#!/bin/bash

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

# create manager1, manager2, and manager3 from the template snapshot
for MANAGER in manager1 manager2 manager3
do	
    lxc profile create "$MANAGER"_profile
    cat ./lxd_profiles/"$MANAGER".yml | lxc profile edit "$MANAGER"_profile

    lxc copy manager-template/managerTemplate $MANAGER
    lxc profile apply $MANAGER docker,"$MANAGER"_profile

    # bind mount for now
    mkdir -p /home/multipass/.apps/$MANAGER
    lxc config device add $MANAGER dockerdisk disk path=/var/lib/docker source=/home/multipass/.apps/$MANAGER
    
    lxc start $MANAGER
done