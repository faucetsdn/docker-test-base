#!/bin/bash

set -euo pipefail

source /etc/os-release

arch=$(dpkg --print-architecture)

case "${arch}" in
    amd64)
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
        ${AG} update
        ${AG} install docker-ce
        mv "${BUILD_DIR}/docker.init.d" /etc/init.d/docker
    ;;
    i386)
        ${AG} install docker.io
        mv "${BUILD_DIR}/docker.init.d" /etc/init.d/docker
        touch /etc/default/docker
    ;;
esac
