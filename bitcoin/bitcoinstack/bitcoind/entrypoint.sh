#!/bin/bash
set -e

# echo "Redirecting stdout and stderr to syslog host $SYSLOG_DESTINATION on port $SYSLOG_PORT using tag $SYSLOG_TAG."
# exec 1> >(logger -s -n $SYSLOG_DESTINATION --port $SYSLOG_PORT --tcp -t $SYSLOG_TAG) 2>&1


# #keep checking for ipfs.complete; when it exists, proceed.
# while [ ! -f /shared/ipfs.complete ]; do
#    echo "waiting for ipfs bootstrap to complete"
#    sleep 10
# done

#start tor service
#tor

#first, wait for TOR proxy


#r un tor process using torrc config file
# which should be configured to run as daemon
echo "Starting tor on $HOSTNAME"
tor -f /var/lib/tor/torrc

# wait for tor to come online
wait-for-it -t 0 127.0.0.1:9050
wait-for-it -t 0 127.0.0.1:9051

echo "Linking /home/bitcoin/.bitcoin with /data"
ln -sfn /data /home/bitcoin/.bitcoin
chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
chown -h bitcoin:bitcoin /data

echo "Copying /run/secrets/bitcoin.conf to /home/bitcoin/.bitcoin/bitcoin.conf"
cp --remove-destination /run/secrets/bitcoin.conf /home/bitcoin/.bitcoin/bitcoin.conf

echo "Copying /run/secrets/bitcoin.conf to /root/.bitcoin/bitcoin.conf"
mkdir -p /root/.bitcoin/
cp --remove-destination /run/secrets/bitcoin.conf /root/.bitcoin/bitcoin.conf
chown root:root /root/.bitcoin/bitcoin.conf
chmod 0440 /root/.bitcoin/bitcoin.conf

echo "Updating permissions on bitcoin data directory files."
chown -R bitcoin:bitcoin /home/bitcoin/.bitcoin

if [[ $BITCOIND_CHAIN = "mainnet" ]]
then
  echo "Starting bitcoind on mainnet."
  echo "running:  bitcoind -conf=/home/bitcoin/.bitcoin/bitcoin.conf -datadir=/home/bitcoin/.bitcoin -assumevalid=00000000000000000009f1f03bc2423aebb73b148a227a176f4ce9ad7cfaed52"
  bitcoind -conf=/home/bitcoin/.bitcoin/bitcoin.conf -datadir=/home/bitcoin/.bitcoin -assumevalid=00000000000000000009f1f03bc2423aebb73b148a227a176f4ce9ad7cfaed52
elif [[ $BITCOIND_CHAIN = "testnet" ]]
then
  echo "Starting bitcoind on testnet."
  echo "bitcoind -conf=/home/bitcoin/.bitcoin/bitcoin.conf -datadir=/home/bitcoin/.bitcoin -assumevalid=00000000000001db206ff4c7c82b9faad4ae60232f7464c6507368f5de4304dd"
  bitcoind -conf=/home/bitcoin/.bitcoin/bitcoin.conf -datadir=/home/bitcoin/.bitcoin -assumevalid=00000000000001db206ff4c7c82b9faad4ae60232f7464c6507368f5de4304dd
else
  echo "Invalid BITCOIND_CHAIN value.  Quitting."
  exit 1
fi

