#!/usr/bin/env bash

export MOLECULE_ACTION="${1:-converge}"

export MOLECULE_DISTRO="${2:-centos7}"

echo "MOLECULE_ACTION=${MOLECULE_ACTION}"
echo "MOLECULE_DISTRO=${MOLECULE_DISTRO}"

#export MOLECULE_DOCKER_COMMAND="${5:-/usr/lib/systemd/systemd}"
#export MOLECULE_DOCKER_COMMAND="${5:-/sbin/init}"
export MOLECULE_DOCKER_COMMAND="${5:-/usr/sbin/init}"

#echo "Reset the molecule env in case residue left from prior run"
#molecule reset

MOLECULE_ARGS=""
#MOLECULE_ARGS="--debug"
MOLECULE_CMD="molecule reset && molecule ${MOLECULE_ARGS} ${MOLECULE_ACTION}"

echo "${MOLECULE_CMD}"
eval "${MOLECULE_CMD}"
