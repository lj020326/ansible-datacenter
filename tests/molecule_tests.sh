#!/usr/bin/env bash

PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

echo "*** $PROJECT_DIR"
cd ${PROJECT_DIR}

#MOLECULE_IMAGE_LABELS="
#centos7
#centos8
#debian9
#debian10
#fedora35
#fedora36
#ubuntu1804
#ubuntu2004
#ubuntu2204
#"

MOLECULE_IMAGE_LABELS="
centos7
centos8
debian9
debian10
ubuntu1804
ubuntu2004
ubuntu2204
"

IFS=$'\n'
for MOLECULE_IMAGE_LABEL in $MOLECULE_IMAGE_LABELS; do
  echo "*** $MOLECULE_IMAGE_LABEL"
  export MOLECULE_IMAGE_LABEL="${MOLECULE_IMAGE_LABEL}"
  molecule reset
  molecule test --debug --parallel
done

