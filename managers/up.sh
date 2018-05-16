
#!/bin/bash


# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"


mkdir -p /home/derek/.apps/manager1
mkdir -p /home/derek/.apps/manager2
mkdir -p /home/derek/.apps/manager3


# create resources for workers
# workers don't get outbound NAT access.
lxc network create workernet ipv4.address=10.1.0.1/24 ipv4.nat=false
lxc network create managernet ipv4.address=10.0.0.1/24 ipv4.nat=false


# managers need docker-compose
for MANAGER in manager1 manager2 manager3
do	
    lxc profile create $MANAGER
    cat ./lxd_profiles/$MANAGER.yml | lxc profile edit $MANAGER

    ## start the managers
    lxc copy dockertemplate/dockerSnapshot $MANAGER
    lxc profile apply $MANAGER dockerpriv,$MANAGER
    lxc config device add $MANAGER dockerdisk disk path=/var/lib/docker source=/home/derek/.apps/$MANAGER
    lxc file push ./https-proxy.conf $MANAGER/etc/systemd/system/docker.service.d/https-proxy.conf
    lxc file push ./daemon.json $MANAGER/etc/docker/daemon.json
    lxc start $MANAGER
done

sleep 30

lxc exec manager1 -- docker swarm init --advertise-addr=10.0.0.10

MANAGER_TOKEN=$(lxc exec manager1 -- docker swarm join-token manager | grep token | awk '{ print $5 }')

lxc exec manager2 -- docker swarm join 10.0.0.10 --advertise-addr 10.0.0.11 --token $MANAGER_TOKEN

lxc exec manager3 -- docker swarm join 10.0.0.10 --advertise-addr 10.0.0.12 --token $MANAGER_TOKEN

# run Consul
# lxc exec manager1 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.10 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8
# lxc exec manager2 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.11 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8
# lxc exec manager3 -- docker run -d --net=host --restart=always -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' consul agent -server -bind=10.0.0.12 -retry-join=10.0.0.10 -bootstrap-expect=3 -dns-port=53 -recursor=8.8.8.8


lxc file push ./manager1files/* --recursive --create-dirs manager1/app/
lxc file push ./manager1-entrypoint.sh manager1/entrypoint.sh
lxc exec manager1 -- chmod +x /entrypoint.sh
lxc exec manager1 -- bash -c /entrypoint.sh
