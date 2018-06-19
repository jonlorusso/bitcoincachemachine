FROM ubuntu:bionic

ENV LIGHTNINGD_VERSION=master

RUN apt-get update
RUN apt-get install -y autoconf automake build-essential tor git libtool libgmp-dev libsqlite3-dev python python3 net-tools zlib1g-dev
RUN mkdir /opt/lightning

RUN git clone https://github.com/ElementsProject/lightning.git /opt/lightning
WORKDIR /opt/lightning
RUN ./configure
RUN make

COPY ./torrc /etc/tor/torrc