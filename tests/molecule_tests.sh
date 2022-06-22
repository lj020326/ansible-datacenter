#!/usr/bin/env bash

PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

echo "*** $PROJECT_DIR"
cd ${PROJECT_DIR}

#MOLECULE_DISTROS="
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

MOLECULE_DISTROS="
centos7
centos8
debian9
debian10
ubuntu1804
ubuntu2004
ubuntu2204
"


IFS=$'\n'
for MOLECULE_DISTRO in $MOLECULE_DISTROS; do
  echo "*** $MOLECULE_DISTRO"
  export MOLECULE_DISTRO
  molecule test
done

