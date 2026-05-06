---
title: "Bootstrap Veeam Agent Config Role"
role: roles/bootstrap_veeam_agent_config
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_veeam_agent_config]
---

# Role Documentation: `bootstrap_veeam_agent_config`

## Overview

The `bootstrap_veeam_agent_config` Ansible role is designed to automate the configuration of Veeam Backup & Replication (B&R) on Linux systems, specifically targeting Debian and RedHat-based distributions. This role ensures that a VBR server, repository, and backup job are properly set up according to the provided variables.

## Role Path

```
roles/bootstrap_veeam_agent_config
```

## Requirements

- Ansible 2.9 or later.
- Supported operating systems: Debian and RedHat families.
- Veeam Agent for Linux installed on the target hosts.

## Variables

### `defaults/main.yml`

| Variable                     | Description                                                                 | Default Value                                  |
|------------------------------|-----------------------------------------------------------------------------|------------------------------------------------|
| `architecture`               | Architecture check, should be x86_64.                                       | `ansible_facts['architecture'] == 'x86_64'`    |
| `veeam_vbrserver.name`       | Name of the VBR server.                                                     | (none)                                         |
| `veeam_vbrserver.endpoint`   | Endpoint address of the VBR server.                                         | (none)                                         |
| `veeam_vbrserver.login`      | Login username for the VBR server.                                          | (none)                                         |
| `veeam_vbrserver.domain`     | Domain for the VBR server login.                                            | (none)                                         |
| `veeam_vbrserver.password`   | Password for the VBR server login.                                          | (none)                                         |
| `veeam_repo.name`            | Name of the Veeam repository.                                               | (none)                                         |
| `veeam_repo.path`            | Path where the repository will be created.                                  | (none)                                         |
| `veeam_repo.type`            | Type of the repository (optional).                                          | (none)                                         |
| `veeam_job.name`             | Name of the backup job.                                                     | (none)                                         |
| `veeam_job.restopoints`      | Maximum number of restore points to keep.                                   | (none)                                         |
| `veeam_job.day`              | Day of the week for scheduled backups.                                      | `'Sat'`                                        |
| `veeam_job.at`               | Time of day for scheduled backups.                                          | `'20:00'`                                      |
| `veeam_job.backupallsystem`  | Whether to backup the entire system.                                        | `false`                                        |
| `veeam_job.objects`          | Specific objects to include in the backup (optional).                       | (none)                                         |

## Tasks

### `tasks/main.yml`

1. **Setup Veeam Backup & Replication Configuration**
   - Checks if the VBR server is already configured.
   - Creates a new VBR server configuration if it does not exist.

2. **Ensure veeam repo**
   - Checks if the repository is already created.
   - Creates a new repository with specified name and path, optionally specifying the type.

3. **Ensure veeam job**
   - Loads the list of repositories to find the ID of the specified repository.
   - Checks if the backup job is already configured.
   - Creates a new backup job based on the provided parameters.
   - Sets up a schedule for the backup job, ensuring it runs automatically at the specified time and day.

## Handlers

### `handlers/main.yml`

1. **restart veeamservices**
   - Restarts the Veeam services to apply any configuration changes.

2. **enable veeamservices**
   - Ensures that the Veeam services are enabled to start on boot.

## Usage Example

```yaml
- name: Configure Veeam Backup & Replication Agent
  hosts: backup_servers
  roles:
    - role: bootstrap_veeam_agent_config
      vars:
        veeam_vbrserver:
          name: "VBRServer1"
          endpoint: "vbrserver.example.com"
          login: "admin"
          domain: "example.com"
          password: "securepassword"
        veeam_repo:
          name: "BackupRepo"
          path: "/mnt/backuprepo"
        veeam_job:
          name: "DailySystemBackup"
          restopoints: 5
          day: "Sun"
          at: "02:00"
          backupallsystem: true
```

## Important Notes

- Double-underscore variables are internal only and should not be modified.
- This role does not invent related roles; it focuses solely on configuring Veeam B&R components.
- Ensure that the Veeam Agent for Linux is installed on the target hosts before running this role.

This documentation provides a comprehensive guide to using the `bootstrap_veeam_agent_config` Ansible role, ensuring proper setup and configuration of Veeam Backup & Replication on supported Linux distributions.