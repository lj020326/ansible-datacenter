# Ansible Role: Veeam Agent

[![Build Status](https://travis-ci.org/sbaerlocher/ansible.veeam-agent.svg?branch=master)](https://travis-ci.org/sbaerlocher/ansible.veeam-agent) [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://sbaerlo.ch/licence) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-veeam--agent-blue.svg)](https://galaxy.ansible.com/sbaerlocher/veeam-agent)

## Description

Install and Configure Veeam Agent for linux on Debian and CentOS.

## Installation

```bash
ansible-galaxy install sbaerlocher.veeam-agent
```

## Requirements

None

## Role Variables

```yml
veeam:
  vbrserver:
    name:
    endpoint:
    login:
    domain:
    password:
  repo:
    name:
    path:
  job:
    name:
    restopoints:
    day:
    at:
```

## Dependencies

None

## Example Playbook

```yml
- hosts: all
  roles:
     - sbaerlocher.veeam-agent
```

## Changelog

### 1.1.0

* update new syntax

### 1.0.0

* initial release

## Author

* [Simon Bärlocher](https://sbaerlocher.ch)

## License

This project is under the MIT License. See the [LICENSE](https://sbaerlo.ch/licence) file for the full license text.

## Copyright

(c) 2018, Simon Bärlocher