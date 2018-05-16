


#ip addresses are the host IP of the ubuntu on the stable/fast network interface
#may want to reserve or have registration method; probably done in OpenStack / MaSS?
docker-machine create --driver generic --generic-ip-address=192.168.1.5 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user derek bootstrap
docker-machine create --driver generic --generic-ip-address=192.168.1.20 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user derek zotac

docker-machine create --driver generic --generic-ip-address=192.168.1.56 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user derek zotac





####Ensure all initial engines (3 is goal) are reachable at this point.

eval $(docker-machine env bootstrap)

#start swarm
docker swarm init --advertise-addr $(docker-machine ip bootstrap)

#start registry operations to serve images.
docker stack deploy -c registry.yml registry

#run DHCPD on bootstrap to serve new clients.
cd ~/git/farscapian.com/bootstrap/dhcpd
docker build -t farscapian/bootstrap .
docker push farscapian/bootstrap
docker run -d --restart always --net=host farscapian/bootstrap

#start first Consul server process on bootstrap
docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind=$(docker-machine ip bootstrap) -retry-join=$(docker-machine ip zotac) -bootstrap-expect=2

#start a Consul client process on bootstrap; this services local DNS requests and facilitates pub/sub of services
# docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -dns-port=53 -recursor=8.8.8.8 -bind=127.0.0.1 -retry-join=$(docker-machine ip zotac)





#Start COnsul Server process on Zotac
eval $(docker-machine env zotac)
docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind=$(docker-machine ip zotac) -retry-join=$(docker-machine ip bootstrap) -bootstrap-expect=2

#start a Consul clientp rocess on Zotac to service DNS requests and service pub/sub




#client
docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -dns-port=53 -recursor=8.8.8.8 -bind=$(docker-machine ip bootstrap) -retry-join=$(docker-machine ip bootstrap)

#docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -e 'CONSUL_ALLOW_PRIVILIEGED_PORTS=' consul agent -server -bind=$(docker-machine ip bootstrap)  




#start consul server process to provide service registration and discover (DNS)
#docker run -d --name=dev-consul -e CONSUL_BIND_INTERFACE=eth0 --net=host -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=true' consul -dns-port=53 -recursor=8.8.8.8
#8500 is the HTTP API, does DNS on 53.

#add '-retry-join=192.168.1.6 ' in there as a consul parameters.  This would be useful to use if there were 
# a bootstrap DHCP server on the network that were HA.  Great place to stick the two expectant consul servers










docker-machine create --driver generic --generic-ip-address=192.168.1.234 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user derek zotac




# docker volume create dhcpdata

# docker run -it --rm --net=host -v dhcpdata:/data networkboot/dhcpd eth0







# #TODO - convert to push image to self-hosted repo; docker run pulls from that image.
# #TODO - Try to convert this to STACK; almost there; troubleshooting needed.
# #this provides networking services, DHCP/DNS, to the LOCAL NETWORK (i.e., the real network)
# # we're going to let consul to the DNS.   -p "53:53/tcp" -p "53:53/udp"








#####################################################
#SECOND MANAGER--Ideally deploy on separate hardware#
#####################################################

#we omit the dns settings here since it's assumed all further docker-machines will be obtaining IP addresses from the running dnsmasq container.  F0 is the first cicd swarm node with DNS name "cicd"
docker-machine create --driver hyperv \
    --hyperv-cpu-count 2 \
    --hyperv-virtual-switch "External" \
    --engine-insecure-registry "registry.farscapian.com" \
    --engine-registry-mirror "http://registry.farscapian.com:5000" \
    --engine-label purpose=apps \
    apps1

eval $(docker-machine env apps1)
MANAGER_JOIN_TOKEN=`docker-machine ssh bootstrap docker swarm join-token manager | grep 'swarm join'`
$MANAGER_JOIN_TOKEN

# deploy gogs for GIT related services
docker stack deploy -c gogs.yml gogs

#172.17.0.2 is the IP address assigned to eth0 in the consul server conatiner.  Need to pin that down to make deterministic.
docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind=$(docker-machine ip apps1) -retry-join=$(docker-machine ip bootstrap) -bootstrap-expect=1

###CLIENT VERSION####
#docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -bind=$(docker-machine ip apps1) -retry-join=$(docker-machine ip bootstrap)

#docker stack deploy -c consul.yml consul

# ##THESE ARE TEST CASES I GUESS
# choco install jq -y
# #mirror before and after
# curl http://cicd.farscapian.com:5000/v2/_catalog | jq
# docker pull ubuntu
# curl http://cicd.farscapian.com:5000/v2/_catalog | jq
# #should have the alpine image showing in json output from mirror



# #insecure registry before and after
# curl http://cicd.farscapian.com/v2/_catalog | jq
# docker build -t cicd.farscapian.com/dhcpdns .
# docker push cicd.farscapian.com/dhcpdns
# curl http://cicd.farscapian.com/v2/_catalog | jq






