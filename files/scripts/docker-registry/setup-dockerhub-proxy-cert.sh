#!/usr/bin/env bash

#############
## ref: https://github.com/moby/moby/issues/39869#issuecomment-967376507
#############
set -e

DOCKER_REGISTRY_HOST="registry.docker.io"
DOCKER_AUTH_URL="https://auth.docker.io"

DOCKER_REGISTRY_CERT_DIR="/etc/docker/certs.d/${DOCKER_REGISTRY_HOST}:443"

SCRIPT_DIR="$(dirname "$0")"
source ${SCRIPT_DIR}/get-curl-ca-opts.sh

echo "==> UNAME=${UNAME}: PLATFORM=[${PLATFORM}] DISTRO=[${DISTRO}]"

echo "==> Setup docker registry cert dir at "
mkdir "${DOCKER_REGISTRY_CERT_DIR}"

echo "==> Setup symlink for docker registry cert to system ca cert bundle"
#ln -s /etc/ssl/certs/ca-certificates.crt ${DOCKER_REGISTRY_CERT_DIR}/ca.crt
ln -s ${CACERT_BUNDLE} ${DOCKER_REGISTRY_CERT_DIR}/ca.crt
