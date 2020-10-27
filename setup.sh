#!/bin/bash

set -euo pipefail

echo "will cite" | parallel --citation

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
sed -i -e "s/setup.py install/${SETUPQ}/g" Makefile
sed -i -e "s/apt-get/${AG}/g" util/install.sh
for i in ssh pep8 pyflakes python-pexpect pylint xterm ; do
    sed -i -e "s/${i}//g" util/install.sh
done
util/install.sh -n
pip3 install -q .
cp util/m /usr/bin/
