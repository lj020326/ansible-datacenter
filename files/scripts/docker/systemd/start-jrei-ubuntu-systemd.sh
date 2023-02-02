#!/usr/bin/env bash

DOCKER_CONTAINER_NAME=systemd-ubuntu
#DOCKER_NAMESPACE=media.johnson.int:5000
DOCKER_NAMESPACE=jrei
DOCKER_IMAGE=${DOCKER_NAMESPACE}/systemd-ubuntu:22.04:latest
DOCKER_CMD=/lib/systemd/systemd

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
  ${DOCKER_IMAGE}
#  ${DOCKER_IMAGE} ${DOCKER_CMD}

SYSTEMD_CHECK_CMD="systemctl is-system-running"
echo "${SYSTEMD_CHECK_CMD}"
docker exec "${DOCKER_CONTAINER_NAME}" "${SYSTEMD_CHECK_CMD}"
