#!/bin/bash

set -euo pipefail

git config --global url.https://github.com/.insteadOf git://github.com/

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

git clone https://github.com/openvswitch/ovs
cd ovs || exit 1
git checkout -b "${OVSV}" "${OVSV}"
./boot.sh
./configure --enable-silent-rules --quiet
make -j4 install

cd "${BUILD_DIR}" || exit 1
git clone https://github.com/mininet/mininet
cd mininet || exit 1
git checkout -b "mininet-${MININETV}" "${MININETV}"
for i in ssh pep8 pyflakes3 python-pexpect pylint xterm ; do
    sed -i -r "/^\s*#/!s/\s+${i}(\s+|\$)/ /g" util/install.sh
done
sed -i -e "s/\$pf/pyflakes3/g" util/install.sh
PYTHON=/venv/bin/python util/install.sh -n
cp util/m /usr/bin/

# workaround python3.9 support for scapy 2.4.4
# https://github.com/secdev/scapy/issues/3100
for libc in /usr/lib/*-linux-*/libc.a; do
    libc_dir=$(dirname "${libc}")
    ln -s "${libc}" "${libc_dir}/liblibc.a"
done
