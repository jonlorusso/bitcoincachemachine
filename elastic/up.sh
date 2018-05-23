
#!/bin/bash

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set.  Please source a .env file."
  exit 1
fi

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

lxc profile create elastic_profile
cat ./elastic_lxd_profile.yml | lxc profile edit elastic_profile


WORKER_TOKEN=$(lxc exec manager1 -- docker swarm join-token worker | grep token | awk '{ print $5 }')


# create manager1, manager2, and manager3 from the template snapshot
for NODE in elastic1 elastic2 elastic3
do	
    lxc copy manager-template/managerTemplate $NODE
    lxc profile apply $NODE default,elastic_profile

    # bind mount for now
    mkdir -p /home/ubuntu/.apps/$NODE
    lxc config device add $NODE dockerdisk disk path=/var/lib/docker source=/home/ubuntu/.apps/$NODE
    # push docker.json for registry mirror settings
    lxc file push ./daemon.json $NODE/etc/docker/daemon.json
    #lxc file push ./environment bitcoin/etc/environment

    lxc start $NODE

    sleep 10

    lxc exec $NODE -- docker swarm join 10.0.0.10 --token $WORKER_TOKEN

    lxc exec manager1 -- mkdir -p /app/elastic
    lxc file push ./managerfiles/* --recursive --create-dirs $NODE/app/elastic/

    # # change permissions and execute /entrypoint.sh
    lxc exec $NODE -- chmod +x /app/elastic/entrypoint.sh
    lxc exec $NODE -- bash -c /app/elastic/entrypoint.sh

done

