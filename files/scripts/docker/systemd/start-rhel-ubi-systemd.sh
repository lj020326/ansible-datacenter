#!/usr/bin/env bash

DOCKER_CONTAINER_NAME=systemd-rhel-ubi8
DOCKER_NAMESPACE=registry.access.redhat.com/ubi8
DOCKER_IMAGE=${DOCKER_NAMESPACE}/ubi-init:latest
DOCKER_CMD=/usr/sbin/init

## ref: https://github.com/j8r/dockerfiles
docker run \
  --rm \
  --name ${DOCKER_CONTAINER_NAME} \
  --privileged \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
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
