---
title: Bootstrap yq Role Documentation
original_path: roles/bootstrap_yq/README.md
category: Ansible Roles
tags: [ansible, yq, installation]
---

# Bootstrap yq

Installs [Yq](https://www.yq.io), a Go-based YAML processor.

## Requirements

- None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

- **bootstrap_yq__version**: `"4.40.5"`
  - The Yq version to install.
  
- **bootstrap_yq__binary**: `"yq_linux_amd64"`
  - The name of the binary extracted from the archive.

- **bootstrap_yq__bin_path**: `/usr/local/bin`
  - The location where the Yq binary will be installed (should be in system `$PATH`).

## Dependencies

- None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - bootstrap_yq
```

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
- [Yq Official Website](https://www.yq.io)

---

This documentation provides a clear and structured overview of the `bootstrap_yq` Ansible role, ensuring it is rendered effectively on GitHub.