#!/bin/bash

lxc exec manager1 -- docker stack rm elastic

# create manager1, manager2, and manager3 from the template snapshot
for NODE in elastic1 elastic2 elastic3 elastic-template
do	
    lxc delete --force $NODE
    sudo rm -rf /home/ubuntu/.apps/$NODE
done

sleep 1  

  # create manager1, manager2, and manager3 from the template snapshot
for NODE in elastic1 elastic2 elastic3 elastic_template
do	
    lxc exec manager1 -- docker node rm $NODE
done
  
lxc profile delete elastic_profile
lxc exec manager1 -- docker system prune -f

