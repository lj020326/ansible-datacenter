#!/usr/bin/env bash

DOCKER_CONTAINER_NAME=systemd-ubuntu22
#DOCKER_NAMESPACE=media.johnson.int:5000
DOCKER_NAMESPACE=lj020326
DOCKER_IMAGE=${DOCKER_NAMESPACE}/ubuntu2204-systemd-python:latest
#DOCKER_CMD=/lib/systemd/systemd
DOCKER_CMD=/usr/sbin/init

## ref: https://github.com/j8r/dockerfiles
## ref: https://stackoverflow.com/questions/53383431/how-to-enable-systemd-on-dockerfile-with-ubuntu18-04
docker run \
  --rm \
  --name ${DOCKER_CONTAINER_NAME} \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --tmpfs /run \
  --tmpfs /tmp \
  -d \
  ${DOCKER_IMAGE} ${DOCKER_CMD}
#  ${DOCKER_IMAGE}

echo "wait for container to start"
sleep 3

SYSTEMD_CHECK_CMD="systemctl is-system-running"
echo "${SYSTEMD_CHECK_CMD}"
SYSTEMD_STATUS=$(docker exec ${DOCKER_CONTAINER_NAME} ${SYSTEMD_CHECK_CMD})
echo "SYSTEMD_STATUS=${SYSTEMD_STATUS}"
