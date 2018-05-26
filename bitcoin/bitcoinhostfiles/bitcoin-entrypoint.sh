#!/bin/bash

echo "Starting /app/bitcoin/bitcoin-entrypoint.sh"

# set the working directory to the location where the script is located
cd "$(dirname "$0")"

source ./environment

if [[ $(env | grep BCM) = '' ]] 
then
  echo "BCM variables not set.  Please source a .env file."
  exit 1
fi

docker pull ipfs/go-ipfs:latest

docker volume create bitcoind-$BCM_BITCOIN_CHAIN-data
docker volume create ipfsdata

docker run -d --name bootstrapper -v bitcoind-$BCM_BITCOIN_CHAIN-data:/bitcoindata -v ipfsdata:/data/ipfs ipfs/go-ipfs:latest daemon

sleep 10

echo "Deploying Bitcoin data on chain $BCM_BITCOIN_CHAIN via IPFS"
if [[ $BCM_BITCOIN_CHAIN = 'devnet' ]] 
then
  echo "BCM_BITCOIN_DEVNET_IPFS_HASH=$BCM_BITCOIN_DEVNET_IPFS_HASH"
  docker exec bootstrapper ipfs get $BCM_BITCOIN_DEVNET_IPFS_HASH -o /bitcoindata
elif [[ $BCM_BITCOIN_CHAIN = 'testnet' ]] 
then
  echo "BCM_BITCOIN_TESTNET_IPFS_HASH=$BCM_BITCOIN_TESTNET_IPFS_HASH"
  docker exec bootstrapper ipfs get $BCM_BITCOIN_TESTNET_IPFS_HASH -o /bitcoindata
elif [[ $BCM_BITCOIN_CHAIN = 'mainnet' ]] 
then
  echo "BCM_BITCOIN_MAINNET_IPFS_HASH=$BCM_BITCOIN_MAINNET_IPFS_HASH"
  docker exec bootstrapper ipfs get $BCM_BITCOIN_MAINNET_IPFS_HASH -o /bitcoindata
else
  echo "BITCOIN_CHAIN not set. Values are devnet testnet and mainnet"
  exit 1
fi

sleep 10 

docker kill bootstrapper
