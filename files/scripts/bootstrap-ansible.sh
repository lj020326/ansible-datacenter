#!/usr/bin/env bash

UNAME=$(uname -s | tr "[:upper:]" "[:lower:]")

case "${UNAME}" in
    linux*)
        OS_RELEASE="$(grep -i '^name=' /etc/os-release)"

        if [[ "$OS_RELEASE" == *"Centos"* ]]; then
            sudo yum install -y ansible.noarch
        elif [[ "$OS_RELEASE" == *"Ubuntu"* ]]; then
            sudo apt-get install -y ansible
        fi
        ;;
    darwin*)
        python3 -m pip install --upgrade pip
        python3 -m pip install ansible
        ;;
    cygwin* | mingw64* | mingw32* | msys*)
        python3 -m pip install --upgrade pip
        python3 -m pip install ansible
        ;;
    *)
        echo "Unsupported operating system: ${UNAME}" >&2
        exit 1
        ;;
esac
