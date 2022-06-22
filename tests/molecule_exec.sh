#!/usr/bin/env bash

export MOLECULE_ACTION="${1:-converge}"
export MOLECULE_DISTRO="${2:-centos7}"
export MOLECULE_DOCKER_COMMAND="${3:-}"

echo "MOLECULE_ACTION=${MOLECULE_ACTION}"
echo "MOLECULE_DISTRO=${MOLECULE_DISTRO}"
echo "MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND}"
#export MOLECULE_DOCKER_COMMAND="/usr/lib/systemd/systemd"
#export MOLECULE_DOCKER_COMMAND="/usr/sbin/init"

MOLECULE_CMD="molecule ${MOLECULE_ACTION}"

echo "${MOLECULE_CMD}"
eval "${MOLECULE_CMD}"
