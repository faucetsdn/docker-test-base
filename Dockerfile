## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM debian:bookworm

ENV OVSV="v3.6.0"
ENV MININETV="2.3.1b4"

ENV AG="apt-get -y --no-install-recommends -o=Dpkg::Use-Pty=0"
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
    && sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources \
    && ${AG} update \
    && ${AG} upgrade \
    && ${AG} install \
           apt-transport-https \
           bc \
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
           libnuma1 \
           locales \
           locales-all \
           libpython3-dev \
           librsvg2-bin \
           libunbound-dev \
           libxdp1 \
           libyaml-dev \
           lsb-release \
           lsof \
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
           traceroute \
           tshark \
           wget \
           wpasupplicant \
           ${BUILD_DEPS} \
# Configure preferred commands
    && update-alternatives --set traceroute6 /usr/bin/traceroute6.db \
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
RUN ovsdb-tool --help
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
