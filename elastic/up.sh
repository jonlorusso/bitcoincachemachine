
#!/bin/bash

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"


if [[ $(lxc list | grep elastic-template) != '' ]] 
then
  echo "Creating nodes on existing elastic-template snapshot."
else
  echo "Creating LXD snapshot for elastic hosts."
  
  lxc profile create elastic_profile
  cat ./elastic_lxd_profile.yml | lxc profile edit elastic_profile

  lxc copy dockertemplate/dockerSnapshot elastic-template
  lxc profile apply elastic-template default,elastic_profile

  # push docker.json for registry mirror settings
  lxc file push ./daemon.json elastic-template/etc/docker/daemon.json
  #lxc file push ./environment elastic-template/etc/environment
  #lxc file push ./proxyconfig.conf elastic-template/etc/systemd/system/docker.service.d/https-proxy.conf
  lxc file push ./sysctl.conf elastic-template/etc/sysctl.conf
  
  lxc snapshot elastic-template elasticStaged
fi

WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')

# create manager1, manager2, and manager3 from the template snapshot
for ELASTIC_NODE in elastic1
do	
  echo "Creating $ELASTIC_NODE from elastic-template/elasticStaged"
  lxc copy elastic-template/elasticStaged $ELASTIC_NODE

  echo "Bind mounting /var/lib/docker in $ELASTIC_NODE to /home/ubuntu/.apps/$ELASTIC_NODE"
  mkdir -p /home/ubuntu/.apps/$ELASTIC_NODE
  lxc config device add $ELASTIC_NODE dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/$ELASTIC_NODE

  lxc start $ELASTIC_NODE
  
done

sleep 10

# create manager1, manager2, and manager3 from the template snapshot
for ELASTIC_NODE in elastic1
do	
  lxc exec $ELASTIC_NODE -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN
  # lxc exec $ELASTIC_NODE -- mkdir -p /app/elastic

  # lxc file push ./elastic-master.yml $ELASTIC_NODE/app/elastic/docker-compose.yml

  # lxc file push ./elastic-entrypoint.sh $ELASTIC_NODE/app/elastic/up.sh
  # lxc exec $ELASTIC_NODE -- chmod +x /app/elastic/up.sh
  # lxc exec $ELASTIC_NODE -- bash -c /app/elastic/up.sh
done


lxc exec manager1 -- mkdir -p /app/elastic
lxc file push ./managerfiles/* --recursive --create-dirs manager1/app/elastic

# # change permissions and execute /entrypoint.sh
lxc exec manager1 -- chmod +x /app/elastic/entrypoint.sh
lxc exec manager1 -- bash -c /app/elastic/entrypoint.sh

