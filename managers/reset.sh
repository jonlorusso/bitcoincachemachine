#!/bin/bash

for MANAGER in manager1 manager2 manager3
do	
    lxc delete --force $MANAGER >/dev/null
    lxc profile delete "$MANAGER"_profile
    sudo rm -rf /home/multipass/.apps/$MANAGER
done

sleep 3

bash -c ./deployFromManagerSnapshot.sh
