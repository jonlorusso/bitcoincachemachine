#!/bin/bash

lxc exec manager1 -- docker stack rm elastic

# create manager1, manager2, and manager3 from the template snapshot
for NODE in elastic1
do	
    lxc delete --force $NODE
    sudo rm -rf /home/ubuntu/.apps/$NODE
    lxc exec manager1 -- docker node rm $NODEs
done

sleep 1  

lxc rm --force elastic-template
lxc profile delete elastic_profile
lxc exec manager1 -- docker system prune -f
