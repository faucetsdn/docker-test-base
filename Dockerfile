## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM ubuntu:21.04

ENV OVSV="v2.14.0"
ENV MININETV="2.3.0d6"

ENV AG="apt-get -qqy --no-install-recommends -o=Dpkg::Use-Pty=0"
ENV SETUPQ="setup.py -q easy_install --always-unzip ."
ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_DIR="/var/tmp/build"
ENV BUILD_DEPS="devscripts software-properties-common"
ENV PATH="/venv/bin:$PATH"

COPY bin/setup.sh /
COPY bin/setupproxy.sh /
COPY bin/dind.sh /
COPY etc/init.d/docker /docker.init.d

RUN mkdir -p ${BUILD_DIR} \
    && mv /setup.sh /setupproxy.sh /dind.sh /docker.init.d "${BUILD_DIR}" \
    && ${BUILD_DIR}/setupproxy.sh \
    && sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && ${AG} update \
    && ${AG} upgrade \
    && ${AG} install \
           apt-transport-https \
           bc \
           bridge-utils \
           ca-certificates \
           curl \
           dnsmasq \
           dsniff \
           ebtables \
           equivs \
           freeradius \
           fping \
           git \
           gnupg \
           iperf \
           iperf3 \
           iputils-ping \
           iproute2 \
           isc-dhcp-client \
           kmod \
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
    && python3 -m venv /venv \
# Install Open vSwitch/Mininet
    && mk-build-deps openvswitch -i -r -t "${AG}" \
    && ${BUILD_DIR}/setup.sh \
# Install docker in docker...
    && ${BUILD_DIR}/dind.sh \
# Upgrade git for github actions
    && add-apt-repository -y ppa:git-core/ppa \
    && ${AG} install git \
# Cleanup
    && ${AG} purge openvswitch-build-deps ${BUILD_DEPS} \
    && ${AG} autoremove --purge \
    && ${AG} clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf "${BUILD_DIR}"
