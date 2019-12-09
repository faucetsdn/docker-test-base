## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM ubuntu:18.04

ENV OVSV="v2.12.0"
ENV MININETV="2.3.0d6"

ENV AG="apt-get -qqy --no-install-recommends -o=Dpkg::Use-Pty=0"
ENV DEBIAN_FRONTEND=noninteractive
ENV SETUPQ="setup.py -q easy_install --always-unzip ."
ENV BUILDDIR="/var/tmp/build"

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
    isc-dhcp-client \
    ladvd \
    locales \
    libpython3-dev \
    librsvg2-bin \
    libyaml-dev \
    lsof \
    netcat \
    ndisc6 \
    net-tools \
    netcat-openbsd \
    nmap \
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

# Install Open vSwitch/Mininet
RUN mk-build-deps openvswitch -i -r -t "$AG" && \
    /setup.sh

# Install docker in docker...
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    $AG update && \
    $AG install docker-ce

# Cleanup
RUN $AG purge openvswitch-build-deps && \
    $AG autoremove --purge && \
    $AG clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf $BUILDDIR
