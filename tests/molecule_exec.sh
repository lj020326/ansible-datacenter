#!/usr/bin/env bash

export MOLECULE_DISTRO="${1:-centos7}"
#export MOLECULE_ACTION="${2:-converge}"

shift 1
if [ $# -lt 1 ]; then
  export MOLECULE_ACTION="converge"
else
  export MOLECULE_ACTION=$@
fi

echo "MOLECULE_ACTION=${MOLECULE_ACTION}"
echo "MOLECULE_DISTRO=${MOLECULE_DISTRO}"

#export MOLECULE_DOCKER_COMMAND="${5:-/usr/lib/systemd/systemd}"
#export MOLECULE_DOCKER_COMMAND="${5:-/sbin/init}"
export MOLECULE_DOCKER_COMMAND="${5:-/usr/sbin/init}"

#echo "Reset the molecule env in case residue left from prior run"
#molecule reset

#MOLECULE_ARGS="--debug"
MOLECULE_CMD="molecule reset && molecule ${MOLECULE_ACTION}"

echo "${MOLECULE_CMD}"
eval "${MOLECULE_CMD}"
