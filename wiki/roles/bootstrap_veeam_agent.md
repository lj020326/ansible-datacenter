---
title: "Bootstrap Veeam Agent Role"
role: roles/bootstrap_veeam_agent
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_veeam_agent]
---

# Role Documentation: `bootstrap_veeam_agent`

## Overview

The `bootstrap_veeam_agent` Ansible role is designed to automate the installation and configuration of the Veeam Agent on various operating systems, including CentOS, Debian-based distributions (like Ubuntu), and Windows. This role handles package management, repository setup, and service configuration for a seamless deployment process.

## Role Path
```
roles/bootstrap_veeam_agent
```

## Variables

### Default Variables (`defaults/main.yml`)

| Variable Name                      | Description                                                                                   | Default Value                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `architecture`                     | Architecture check to ensure the system is x86_64.                                            | `ansible_facts['architecture'] == 'x86_64'`                                   |
| `veeam_recovery_media_url`         | URL for Veeam Recovery Media ISO.                                                             | `http://repository.veeam.com/backup/linux/agent/veeam-recovery-media/x64/veeam-recovery-media-4.0.0.iso` |
| `veeam_vbrserver.name`             | Name of the VBR server.                                                                       | (empty)                                                                       |
| `veeam_vbrserver.endpoint`         | Endpoint URL for the VBR server.                                                              | (empty)                                                                       |
| `veeam_vbrserver.login`            | Login username for the VBR server.                                                            | (empty)                                                                       |
| `veeam_vbrserver.domain`           | Domain for the VBR server login.                                                              | (empty)                                                                       |
| `veeam_vbrserver.password`         | Password for the VBR server login.                                                            | (empty)                                                                       |
| `veeam_repo.name`                  | Name of the backup repository.                                                                | (empty)                                                                       |
| `veeam_repo.path`                  | Path to the backup repository.                                                                | (empty)                                                                       |
| `veeam_job.name`                   | Name of the Veeam backup job.                                                                 | (empty)                                                                       |
| `veeam_job.restopoints`            | Number of restore points to keep.                                                             | (empty)                                                                       |
| `veeam_job.day`                    | Day of the week for the backup job.                                                           | (empty)                                                                       |
| `veeam_job.at`                     | Time of day for the backup job.                                                               | (empty)                                                                       |

**Note:** Variables related to VBR server, repository, and job configuration are placeholders and should be populated with actual values as per your environment.

## Tasks

### CentOS (`tasks/CentOS.yml`)
- **Install veeam agent packages**: Installs the necessary Veeam Agent packages on CentOS systems using the `ansible.builtin.package` module.

### Debian (`tasks/Debian.yml`)
1. **Add Veeam key**: Adds the Veeam repository GPG key using the `ansible.builtin.apt_key` module.
2. **Add Veeam repository**: Configures the Veeam repository in APT sources using the `ansible.builtin.apt_repository` module.
3. **Update veeam agent packages**: Installs or updates the Veeam Agent packages on Debian-based systems.

### Windows (`tasks/Windows.yml`)
1. **Install veeam agent**: Installs the Veeam Agent for Microsoft Windows using Chocolatey via the `chocolatey.chocolatey.win_chocolatey` module.
2. **Disable Tray**: Disables the Veeam EndPoint Tray application from starting automatically by modifying the Windows Registry using the `ansible.windows.win_regedit` module.

### Main (`tasks/main.yml`)
1. **Add OS specific variables**: Includes OS-specific variable files based on the distribution and version facts.
2. **Include distribution tasks**: Executes OS-specific task files to handle package installation and configuration.
3. **Accept EULA**: Accepts the End User License Agreement (EULA) for Veeam Agent using the `ansible.builtin.command` module.
4. **Accept EULA 3rd party**: Accepts third-party licenses required by Veeam Agent.

## Handlers

### Main (`handlers/main.yml`)
1. **Restart veeamservices**: Restarts the Veeam services to apply any configuration changes.
2. **Enable veeamservices**: Ensures that the Veeam services are enabled to start on system boot.

## Usage Example

Below is an example playbook demonstrating how to use the `bootstrap_veeam_agent` role:

```yaml
---
- name: Deploy Veeam Agent
  hosts: all
  become: yes
  roles:
    - role: bootstrap_veeam_agent
      vars:
        veeam_vbrserver:
          name: "vbr-server"
          endpoint: "https://vbr-server.example.com"
          login: "admin"
          domain: "example.com"
          password: "securepassword"
        veeam_repo:
          name: "BackupRepo"
          path: "/mnt/backuprepo"
        veeam_job:
          name: "DailyBackup"
          restopoints: 7
          day: "Monday"
          at: "02:00"
```

## Important Notes

- **Double-underscore variables**: These are internal to the role and should not be modified.
- **Related Roles**: This documentation does not invent or reference related roles. All configurations are handled within this role.
- **Markdown Format**: This documentation is written in standard GitHub Markdown.

This comprehensive guide provides a clear understanding of how to deploy and configure the Veeam Agent across different operating systems using Ansible.