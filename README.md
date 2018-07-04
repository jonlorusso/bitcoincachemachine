
# Bitcoin Cache Machine

> **IMPORTANT!!!!**
> Bitcoin Cache Machine is intended for evaluation purposes ONLY!
> It is very new and under heavy development by a single author
> and HAS NOT undergone a formal security evaluation.
> USE AT YOUR OWN RISK

Bitcoin Cache Machine is a software-defined data center designed for individuals wanting their own bitcoin infrastructure. Bitcoin Cache Machine runs a fully validating Bitcoin Core node (v16.0), lightning network daemon (all implementations are planned), a messaging/logging stack, and reporting stack. Bitcoin Cache Machine deploys in a fully automated way and runs on bare-metal, in a VM, on-premise, or in the cloud. It's entirely based on Ubuntu 18.04 Bionic Beaver.

## Why does Bitcoin Cache Machine Exist?

If you're involved with Bitcoin or consider yourself a Bitcoin Maximalist, you will undoubtedly understand the importance of running your own Bitcoin node software. Running a Bitcoin full node is easy enough--just download the software and run it on your home machine. Although running your own Bitcoin full node provides the best form of privacy, there are many other areas where your privacy can be leaked, such as using a third party block explorer or wallet software. 

BCM is meant to bridge that gap by providing a fully automated mechanism to deploy your own Bitcoin infrastructure. BCM is pre-configured to protect user's privacy. Services provided by BCM are exposed on the TOR overlay network providing a very cloud-like experience while anonymizing your IP information and providing end-to-end confidentiality (encryption).

The goal of BCM is to integrate as many of the open-source Bitcoin-related projects out there into an easily deployable format. This includes running associated Lightning Network Daemons (lnd, c-lightning, eclair) for receiving and generating invoices.

## Architecture

BCM is built entirely on Ubuntu 18.04 Bionic Beaver. BCM can run inside a VM or on bare-metal (preferred).  LXD/LXC system containers are used to provision system-level containers (analogous to a VM in the cloud). Docker daemon runs in each LXD system container and is responsible for running application-specific containers.


## Currently implemented features

* Host your own Bitcoin full node (version 16.0). Bitcoind is configured to use TOR hidden services for peer-to-peer network communication.  RPC interfaces MAY be exposed as a TOR hidden service for client wallet software that supports direct communication (e.g., Samouri Wallet)
* Lightning Network Daemon and lncli-web wallet interface
Host your own Nextcloud Instance (planned)!
Host your own secure email infrastructure (planned)!


## Planned Features

* Host your own integrated pric-light, and eClair to transaction or provide liquidiity to the lightning network!  TOR integratedvate block explorer, accessible over TOR (planned)!
* ZAP wallet integration with LND


TCP 9050 (TOR) outbound is required for BCM to function. This is required since BCM exposes some of the services on the TOR overlay network facilitating client connections (e.g., a wallet app on your phone, or maybe a block explorer). This allows you to host your own infrastructure while maintaining a very cloud-like feel, all without having to fiddle with your external firewall.

BCM begins by deploying full Bitcoin infrastructure to the environment via LXD system containers running Docker daemon. A Bitcoin full node running Bitcoin Core 16.0 is deployed along with Lightning Network Daemon (lnd) (other implementations planned). BCM includes Kafka infrastructure for distributed messaging and stream processing. All logs are sent to Kafka which is the system of record for user data. Event processing if facilitated by Kafka Streams.

### How to Run Bitcoin Cache Machine

If you can run LXD system containers, you can run BCM. For bare-metal, Ubuntu Artful has been successfully tested. You can also run BCM in a virtual environment. Visit https://github.com/farscapian/bcm_bootstrap to discover the various ways you can deploy Bitcoin Cache Machine in a VM (on-premise or in the cloud).

## Bitcoin Cache Machine Components

Each of the components listed below represent one or more logical groups of LXC system containers. Each LXC system container is provisioned via cloud-init. All system containers run Docker daemon in Docker Swarm configuration.

The main system containers are listed below:

1. Proxyhost -- provides HTTP/HTTPS proxy for system containers requiring outbound HTTP/HTTPS requests. Proxyhost connects to the lxdbr0 bridge that NATs to the host IP address. Proxyhost also runs a Docker registry configured as a pull-through cache.

2. Manager hosts -- There are three manager hosts to facilitate a Docker Swarm manager role for the rest of the swarm. The docker daemon on each manager host is configured to use the proxyhost for outbound HTTP/HTTPS requests. Swarm hosts also run docker registry mirrors to serve images to all docker daemons residing in other LXD hosts. A Kafka Message stack is also deployed to the manager nodes. Manager nodes are meant to be distributed to independent hardware since it's a distributed system but operate on a single computer just fine. Distributed oepration can be achieved with LXD clustering and VXLAN (I think).

3. App Hosts -- LXD hosts intended for application-specific purposes, such as Bitcoin full node or perhaps a Nextcloud instance (planned).  Application hosts requiring outbound network access connect to proxyhost for outbound connectivity. The docker daemon on app hosts is configured to obtain images from a docker registry mirror running on the manager hosts.
