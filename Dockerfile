## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM debian:buster

ENV OVSV="v2.16.2"
ENV MININETV="2.3.0"

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
    && cat /usr/share/doc/apt/examples/sources.list | sed -e 's/#deb-src/deb-src/' > /etc/apt/sources.list \
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
           locales-all \
           libpython3-dev \
           librsvg2-bin \
           libunbound-dev \
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
# Create venv
    && python3 -m venv /venv \
# Install Open vSwitch/Mininet
    && mk-build-deps openvswitch -i -r -t "${AG}" \
    && ${BUILD_DIR}/setup.sh \
# Install docker in docker...
    && ${BUILD_DIR}/dind.sh \
# Cleanup
    && ${AG} purge openvswitch-build-deps ${BUILD_DEPS} \
    && ${AG} autoremove --purge \
    && ${AG} clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf "${BUILD_DIR}"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
