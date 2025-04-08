#!/bin/bash -eu

cd ..

MOLECULE_IMAGE_LABELS="ubuntu22 ubuntu20 ubuntu18 centos7 centos8 debian9 debian10"

for MOLECULE_IMAGE_LABEL in $MOLECULE_IMAGE_LABELS; do
  echo "*** $MOLECULE_IMAGE_LABEL"
  export MOLECULE_IMAGE_LABEL
  molecule test
done

MOLECULE_IMAGE_LABEL="centos7"
MOLECULE_DOCKER_COMMAND="/usr/lib/systemd/systemd"

echo "*** $MOLECULE_IMAGE_LABEL"
export MOLECULE_IMAGE_LABEL MOLECULE_DOCKER_COMMAND
molecule test
