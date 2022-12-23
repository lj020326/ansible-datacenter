[![Build Status](https://travis-ci.org/appuio/ansible-ini2yaml.svg?branch=master)](https://travis-ci.org/appuio/ansible-ini2yaml)

Ansible INI to YAML inventory converter
=======================================

This repository contains a Python script for converting Ansible inventories in INI format to YAML format.

Usage
-----

The script is implemented as a filter:

    python ini2yaml.py < hosts.ini > hosts.yml
    ## OR
    ini2yaml.py < inventory.ini > inventory.yml

Ansible 2.4.1 or later automatically recognizes the inventory format so the `.yaml` file extension can be omitted, also allowing the default `/etc/ansible/hosts` inventory to be in YAML format.

Dependencies
------------

Install dependencies:

    pip install -r requirement.txt

