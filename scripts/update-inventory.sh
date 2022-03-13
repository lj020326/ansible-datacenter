#!/usr/bin/env bash

## ref: https://itnext.io/create-a-host-inventory-in-a-minute-with-ansible-c7bf251166d9
ansible -i hosts -m setup --tree out/ all
tree out

ansible-cmdb -t html_fancy_split -p local_js=1 out/
