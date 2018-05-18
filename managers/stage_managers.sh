#!/bin/bash

# create manager1, manager2, and manager3 from the template snapshot
for MANAGER in manager1 manager2 manager3
do	
    lxc profile create "$MANAGER"_profile
    cat ./lxd_profiles/"$MANAGER".yml | lxc profile edit "$MANAGER"_profile

    lxc copy manager-template/managerTemplate $MANAGER
    lxc profile apply $MANAGER default,"$MANAGER"_profile

    # bind mount for now
    mkdir -p /home/ubuntu/.apps/$MANAGER
    lxc config device add $MANAGER dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/$MANAGER
    
    lxc start $MANAGER
done