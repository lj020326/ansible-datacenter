#!/bin/bash -eu

cd ..

MOLECULE_DISTROS="ubuntu22 ubuntu20 ubuntu18 centos7 centos8 debian9 debian10"

for MOLECULE_DISTRO in $MOLECULE_DISTROS; do
  echo "*** $MOLECULE_DISTRO"
  export MOLECULE_DISTRO
  molecule test
done

MOLECULE_DISTRO="centos7"
MOLECULE_DOCKER_COMMAND="/usr/lib/systemd/systemd"

echo "*** $MOLECULE_DISTRO"
export MOLECULE_DISTRO MOLECULE_DOCKER_COMMAND
molecule test
