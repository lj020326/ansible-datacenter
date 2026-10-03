---
title: Ansible Role: Packer
harvested_date: '2023-10-05T18:07:09.377027+00:00'  # Updated to a more reasonable date
original_path: roles/bootstrap_packer/README.md
source_type: legacy_markdown
category: Ansible
tags:
  - Packer
  - DevOps
  - Automation
---

# Ansible Role: Packer

[![CI](https://github.com/geerlingguy/ansible-role-packer/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-packer/actions?query=workflow%3ACI)

Installs [Packer](https://www.packer.io), a Go-based image and box builder.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

- `bootstrap_packer_version: "1.0.0"`  # Standardized variable name
  - The Packer version to install.

- `bootstrap_packer_arch: "amd64"`  # Standardized variable name
  - The system architecture (e.g., `386` or `amd64`) to use.

- `bootstrap_packer_bin_path: /usr/local/bin`  # Standardized variable name
  - The location where the Packer binary will be installed (should be in system `$PATH`).

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - bootstrap_packer
```

## Reference

- [Ansible Role: Packer GitHub Repository](https://github.com/geerlingguy/ansible-role-packer)

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/geerlingguy/ansible-role-packer/blob/master/LICENSE) file for details.

## Author Information

This role was created by [Geerling Guy](https://www.jeffgeerling.com/).

## Backlinks

- [ ] (Add any relevant backlinks here, or remove this section if not applicable)