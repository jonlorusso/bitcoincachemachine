#!/bin/bash

# create manager1, manager2, and manager3 from the template snapshot
for NODE in elastic1 elastic2 elastic3
do	
    lxc exec manager1 -- docker node rm $NODE

    lxc delete --force $NODE
done

lxc profile delete elastic_profile