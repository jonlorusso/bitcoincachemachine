
#!/bin/bash

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set.  Please source a .env file."
  exit 1
fi

# set the working directory to the location where the script is located
# since all file references are relative to this script
cd "$(dirname "$0")"

# create resources for workers
# workers don't get outbound NAT access.
lxc network create workernet ipv4.address=10.1.0.1/24 ipv4.nat=false
lxc network create managernet ipv4.address=10.0.0.1/24 ipv4.nat=false

# create the manager template
bash -c ./create_manager_template.sh

sleep 5

bash -c ./deployFromManagerSnapshot.sh

sleep 5