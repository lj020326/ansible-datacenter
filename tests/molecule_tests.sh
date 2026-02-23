#!/usr/bin/env bash

PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

echo "*** $PROJECT_DIR"
cd "${PROJECT_DIR}" || exit

#MOLECULE_IMAGE_LIST="
#systemd-python-centos:9
#systemd-python-centos:10
#systemd-python-redhat:9
#systemd-python-redhat:10
#systemd-python-debian:10
#systemd-python-debian:11
#systemd-python-debian:12
#systemd-python-fedora:latest
#systemd-python-ubuntu:22.04
#systemd-python-ubuntu:24.04
#"

MOLECULE_IMAGE_LIST="
systemd-python-centos:9
systemd-python-centos:10
systemd-python-debian:12
systemd-python-ubuntu:22.04
systemd-python-ubuntu:24.04
"

IFS=$'\n'
for MOLECULE_IMAGE in $MOLECULE_IMAGE_LIST; do
  echo "*** MOLECULE_IMAGE=${MOLECULE_IMAGE}"
  MOLECULE_IMAGE="${MOLECULE_IMAGE}"
  "MOLECULE_IMAGE=${MOLECULE_IMAGE} molecule reset"
#  "MOLECULE_IMAGE=${MOLECULE_IMAGE} molecule test --debug --parallel"
  "MOLECULE_IMAGE=${MOLECULE_IMAGE} molecule test"
done
