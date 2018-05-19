# Bitcoin Cache Machine

```
***IMPORTANT!!!!*** Bitcoin Cache Machine is intended for testing purposes ONLY! It is very new and under heavy development by a single author, so there will be bugs!
```

Bitcoin Cache Machine is a software-defined datacenter designed primarily for individuals and small businesses wanting to run their own Bitcoin full node software (e.g., a company, Bitcoin Maximalists, etc.,) and associated infrastructure. Bitcoin Cache Machine runs a fully validating Bitcoin Core node (v16.0), lightning network daemon (all implementations are planned), and a messaging (Kafka)/logging, and reporting stack. Bitcoin Cache Machine deploys in a fully automated fashion and runs on bare-metal, in a VM, or in the cloud.

## Introduction

Bitcoin Cache Machine (BCM) is a software-defined datacenter solution that allows individuals to quickly deploy Bitcoin-related infrastructure including a fully-validating Bitcoin Core node (testnet supported at the moment), Lightning Network Daemon (lnd), associated wallet software, payment processing back-ends like BTCPay Server (planned), notifications (planned), etc.. Services with remote clients are exposed on the TOR overlay network. All BCM requires to function is a modern Linux kernel -- so it will run on-premise (preferred), in the cloud (discouraged), on bare-metal or in a VM. The only network requirement is outbound TCP 9050 (TOR) which most home networks allow. This is required since BCM exposes some of the services on the TOR overlay network facilitating client connections (e.g., a wallet app on your phone, or maybe a block explorer). This allows you to host your own infrastructure while maintaining a very cloud-like feel, all without having to fiddle with your external firewall.

BCM begins by deploying full Bitcoin infrastructure to the environment via LXD system containers running Docker daemon. A Bitcoin full node running Bitcoin Core 16.0 is deployed along with Lightning Network Daemon (lnd) (other implementations planned). BCM includes Kafka infrastructure for distributed messaging and stream processing. All logs are sent to Kafka which is the system of record for user data. Event processing if facilitated by Kafka Streams.

### How to Run Bitcoin Cache Machine

If you can run LXD system containers, you can run BCM. For bare-metal, Ubuntu Artful has been successfully tested. You can also run BCM in a virtual environment. Visit https://github.com/farscapian/bcm_bootstrap to discover the various ways you can deploy Bitcoin Cache Machine in a VM (on-premise or in the cloud).

## Bitcoin Cache Machine Components

Each of the components listed below represent one or more logical groups of LXC system containers. Each LXC system container is provisioned via cloud-init. All system containers run Docker daemon in Docker Swarm configuration.

The main system containers are listed below:

1. Proxyhost -- provides HTTP/HTTPS proxy for system containers requiring outbound HTTP/HTTPS requests. Proxyhost connects to the lxdbr0 bridge that NATs to the host IP address. Proxyhost also runs a Docker registry configured as a pull-through cache.

2. Manager hosts -- There are three manager hosts to facilitate a Docker Swarm manager role for the rest of the swarm. The docker daemon on each manager host is configured to use the proxyhost for outbound HTTP/HTTPS requests. Swarm hosts also run docker registry mirrors to serve images to all docker daemons residing in other LXD hosts.

3. App Hosts -- LXD hosts intended for application-specific purposes, such as Bitcoin full node or perhaps a Nextcloud instance (planned).  Application hosts requiring outbound network access connect to proxyhost for outbound connectivity. The docker daemon on app hosts is configured to obtain images from a docker registry mirror running on the manager hosts.
