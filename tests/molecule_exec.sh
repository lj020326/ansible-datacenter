#!/usr/bin/env bash

MOLECULE_IMAGE="${1:-systemd-python-centos:10}"

shift 1
MOLECULE_ARGS=("converge")
if [ $# -gt 0 ]; then
    MOLECULE_ARGS=("$@")
fi

echo "MOLECULE_ARGS=${MOLECULE_ARGS[*]}"
echo "MOLECULE_IMAGE=${MOLECULE_IMAGE}"

#MOLECULE_DOCKER_COMMAND="${5:-/usr/lib/systemd/systemd}"
#MOLECULE_DOCKER_COMMAND="${5:-/sbin/init}"
#MOLECULE_DOCKER_COMMAND="${5:-/usr/sbin/init}"

#echo "Reset the molecule env in case residue left from prior run"
#molecule reset

#MOLECULE_ARGS="--debug"
#MOLECULE_CMD="molecule reset && MOLECULE_IMAGE=${MOLECULE_IMAGE=} molecule ${MOLECULE_ARGS}"
MOLECULE_CMD="MOLECULE_IMAGE=${MOLECULE_IMAGE=} molecule ${MOLECULE_ARGS[*]}"

echo "${MOLECULE_CMD}"
eval "${MOLECULE_CMD}"
