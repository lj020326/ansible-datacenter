---
title: Ansible Role for Veeam Agent Configuration
original_path: roles/bootstrap_veeam_agent_config/README.md
category: Ansible Roles
tags: [veeam, ansible, linux, debian, centos]
---

# Ansible Role: Veeam Agent

## Description

This role installs and configures the Veeam Agent for Linux on Debian and CentOS systems.

## Installation

To install this role using `ansible-galaxy`, run:

```bash
ansible-galaxy install sbaerlocher.veeam-agent
```

## Requirements

- This role has no specific requirements beyond the standard Ansible setup.

## Role Variables

The following variables can be customized in your playbook to configure Veeam Agent:

```yaml
veeam:
  vbrserver:
    name: ""       # Name of the VBR server
    endpoint: ""   # Endpoint URL for the VBR server
    login: ""      # Login username for the VBR server
    domain: ""     # Domain for the VBR server (if applicable)
    password: ""   # Password for the VBR server login
  repo:
    name: ""       # Name of the backup repository
    path: ""       # Path to the backup repository on the VBR server
  job:
    name: ""       # Name of the backup job
    restopoints: 0 # Number of restore points to keep
    day: ""        # Day of the week for the scheduled backup (e.g., "Monday")
    at: ""         # Time of day for the scheduled backup (e.g., "23:00")
```

## Dependencies

- This role has no external dependencies.

## Example Playbook

Here is an example playbook that uses this role:

```yaml
- hosts: all
  roles:
    - sbaerlocher.veeam-agent
```

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Veeam Agent for Linux Documentation](https://helpcenter.veeam.com/docs/agentforlinux/index.html?ver=50)

This documentation provides a clear and structured overview of the Ansible role for configuring Veeam Agent on Debian and CentOS systems.