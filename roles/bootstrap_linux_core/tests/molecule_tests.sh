#!/bin/bash -eu

cd ..

MOLECULE_IMAGE_LIST="ubuntu:22.04 ubuntu:24.04 centos:10 centos:9 debian:10 debian:12"

for MOLECULE_IMAGE in $MOLECULE_IMAGE_LIST; do
  echo "*** $MOLECULE_IMAGE"
  export MOLECULE_IMAGE
  molecule test
done

MOLECULE_IMAGE="centos:10"
MOLECULE_DOCKER_COMMAND="/usr/lib/systemd/systemd"

echo "*** $MOLECULE_IMAGE"
export MOLECULE_IMAGE MOLECULE_DOCKER_COMMAND
molecule test
