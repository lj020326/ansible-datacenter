vmware-esxi-hostconfig
=========

Manage ESXi node settings, including hostname, DNS and NTP settings.

Requirements
------------

pyvmomi

Role Variables
--------------

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

Dependencies
------------

An Ansible Vault file must exist and include the following variables:

```yaml
vault_esxi_username: 'root'
vault_esxi_password: 'password'
```

Example Playbook
----------------

```yaml
---
- hosts: all
  connection: local
  gather_facts: false
  
  roles:
    - vmware-esxi-hostconfig
```
