## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM ubuntu:18.04

ENV OVSV="v2.13.1"
ENV MININETV="2.3.0d6"

ENV AG="apt-get -qqy --no-install-recommends -o=Dpkg::Use-Pty=0"
ENV SETUPQ="setup.py -q easy_install --always-unzip ."
ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_DIR="/var/tmp/build"
ENV BUILD_DEPS="devscripts"

COPY setup.sh /
COPY setupproxy.sh /

RUN /setupproxy.sh \
    && sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && ${AG} update \
    && ${AG} install \
           apt-transport-https \
           bc \
           bridge-utils \
           ca-certificates \
           curl \
           dsniff \
           ebtables \
           equivs \
           freeradius \
           fping \
           git \
           gnupg \
           iperf3 \
           iputils-ping \
           iproute2 \
           isc-dhcp-client \
           ladvd \
           locales \
           libpython3-dev \
           librsvg2-bin \
           libyaml-dev \
           lsb-release \
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
           sudo \
           tcpdump \
           tshark \
           vlan \
           wget \
           wpasupplicant \
           ${BUILD_DEPS} \
# Install Open vSwitch/Mininet
    && mk-build-deps openvswitch -i -r -t "${AG}" \
    && /setup.sh \
# Install docker in docker...
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && ${AG} update \
    && ${AG} install docker-ce \
# Cleanup
    && ${AG} purge openvswitch-build-deps ${BUILD_DEPS} \
    && ${AG} autoremove --purge \
    && ${AG} clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf "${BUILD_DIR}"
