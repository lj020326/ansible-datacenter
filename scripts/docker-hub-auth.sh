#!/usr/bin/env bash

## ref: https://github.com/docker/distribution/issues/1968
## ref: https://gist.github.com/alexanderilyin/8cf68f85b922a7f1757ae3a74640d48a

set -euxo pipefail

DOCKER_HUB_ORG="***"
DOCKER_HUB_REPO="***"
DOCKER_HUB_USER="***"
DOCKER_HUB_PASSWORD="***"

AUTH_DOMAIN="auth.docker.io"
AUTH_SERVICE="registry.docker.io"
AUTH_SCOPE="repository:${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}:pull"
AUTH_OFFLINE_TOKEN="1"
AUTH_CLIENT_ID="shell"

API_DOMAIN="registry-1.docker.io"

TOKEN=$(curl -v -X GET -u ${DOCKER_HUB_USER}:${DOCKER_HUB_PASSWORD} "https://${AUTH_DOMAIN}/token?service=${AUTH_SERVICE}&scope=${AUTH_SCOPE}&offline_token=${AUTH_OFFLINE_TOKEN}&client_id=${AUTH_CLIENT_ID}" | jq -r '.token')
VERSIONS=$(curl -v -H "Authorization: Bearer ${TOKEN}" https://${API_DOMAIN}/v2/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/tags/list | jq -r '.tags[]' | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | sort --version-sort)
VERSION_OLD_FULL_RAW=$(echo "${VERSIONS}" | tail -n 1)

echo ${VERSION_OLD_FULL_RAW}

VERSION_OLD_FULL_CLEAN=$(echo ${VERSION_OLD_FULL_RAW} | tr -d v)

VERSION_OLD_MAJOR=$(echo ${VERSION_OLD_FULL_CLEAN} | awk -F . '{print $1}' )
VERSION_OLD_MINOR=$(echo ${VERSION_OLD_FULL_CLEAN} | awk -F . '{print $2}' )
VERSION_OLD_PATCH=$(echo ${VERSION_OLD_FULL_CLEAN} | awk -F . '{print $3}' )

VERSION_NEW_MAJOR=${VERSION_OLD_MAJOR}
VERSION_NEW_MINOR=$((${VERSION_OLD_MINOR}+1))
VERSION_NEW_PATCH=0

VERSION_NEW_FULL_RAW="v${VERSION_NEW_MAJOR}.${VERSION_NEW_MINOR}.${VERSION_NEW_PATCH}"

echo ${VERSION_NEW_FULL_RAW}
