## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM ubuntu:18.04

# TODO: 2.10.0 disconnects during stacking tests.
ENV OVSV="v2.9.2"
ENV DPDK="18.02.2"
ENV MININETV="2.3.0d4"

ENV AG="apt-get -qqy --no-install-recommends -o=Dpkg::Use-Pty=0"
ENV DEBIAN_FRONTEND=noninteractive
ENV SETUPQ="setup.py -q easy_install --always-unzip ."
ENV BUILDDIR="/var/tmp/build"
ENV DPDK_TARGET=x86_64-native-linuxapp-gcc

COPY setup.sh /
COPY setupproxy.sh /

RUN /setupproxy.sh && \
  sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
  $AG update && \
  $AG install \
    apt-transport-https \
    bc \
    bridge-utils \
    build-essential \
    ca-certificates \
    curl \
    devscripts \
    dsniff \
    ebtables \
    equivs \
    freeradius \
    fping \
    git \
    gnupg-agent \
    iperf \
    iputils-ping \
    iproute2 \
    ladvd \
    linux-headers-`uname -r` \
    locales \
    libnuma-dev \
    libpython3-dev \
    libyaml-dev \
    lsof \
    netcat \
    ndisc6 \
    net-tools \
    netcat-openbsd \
    nmap \
    numactl \
    parallel \
    patch \
    psmisc \
    python3-pip \
    python3-venv \
    software-properties-common \
    sudo \
    tcpdump \
    tshark \
    vlan \
    wget \
    wpasupplicant

# Install DPDK/Open vSwitch/Mininet
RUN mk-build-deps dpdk -i -r -t "$AG" && \
    mk-build-deps openvswitch -i -r -t "$AG" && \
    /setup.sh

# Install docker in docker...
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    $AG update && \
    $AG install docker-ce

# Cleanup
RUN $AG purge linux-headers-`uname -r` dpdk-build-deps openvswitch-build-deps && \
    $AG autoremove --purge && \
    $AG clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf $BUILDDIR
