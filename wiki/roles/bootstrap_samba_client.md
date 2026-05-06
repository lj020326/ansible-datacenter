---
title: "Bootstrap Samba Client Role"
role: roles/bootstrap_samba_client
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_samba_client]
---

# Role Documentation: `bootstrap_samba_client`

## Overview

The `bootstrap_samba_client` Ansible role is designed to configure and manage Samba client installations on various Linux distributions, including CentOS, Fedora, Scientific, Debian, and Ubuntu. This role ensures that the necessary packages are installed, SMB configuration files are copied, mount directories are created, and Samba mounts are added to `/etc/fstab`.

## Role Variables

### Default Variables

The default variables for this role are defined in `defaults/main.yml`. These variables can be overridden by user-defined variables or group/host-specific variables.

| Variable Name               | Description                                                                                     | Default Value                                   |
|-----------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `samba_domain`              | The Samba domain to which the client will connect.                                              | `example.int`                                   |
| `samba_mounts`              | A list of dictionaries defining the mount points for Samba shares.                              | `[]`                                            |
| `samba_client_packages`     | A dictionary mapping Linux distributions to their respective Samba client package names.        | See below                                       |

#### `samba_client_packages`

This variable is a dictionary that maps different Linux distributions to their respective Samba client packages. The default configuration includes:

- **CentOS, Fedora, Scientific**: `cifs-utils`
- **Debian, Ubuntu**: `cifs-utils`

Example:
```yaml
samba_client_packages:
  CentOS: &rhpackages
    - cifs-utils
  Fedora: *rhpackages
  Scientific: *rhpackages
  Debian: &debpackages
    - cifs-utils
  Ubuntu: *debpackages
```

## Tasks

The tasks in this role are defined in `tasks/main.yml`. They perform the following actions:

1. **Install Samba client packages**:
   - Installs the necessary Samba client packages based on the distribution using the `ansible.builtin.package` module.

2. **Copy SMB configuration files**:
   - Copies the SMB credentials file (`config-smbcredentials.conf.j2`) to `/root/.smbcredentials` with appropriate permissions and ownership.
   - The template is rendered using the `ansible.builtin.template` module.

3. **Ensure mount dirs exist**:
   - Creates directories for Samba mounts if any are specified in `samba_mounts`.
   - Uses the `ansible.builtin.file` module to create directories with mode `0755`.

4. **Add Samba mounts to `/etc/fstab`**:
   - Adds entries to `/etc/fstab` for each mount point defined in `samba_mounts`.
   - Mounts the shares using the `ansible.posix.mount` module.

## Handlers

The handlers in this role are defined in `handlers/main.yml`. They perform the following actions:

1. **Reload firewalld**:
   - Reloads the firewall configuration to apply any changes.
   - Uses the `ansible.builtin.command` module with `firewall-cmd --reload`.

2. **Restart firewalld**:
   - Restarts the firewalld service to ensure all configurations are applied.
   - Uses the `ansible.builtin.service` module.

## Example Playbook

Below is an example playbook that demonstrates how to use the `bootstrap_samba_client` role:

```yaml
---
- name: Bootstrap Samba Client on Linux hosts
  hosts: samba_clients
  become: yes
  vars:
    samba_domain: mydomain.local
    samba_mounts:
      - name: /mnt/samba_share1
        src: //server/share1
        fstype: cifs
        options: "credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0777,dir_mode=0777"
  roles:
    - role: bootstrap_samba_client
```

## Notes

- **Double-underscore variables**: These are internal only and should not be modified.
- **Related Roles**: This documentation does not invent related roles. The `bootstrap_samba_client` role is self-contained for configuring Samba clients.

This comprehensive guide provides a detailed overview of the `bootstrap_samba_client` Ansible role, including its purpose, variables, tasks, handlers, and an example playbook to help you get started with deploying Samba clients in your environment.