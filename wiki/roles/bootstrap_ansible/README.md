```markdown
---
title: Ansible Role for Installing Ansible on Linux Servers
original_path: roles/bootstrap_ansible/README.md
category: Ansible Roles
tags: ansible, installation, role, linux
---

# Ansible Role: Bootstrap Ansible

This Ansible role installs Ansible on Linux servers.

## Requirements

- If using on a RedHat/CentOS/Rocky Linux-based host, ensure the EPEL repository is added. This can be done by including the `geerlingguy.repo-epel` role from Ansible Galaxy.

## Role Variables

Available variables are listed below, along with their default values (see `defaults/main.yml`):

- **bootstrap_ansible__install_method**: `package`
  - Whether to install Ansible via the system package manager (`apt`, `yum`, `dnf`, etc.), or via `pip`. If set to `pip`, ensure Pip is installed prior to running this role. You can use the `bootstrap_pip` module to install Pip easily.

- **bootstrap_ansible__install_version_pip**: `''`
  - If `bootstrap_ansible__install_method` is set to `pip`, specifies the Ansible version to be installed via Pip. If not set, the latest version of Ansible will be installed.

- **bootstrap_ansible__install_pip_extra_args**: `''`
  - If `bootstrap_ansible__install_method` is set to `pip`, lists extra arguments to be given to `pip`. If not set, no extra arguments are provided.

## Dependencies

None.

## Example Playbook

### Install from the System Package Manager

```yaml
- hosts: servers
  roles:
    - role: bootstrap_ansible
```

### Install from Pip

```yaml
- hosts: servers
  vars:
    bootstrap_ansible__install_method: pip
    bootstrap_ansible__install_version_pip: "2.7.0"
    bootstrap_ansible__install_pip_extra_args: "--user"
  roles:
    - role: bootstrap_pip
    - role: bootstrap_ansible
```

## Reference

- [geerlingguy/ansible-role-ansible](https://github.com/geerlingguy/ansible-role-ansible)

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved version maintains all the original information while adhering to clean, professional Markdown formatting and structure suitable for GitHub rendering.