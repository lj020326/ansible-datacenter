```markdown
---
title: Bootstrap VMware ESXi Host Configuration Role
original_path: roles/bootstrap_vmware_esxi_hostconfig/README.md
category: Ansible Roles
tags: [vmware, esxi, ansible]
---

# Bootstrap VMware ESXi Host Configuration Role

## Overview

This role is designed to manage ESXi node settings, including hostname, DNS, and NTP configurations.

## Requirements

- `pyvmomi`

## Role Variables

```yaml
esxi_username: '{{ vault_esxi_username }}'
esxi_password: '{{ vault_esxi_password }}'
ntp_state: present

dns_servers:
  - 8.8.8.8
  - 8.8.4.4

ntp_servers:
  - 132.163.96.5
  - 132.163.97.5

change_hostname: false
```

## Dependencies

An Ansible Vault file must exist and include the following variables:

```yaml
vault_esxi_username: 'root'
vault_esxi_password: 'password'
```

## Example Playbook

```yaml
---
- name: Run bootstrap_vmware_esxi_hostconfig
  hosts: all
  connection: local
  gather_facts: false
  
  roles:
    - role: bootstrap_vmware_esxi_hostconfig
```

## Backlinks

- [Ansible Roles Documentation](/docs/ansible-roles)
- [VMware ESXi Configuration Guide](/guides/vmware-esxi-config)

```
```