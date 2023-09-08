#!/usr/bin/env bash

#############
## ref: https://github.com/lj020326/ansible-datacenter/tree/main/docs/docker/how-to-debug-dockerhub-pull-image.md
## ref: https://stackoverflow.com/questions/55269256/how-to-get-manifests-using-http-api-v2
## ref: https://github.com/lj020326/ansible-datacenter/tree/main/docs/docker/how-the-docker-pull-command-works-under-the-covers-with-http-headers-to-illustrate-the-process.md
## ref: https://success.docker.com/article/how-do-i-authenticate-with-the-v2-api
#############
set -e

DOCKER_REGISTRY_SERVICE="registry.docker.io"

DOCKER_REGISTRY_URL="https://index.docker.io/v2"
#DOCKER_REGISTRY_URL="https://registry.hub.docker.com/v2"
#DOCKER_REGISTRY_URL="https://registry.docker.io/v2"
#DOCKER_REGISTRY_URL="https://registry-1.docker.io/v2"
#DOCKER_REGISTRY_URL="https://hub.docker.com/v2"

DOCKER_AUTH_URL="https://auth.docker.io"
DOCKER_SCHEMA="application/vnd.docker.distribution.manifest.v2+json"

REPO_NAMESPACE="lj020326"
IMAGE="docker-jenkins"
IMAGE_TAG="latest"
REPO_IMAGE=${REPO_NAMESPACE}/${IMAGE}

SCRIPT_DIR="$(dirname "$0")"
source ${SCRIPT_DIR}/get-curl-ca-opts.sh

echo "UNAME=${UNAME}: PLATFORM=[${PLATFORM}] DISTRO=[${DISTRO}]"

echo "==> get docker hub token to be able to talk to Docker Hub"
## ref: https://medium.com/google-cloud/adventures-w-docker-manifests-78f255d662ff
TOKEN=$(\
  curl ${CURL_CA_OPTS} \
  --silent \
  --location \
  "${DOCKER_AUTH_URL}/token?service=${DOCKER_REGISTRY_SERVICE}&scope=repository:${REPO_IMAGE}:pull" \
  | jq --raw-output .token\
)

echo "==> TOKEN=${TOKEN}"

echo "==> Get manifest raw output"

curl ${CURL_CA_OPTS} \
  --location \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Accept: ${DOCKER_SCHEMA}" \
  "${DOCKER_REGISTRY_URL}/${REPO_NAMESPACE}/${IMAGE}/manifests/${IMAGE_TAG}" \
  | jq --raw-output

echo "==> Get SHA256 from manifest"
TOKEN=$(\
  curl ${CURL_CA_OPTS} \
  --silent \
  --location \
  "${DOCKER_AUTH_URL}/token?service=${DOCKER_REGISTRY_SERVICE}&scope=repository:${REPO_IMAGE}:pull" \
  | jq --raw-output .token\
)

SHA256SUM=$(curl ${CURL_CA_OPTS} \
  --silent \
  --location \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Accept: ${DOCKER_SCHEMA}" \
  "${DOCKER_REGISTRY_URL}/${REPO_NAMESPACE}/${IMAGE}/manifests/${IMAGE_TAG}" \
  | sha256sum \
  | head --bytes 64)

echo "==> SHA256SUM=${SHA256SUM}"
