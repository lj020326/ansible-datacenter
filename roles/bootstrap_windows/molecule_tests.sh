#!/bin/bash -eu

MOLECULE_IMAGE_LABELS="centos7"

for MOLECULE_IMAGE_LABEL in $MOLECULE_IMAGE_LABELS; do
  echo "*** $MOLECULE_IMAGE_LABEL"
  export MOLECULE_IMAGE_LABEL
  molecule test
done
