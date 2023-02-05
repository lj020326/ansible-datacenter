#!/usr/bin/env bash

## ref: https://stackoverflow.com/questions/26423515/how-to-automatically-update-your-docker-containers-if-base-images-are-updated

set -e
BASE_IMAGE=${1:-registry}
REGISTRY=${2:-media.johnson.int:5000}
#REGISTRY="registry.hub.docker.com"
IMAGE="${REGISTRY}/${BASE_IMAGE}"
CID=$(docker ps | grep "${IMAGE}" | awk '{print $1}')
docker pull "${IMAGE}"

for im in $CID
do
  LATEST=`docker inspect --format "{{.Id}}" "${IMAGE}"`
  RUNNING=`docker inspect --format "{{.Image}}" $im`
  NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
  echo "Latest: ${LATEST}"
  echo "Running: ${RUNNING}"
  if [ "$RUNNING" != "$LATEST" ];then
    echo "upgrading $NAME"
    docker stop "${NAME}"
    docker rm -f "${NAME}"
    docker start "${NAME}"
  else
    echo "${NAME} up to date"
  fi
done