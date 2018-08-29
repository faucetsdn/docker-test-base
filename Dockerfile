## Image name: faucet/test-base
## Base image for FAUCET tests.

FROM ubuntu:16.04

ENV OVSV="v2.9.2"
ENV DPDK="18.02.2"
ENV MININETV="2.3.0d4   "

ENV OVSDEPS="autoconf automake libpcap-dev libcap-ng-dev libnuma-dev libtool libssl-dev linux-headers-generic libffi-dev"
ENV AG="apt-get -qqy --no-install-recommends -o=Dpkg::Use-Pty=0"
ENV DEBIAN_FRONTEND=noninteractive
# Pre-install Ryu and basic dependencies - so test image has less work
ENV PIPDEPS="setuptools wheel virtualenv"
ENV PIP3="pip3 -q --no-cache-dir install --upgrade"
ENV SETUPQ="setup.py -q easy_install --always-unzip ."
ENV MAKEFLAGS="-s"
ENV BUILDDIR="/var/tmp/build"
ENV DPDK_TARGET=x86_64-native-linuxapp-gcc

###
### When apt-get'ing, make sure apt-update always run first per RUN
### to ensure Docker layer cache doesn't use a stale apt database.
###

COPY setupproxy.sh /

RUN \
  ./setupproxy.sh && \
  $AG update && \
  $AG install \
    $OVSDEPS \
    apt-transport-https \
    bc \
    bridge-utils \
    build-essential \
    curl \
    dsniff \
    freeradius \
    fping \
    gcc \
    git \
    iperf \
    iputils-ping \
    iproute2 \
    ladvd \
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
    openvswitch-common \
    parallel \
    patch \
    psmisc \
    python3-pip \
    software-properties-common \
    sudo \
    tcpdump \
    tshark \
    vlan \
    wget \
    wpasupplicant && \
  $AG install linux-headers-`uname -r` && \
  git config --global url.https://github.com/.insteadOf git://github.com/ && \
    mkdir -p $BUILDDIR && \
    cd $BUILDDIR && \
    wget -q -O- http://fast.dpdk.org/rel/dpdk-$DPDK.tar.xz | tar -Jxf- && \
      cd dpdk* && \
      make install T=$DPDK_TARGET DESTDIR=install && \
    cd .. && \
    git clone https://github.com/openvswitch/ovs -b ${OVSV} && \
      cd ovs && \
      ./boot.sh && \
      ./configure --enable-silent-rules --quiet --with-dpdk=`echo ../dpdk*/$DPDK_TARGET` && \
      make install && \
    cd .. && \
    git clone https://github.com/mininet/mininet && \
      cd mininet && \
      git checkout -b mininet-$mininetv $mininetv && \
      perl -pi -e "s/setup.py install/${SETUPQ}/g" Makefile && \
      perl -pi -e "s/apt-get/${AG}/g" util/install.sh && \
      for i in ssh pep8 pyflakes python-pexpect pylint xterm ; do \
          perl -pi -e "s/${i}//g" util/install.sh ; done && \
      PYTHON=python3 util/install.sh -n && \
    cd .. && \
  cd / && rm -rf $BUILDDIR && \
  $AG purge $OVSDEPS linux-headers-`uname -r` && \
  $AG autoremove

RUN \
  ./setupproxy.sh && \
  $AG update && \
  $AG install cython3 && \
  $AG purge pylint && \
  $PIP3 scapy $PIPDEPS && \
  $PIP3 ryu

# Install docker in docker...
RUN ./setupproxy.sh && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    $AG update && $AG install docker-ce
