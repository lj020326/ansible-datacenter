#!/usr/bin/env bash

##
## ref: https://success.docker.com/article/how-do-i-authenticate-with-the-v2-api
##
set -e

#DOCKER_REGISTRY_URL=hub.docker.com
DOCKER_REGISTRY_URL=media.johnson.int:5000

# set username and password
DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME:-"testuser"}
DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD:-"testpassword"}

SCRIPT_DIR="$(dirname "$0")"
source ${SCRIPT_DIR}/get-curl-ca-opts.sh

# get token to be able to talk to Docker Hub
TOKEN=$(curl ${CURL_CA_OPTS} -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_REGISTRY_USERNAME}'", "password": "'${DOCKER_REGISTRY_PASSWORD}'"}' https://${DOCKER_REGISTRY_URL}/v2/users/login/ | jq -r .token)

echo "TOKEN=$TOKEN"

# get list of namespaces accessible by user (not in use right now)
#NAMESPACES=$(curl -s -H "Authorization: JWT ${TOKEN}" https://${DOCKER_REGISTRY_URL}/v2/repositories/namespaces/ | jq -r '.namespaces|.[]')

# get list of repos for that user account
REPO_LIST=$(curl ${CURL_CA_OPTS} -s -H "Authorization: JWT ${TOKEN}" https://${DOCKER_REGISTRY_URL}/v2/repositories/${DOCKER_REGISTRY_USERNAME}/?page_size=10000 | jq -r '.results|.[]|.name')

# build a list of all images & tags
for i in ${REPO_LIST}
do
  # get tags for repo
  IMAGE_TAGS=$(curl ${CURL_CA_OPTS} -s -H "Authorization: JWT ${TOKEN}" https://${DOCKER_REGISTRY_URL}/v2/repositories/${DOCKER_REGISTRY_USERNAME}/${i}/tags/?page_size=10000 | jq -r '.results|.[]|.name')

  # build a list of images from tags
  for j in ${IMAGE_TAGS}
  do
    # add each tag to list
    FULL_IMAGE_LIST="${FULL_IMAGE_LIST} ${DOCKER_REGISTRY_USERNAME}/${i}:${j}"
  done
done

# output list of all docker images
for i in ${FULL_IMAGE_LIST}
do
  echo ${i}
done
