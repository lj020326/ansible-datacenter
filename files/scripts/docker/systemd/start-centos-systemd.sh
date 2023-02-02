#!/usr/bin/env bash

DOCKER_CONTAINER_NAME=systemd-centos8
#DOCKER_NAMESPACE=media.johnson.int:5000
DOCKER_NAMESPACE=lj020326
DOCKER_IMAGE=${DOCKER_NAMESPACE}/centos8-systemd-python:latest
#DOCKER_CMD=/usr/sbin/init
DOCKER_CMD=/sbin/init

## ref: https://github.com/j8r/dockerfiles
docker run \
  --rm \
  --name ${DOCKER_CONTAINER_NAME} \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --tmpfs /run \
  --tmpfs /tmp \
  -d \
  ${DOCKER_IMAGE}
#  ${DOCKER_IMAGE} ${DOCKER_CMD}

echo "wait for container to start"
sleep 3

SYSTEMD_CHECK_CMD="systemctl is-system-running"
echo "${SYSTEMD_CHECK_CMD}"
SYSTEMD_STATUS=$(docker exec ${DOCKER_CONTAINER_NAME} ${SYSTEMD_CHECK_CMD})
echo "SYSTEMD_STATUS=${SYSTEMD_STATUS}"
