# Bitcoin Cache Machine

An application that automatically deploys a pre-configured software-defined datacenter consisting of Bitcoin infrastructure including Lightning Network, messaging via Kafka, and a reporting and logging stack.  Run on bare-metal or VMs. The entire system only needs outbound HTTP/HTTPS and MUST be able to connect to the TOR network (outbound TCP 9050).

## Bitcoin Cache Machine

Bitcoin Cache Machine (BCM) is a software-defined datacenter solution that allows individuals to quickly deploy Bitcoin-related infrastructure, including Lightning Network. All BCM requires to function is a modern Linux kernel--so it will run on-premise (preferred), in the cloud (discouraged), on bare-metal or in a VM.

BCM is designed to be self-contained. If you can run LXD system containers, you can run this application. Modern Linux distributions running on bare-metal or as a virtual machine in a Type I or Type II have been successfully tested.

Bitcoin Cache Machine begins by deploying full Bitcoin infrastructure to the environment via LXD system containers and Docker Swarm. A Bitcoin full node running Bitcoin Core 16.0 is deployed along with all major Lightning implementations. Services provided by the full node and Lightning clients are exposed over TOR onion service for a very cloud-like experience for the end user (assuming the client can connect to the TOR network).

## Bitcoin Cache Machine Components

Each of the components listed below represent one or more logical groupints of LXC system containers. Each LXC system container The system uses cloud-init to provision each system container. All system containers run Docker daemon is Docker Swarm configuration.

The main system containers are listed below:

1. Proxyhost -- provides HTTP/HTTPS proxy for system containers requiring outbound HTTP/HTTPS requests. Proxyhost connects to the lxdbr0 bridge that NATs to the host IP address. Proxyhost also runs a Docker registry configured as a pull-through cache.

2. Manager hosts -- There are three manager hosts to facilitate a Docker Swarm manager role. The docker daemon on the manager hosts are configured to use the proxyhost for outbound HTTP/HTTPS requests. Swarm hosts also run docker registry mirrors to serve images to all docker daemons residing in other LXD hosts.

3. Application Hosts -- LXD hosts intended for application-specific purposes.  Worker hosts requiring outbound network access The docker daemon on worker hosts is configured to obtain images from a docker registry mirror running on the manager hosts.  Worker hosts are assumed to exist by applications and are reserved for general-purpose application workloads.  Some applications, such as kafka, require more specific configurations of LXC system containers.

