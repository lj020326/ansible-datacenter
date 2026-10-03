---
title: "Bootstrap AWX: Automation Controller Setup"
original_path: roles/bootstrap_awx/README.md
category: "Automation"
tags: ["AWX", "Automation Controller", "Ansible", "Rancher", "Kubernetes"]
harvested_date: '2026-08-07T18:07:09.147224+00:00'
source_type: legacy_markdown
---

# Bootstrap AWX: Automation Controller Setup

This playbook bootstraps an AWX/Automation Controller system capable of creating and managing multiple servers. It also supports the installation of [Rancher](https://www.rancher.com/), a tool for managing Kubernetes clusters. Ideally, this system can manage updates, configuration, backups, and monitoring of servers autonomously.

AWX is the upstream project of the Red Hat Ansible Automation Platform. It provides a web-based solution and API to manage Ansible playbooks, inventories, and other resources.

## Prerequisites

- A server running Ubuntu 20.04 or 22.04
- Root or sudo access to the server
- Basic knowledge of Ansible and Kubernetes

## Installation

To configure and install this AWX/Automation Controller setup on your own server, follow the [bootstrap setup steps detailed here](docs/bootstrap_awx.md). This document provides a step-by-step guide to installing and configuring the system.

## Features

- Support for deployment on Ubuntu 20.04 and 22.04. [completed]
- Updated AWX to version 1.1.0. [completed]
- Updated awx-on-k3s to version 1.1.0. [completed]
- Updated k9s to the latest version. [completed]

## To Do

- [ ] Fix Rancher
- [ ] Fix AWX token generation
- [ ] Automate backups using Borg
- [ ] Automate recovery
- [ ] Automate routine recovery testing for the AWX setup

## Usage Examples

After installation, you can access the AWX web interface by navigating to `http://<your-server-ip>` in your web browser. The default credentials are `admin`/`admin`.

## Reference

- [PC-Admin/awx-ansible GitHub Repository](https://github.com/PC-Admin/awx-ansible)

## Additional Resources

- [AWX Official Documentation](https://awx.readthedocs.io/)
- [Rancher Official Documentation](https://rancher.com/docs/rancher/v2.x/en/)