```markdown
---
title: Ansible Role for EPEL Repository
original_path: roles/bootstrap_epel_repo/README.md
category: Ansible Roles
tags: [ansible, epel, repository, rhel, centos]
---

# Ansible Role: EPEL Repository

[![CI](https://github.com/geerlingguy/ansible-role-repo-epel/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-repo-epel/actions?query=workflow%3ACI)

## Overview

This Ansible role installs the [EPEL repository](https://fedoraproject.org/wiki/EPEL) (Extra Packages for Enterprise Linux) on RHEL/CentOS systems.

## Requirements

- This role is specifically designed for RHEL and its derivatives.

## Role Variables

The following variables are available, along with their default values (see `defaults/main.yml`):

- **bootstrap_epel_repo__url**: 
  - Default: `"http://download.fedoraproject.org/pub/epel/{{ ansible_facts['distribution_major_version'] }}/{{ ansible_facts['userspace_architecture'] }}{{ '/' if ansible_facts['distribution_major_version'] < '7' else '/e/' }}epel-release-{{ ansible_facts['distribution_major_version'] }}-{{ epel_release[ansible_distribution_major_version] }}.noarch.rpm"`
  - Description: The URL for the EPEL repository. Generally, this should not be changed unless a specific version is required.

- **bootstrap_epel_repo__gpg_key_url**: 
  - Default: `"/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-{{ ansible_facts['distribution_major_version'] }}"`
  - Description: The URL for the EPEL GPG key. This should not typically be changed.

- **bootstrap_epel_repo__disable**: 
  - Default: `false`
  - Description: Set to `true` to disable the EPEL repository if it is already installed.

## Dependencies

This role has no external dependencies.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - geerlingguy.repo-epel
```

## License

This role is licensed under the MIT / BSD license.

## Author Information

This role was created in 2014 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).

## Backlinks

- [Ansible Roles Collection](../README.md)
```

This improved version maintains all the original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.