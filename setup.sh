#!/bin/bash

python3 -m venv /venv
source /venv/bin/activate

git config --global url.https://github.com/.insteadOf git://github.com/

mkdir -p $BUILDDIR

cd $BUILDDIR
git clone https://github.com/openvswitch/ovs -b ${OVSV}
cd ovs
./boot.sh
./configure --enable-silent-rules --quiet
make install

cd $BUILDDIR
git clone https://github.com/mininet/mininet
cd mininet
git checkout -b mininet-$MININETV $MININETV
sed -i -e "s/setup.py install/${SETUPQ}/g" Makefile
sed -i -e "s/apt-get/${AG}/g" util/install.sh
for i in ssh pep8 pyflakes python-pexpect pylint xterm ; do
    sed -i -e "s/${i}//g" util/install.sh
done
PYTHON=/venv/bin/python3 util/install.sh -n
