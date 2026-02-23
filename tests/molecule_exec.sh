#!/usr/bin/env bash

MOLECULE_IMAGE="${1:-systemd-python-centos:10}"
#MOLECULE_ACTION="${2:-converge}"

shift 1
if [ $# -lt 1 ]; then
  MOLECULE_ACTION="converge"
else
  MOLECULE_ACTION=$@
fi

echo "MOLECULE_ACTION=${MOLECULE_ACTION}"
echo "MOLECULE_IMAGE=${MOLECULE_IMAGE}"

#MOLECULE_DOCKER_COMMAND="${5:-/usr/lib/systemd/systemd}"
#MOLECULE_DOCKER_COMMAND="${5:-/sbin/init}"
#MOLECULE_DOCKER_COMMAND="${5:-/usr/sbin/init}"

#echo "Reset the molecule env in case residue left from prior run"
#molecule reset

#MOLECULE_ARGS="--debug"
#MOLECULE_CMD="molecule reset && MOLECULE_IMAGE=${MOLECULE_IMAGE=} molecule ${MOLECULE_ACTION}"
MOLECULE_CMD="MOLECULE_IMAGE=${MOLECULE_IMAGE=} molecule ${MOLECULE_ACTION}"

echo "${MOLECULE_CMD}"
eval "${MOLECULE_CMD}"
