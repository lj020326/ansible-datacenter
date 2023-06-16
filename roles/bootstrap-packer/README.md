# Ansible Role: Packer

[![CI](https://github.com/geerlingguy/ansible-role-packer/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-packer/actions?query=workflow%3ACI)

Installs [Packer](https://www.packer.io), a Go-based image and box builder.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_packer__version: "1.0.0"

The Packer version to install.

    bootstrap_packer__arch: "amd64"

The system architecture (e.g. `386` or `amd64`) to use.

    bootstrap_packer__bin_path: /usr/local/bin

The location where the Packer binary will be installed (should be in system `$PATH`).

## Dependencies

None.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - bootstrap-packer

```

## Reference

- https://github.com/geerlingguy/ansible-role-packer
- 