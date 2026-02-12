#!/bin/bash -eu

MOLECULE_IMAGE_LIST="centos:10 centos:9"

for MOLECULE_IMAGE_LABEL in $MOLECULE_IMAGE_LIST; do
  echo "*** $MOLECULE_IMAGE"
  export MOLECULE_IMAGE_LABEL
  molecule test
done
