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
    sed -i -e "s/ ${i} / /g" util/install.sh
done
PYTHON=/venv/bin/python util/install.sh -n
cp util/m /usr/bin/
