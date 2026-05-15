```markdown
---
title: Ansible Role for Packer Installation
original_path: roles/bootstrap_packer/README.md
category: Ansible Roles
tags: [ansible, packer, automation]
---

# Ansible Role: Packer

[![CI](https://github.com/geerlingguy/ansible-role-packer/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-packer/actions?query=workflow%3ACI)

This role installs [Packer](https://www.packer.io), a Go-based tool for creating identical machine images for multiple platforms from a single source configuration.

## Requirements

- None.

## Role Variables

The following variables are available, along with their default values (see `defaults/main.yml`):

- **bootstrap_packer__version**: `"1.0.0"`
  - The version of Packer to install.
  
- **bootstrap_packer__arch**: `"amd64"`
  - The system architecture to use (e.g., `386`, `amd64`).

- **bootstrap_packer__bin_path**: `/usr/local/bin`
  - The directory where the Packer binary will be installed. This path should be included in the system's `$PATH`.

## Dependencies

- None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - bootstrap_packer
```

## Reference

- [GitHub Repository](https://github.com/geerlingguy/ansible-role-packer)

## Backlinks

- [Ansible Roles Collection](../README.md)
```

This improved Markdown document includes a structured layout with clear headings, proper formatting for role variables, and additional YAML frontmatter for better categorization and searchability. The "Backlinks" section provides a reference to the parent documentation or collection if applicable.