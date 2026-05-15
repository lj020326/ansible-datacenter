```markdown
---
title: Ansible Role for NFS
original_path: roles/bootstrap_nfs/README.md
category: Ansible Roles
tags: [ansible, nfs, redhat, centos, debian, ubuntu]
---

# Ansible Role: NFS

[![CI](https://github.com/geerlingguy/ansible-role-nfs/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-nfs/actions?query=workflow%3ACI)

This role installs NFS utilities on RedHat/CentOS or Debian/Ubuntu systems.

## Requirements

- None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

- **bootstrap_nfs__exports**: A list of exports which will be placed in the `/etc/exports` file. Refer to Ubuntu's [Network File System (NFS) guide](https://ubuntu.com/server/docs/service-nfs) for more information and examples.
  - *Default*: `[]`
  - *Example*: `bootstrap_nfs__exports: [ "/home/public    *(rw,sync,no_root_squash)" ]`

- **bootstrap_nfs__rpcbind_state**: (RedHat/CentOS/Fedora only) The state of the `rpcbind` service.
  - *Default*: `started`
  
- **bootstrap_nfs__rpcbind_enabled**: (RedHat/CentOS/Fedora only) Whether the `rpcbind` service should be enabled at system boot.
  - *Default*: `true`

## Dependencies

- None.

## Example Playbook

```yaml
- hosts: db-servers
  roles:
    - { role: geerlingguy.nfs }
```

## License

This role is licensed under the MIT / BSD license.

## Author Information

This role was created in 2014 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).

## Backlinks

- [Ansible Roles Collection](../README.md)
```

This improved version maintains the original content while adhering to clean, professional Markdown formatting and structure suitable for GitHub rendering.