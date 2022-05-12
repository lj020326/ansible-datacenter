# Ansible Role: Veeam Agent

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
