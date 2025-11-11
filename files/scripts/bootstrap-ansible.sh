#!/usr/bin/env bash

OS-RELEASE=$(cat /etc/os-release | grep -i ^name=)

if [[ $string = *"Centos"* ]]; then
    sudo yum ansible.noarch
elif [[ $string = *"Ubuntu"* ]]; then
    sudo apt-get install ansible
fi
