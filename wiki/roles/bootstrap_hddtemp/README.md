```markdown
---
title: bootstrap_hddtemp Role Documentation
original_path: roles/bootstrap_hddtemp/README.md
category: Ansible Roles
tags: [ansible, hddtemp, debian]
harvested_date: '2026-05-04T16:47:07.984363+00:00'
source_type: legacy_markdown
---

# bootstrap_hddtemp Role

## Overview

The `bootstrap_hddtemp` role is designed to install and configure the `hddtemp` utility on Debian-based systems. This utility provides temperature monitoring for hard disk drives.

## Usage

To use this role, include it in your Ansible playbook:

```yaml
- hosts: all
  roles:
    - bootstrap_hddtemp
```

## Configuration

No additional configuration is required beyond including the role in your playbook. The role will automatically handle the installation and basic setup of `hddtemp`.

## Dependencies

This role has no external dependencies.

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved version includes a structured format with clear headings, YAML frontmatter enhancements, and a "Backlinks" section for better navigation.