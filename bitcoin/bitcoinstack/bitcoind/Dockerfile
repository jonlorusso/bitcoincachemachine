FROM ubuntu:artful

# most of the bitcoin stuff came from nicolasdorier
RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget tor procps wait-for-it \
	&& rm -rf /var/lib/apt/lists/*

ENV BITCOIN_VERSION 0.16.1
ENV BITCOIN_URL https://bitcoincore.org/bin/bitcoin-core-0.16.1/bitcoin-0.16.1-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256 10b31d17351ff4c7929cf955e4d24a2398b0ce91509f707faf8596940c12432a
ENV BITCOIN_ASC_URL https://bitcoincore.org/bin/bitcoin-core-0.16.1/SHA256SUMS.asc
ENV BITCOIN_PGP_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964

RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& gpg --keyserver keyserver.ubuntu.com --recv-keys "$BITCOIN_PGP_KEY" \
	&& wget -qO bitcoin.asc "$BITCOIN_ASC_URL" \
	&& gpg --verify bitcoin.asc \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
    && rm -rf /tmp/*

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
	&& chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
	&& ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
	&& chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

VOLUME /data
VOLUME /logs/bitcoind

RUN chown -R root:root /var/lib/tor

WORKDIR /root/.bitcoin

EXPOSE 8332 8333 18332 18333 18443 18444 18501 28332

# ### lightning stuff
# RUN set -ex \
# 	&& apt-get update \
# 	&& apt-get install -y autoconf automake build-essential tor git libtool libgmp-dev libsqlite3-dev python python3 net-tools zlib1g-dev
# RUN mkdir /opt/lightning

# RUN git clone https://github.com/ElementsProject/lightning.git /opt/lightning
# WORKDIR /opt/lightning
# RUN ./configure
# RUN make

COPY ./torrc /etc/tor/torrc

# entrypoint stuff
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]