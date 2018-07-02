# bcm_bootstrap

Files related to bootstrapping Bitcoin Cache Machine https://github.com/farscapian/bitcoincachemachine.  You can run Bitcoin Cache Machine in a virtual machine environment (e.g., "in the cloud" or on a Windows Hyper-V or VirtualBox vm) or on bare-metal running Ubuntu Artful.

The easiest way to get started with Bitcoin Cache Machine is if you are already running an Ubuntu instance that supports LXD directly.  If that's the case, Bitcoin Cache Machine directly on your machine. The sections below provide instructions on deploying Bitcoin Cache Machine depending on circumstances.

## Running Bitcoin Cache Machine on bare-metal Ubuntu Artful

Since BCM is built entirely in LXD, you SHOULD be able to run it on any LXD capable machine (theoretically I think). If you have Ubuntu Artful (Desktop or Server) installed on a bare-metal machine, you can run BCM directly on top--no VM required. Only Ubuntu Artful has been tested at this point.

### Steps

First, install LXD and zfs-utils.

```bash
sudo apt install zfsutils-linux
sudo snap install lxd
```

Next, clone the Bitcoin Cache Machine repository and run the script.

```bash
# clone the repo
git clone https://github.com/farscapian/bitcoincachemachine

# update permissions and start the process
cd bitcoincachemachine/
chmod +x up_vm.sh
./up_vm.sh
```

Bitcoin Cache Machine will now be provisioned to the bare-metal machine running Ubuntu Artful.

## Running Bitcoin Cache Machine in a VM


### Base OS is Ubuntu Artful

If you're a developer and want to test Bitcoin Cache Machine in a test environment and you're running Ubuntu, consider using multipass. Multipass allows you to quickly spin up VMs. It's installed via snap.

```bash
sudo snap install multipass
```

Next, clone this repository and start execute `up_vm.sh`.  It's important to update the .env file to define how many resources you want to give to BCM. Furthermore, you should update user-data.yml if you  The more the better.important to update the .env file to define how many resources you want to give to BCM.  The more the better.

```bash
# clone the repo
git clone https://github.com/farscapian/bcm_bootstrap

# update permissions and start the process
cd bcm_bootstrap/
```

A HTTP, HTTPS, or Docker Registry PROXY sitting on your local network decreases deployment time (especially subsequent deployments).  If you have these proxies, consider adding the following lines to the file `user-data.yml` in the `runcmd:` stanza. The lines below should be inserted just before the final line (e.g., `bash -c /home/ubuntu/bitcoincachemachine/up.sh &` ).

```yml
runcmd:
- echo 'export HTTP_PROXY="http://nextcloud.farscapian.com:3128"' >> /home/ubuntu/bitcoincachemachine/.env
- echo 'export HTTPS_PROXY="http://nextcloud.farscapian.com:3128"' >> /home/ubuntu/bitcoincachemachine/.env
- echo 'export REGISTRY_PROXY_REMOTEURL="http://nextcloud.farscapian.com:5000"' >> /home/ubuntu/bitcoincachemachine/.env
- cat /home/ubuntu/bitcoincachemachine/.env >> /home/ubuntu/.bashrc
```
Once you're done with .env and user-data.yml, execute the Bitcoin Cache Machine installer.

```
chmod +x up_vm.sh

################################################
## Update .env and/or user-data.yml first
################################################
./up_vm.sh
```

At this point, multipass will download a base Ubuntu Artful image. A cloud-init script is passed to the new VM which continues the process of installating Bitcoin Cache Machine.

#### Install it as a snap

TODO

### Base OS is Windows 10

If you're running a Windows machine machine capable of running Hyper-V, you can create a VM environment for BCM.

TODO Instructions

#### Create an Ubuntu Artful Server VM in Hyper-V

TODO

#### Create an Ubuntu Artful Server VM in VirtualBox

TODO