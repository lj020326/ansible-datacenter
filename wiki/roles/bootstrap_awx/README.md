```markdown
---
title: bootstrap-awx : Automation Controller Setup
original_path: roles/bootstrap_awx/README.md
category: Documentation
tags: [AWX, AutomationController, Rancher, Kubernetes]
---

# Bootstrap AWX: Automation Controller Setup

This playbook bootstraps an AWX/Automation Controller system capable of creating and managing multiple servers. It also installs [Rancher](https://www.rancher.com/), a tool for managing Kubernetes. Ideally, this system should manage updates, configuration, backups, and monitoring of servers autonomously.

## Installation

To configure and install this AWX/Automation Controller setup on your own server, follow the [bootstrap setup steps detailed here](docs/bootstrap_awx.md).

## Features

- **Deployment Support**: Ubuntu 20.04 and 22.04. [Done]
- **AWX Version Update**: Updated to version 1.1.0. [Done]
- **awx-on-k3s Version Update**: Updated to version 1.1.0. [Done]
- **k9s Version Update**: Updated to the latest version. [Done]

## To Do

- **Fix Rancher**: []
- **AWX Token Generation**: Fixed? []
- **Automate Backups**: Use Borg.
- **Automate Recovery**:
- **Routine Recovery Testing**: For AWX setup.

## Reference

- [PC-Admin/awx-ansible GitHub Repository](https://github.com/PC-Admin/awx-ansible)

## Backlinks

- [Main Documentation Index](../README.md)
```

This improved version includes a clean and professional structure with proper headings, YAML frontmatter enhancements, and a "Backlinks" section for navigation.