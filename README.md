# Bitcoin Cache Machine in a paragraph

IMPORTANT!!!!  Bitcoin Cache Machine is intended for development purposes ONLY!

Bitcoin Cache Machine is a software-defined datacenter designed for primarily for individuals or small businesses wanting to run their own Bitcoin full node software (e.g., a company, Bitcoin Maximalists, etc.,). Bitcoin Cache Machine runs a fully validating Bitcoin Core node (v16.0), lightning network daemon (all implementations are planned), and a messaging (Kafka)/logging, and reporting stack. Bitcoin Cache Machine deploys in a fully automated fashion.

## Introduction

Bitcoin Cache Machine (BCM) is a software-defined datacenter solution that allows individuals to quickly deploy Bitcoin-related infrastructure including a fully-validating Bitcoin Core node, Lightning Network Daemon (lnd), associated wallet software, payment processing back-ends like BTCPay Server (planned), notifications (planned), etc.. Services with remote clients are exposed on the TOR overlay network. All BCM requires to function is a modern Linux kernel -- so it will run on-premise (preferred), in the cloud (discouraged), on bare-metal or in a VM. The only network requirement is outbound TCP 9050 (TOR) which most home networks allow.

BCM begins by deploying full Bitcoin infrastructure to the environment via LXD system containers running Docker daemon. A Bitcoin full node running Bitcoin Core 16.0 is deployed along with Lightning Network Daemon (lnd) (other implementations planned). BCM includes Kafka infrastructure for distributed messaging and stream processing. All logs are sent to Kafka which is the system of record for user data.

### How to Run Bitcoin Cache Machine

If you can run LXD system containers, you can run BCM. For bare-metal, Ubuntu Artful has been successfully tested. You can also run BCM in a virtual environment. Visit https://github.com/farscapian/bcm_bootstrap to discover the various ways you can deploy Bitcoin Cache Machine in a VM (on-premise or in the cloud).

## Bitcoin Cache Machine Components

Each of the components listed below represent one or more logical groups of LXC system containers. Each LXC system container is provisioned via cloud-init. All system containers run Docker daemon in Docker Swarm configuration.

The main system containers are listed below:

1. Proxyhost -- provides HTTP/HTTPS proxy for system containers requiring outbound HTTP/HTTPS requests. Proxyhost connects to the lxdbr0 bridge that NATs to the host IP address. Proxyhost also runs a Docker registry configured as a pull-through cache.

2. Manager hosts -- There are three manager hosts to facilitate a Docker Swarm manager role. The docker daemon on eacho manager host is configured to use the proxyhost for outbound HTTP/HTTPS requests. Swarm hosts also run docker registry mirrors to serve images to all docker daemons residing in other LXD hosts.

3. app Hosts -- LXD hosts intended for application-specific purposes.  Application hosts requiring outbound network access connect to proxyhost for outbound connectivity. The docker daemon on app hosts is configured to obtain images from a docker registry mirror running on the manager hosts.
