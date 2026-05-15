---
title: Bootstrap Veeam Agent Configuration Role
role: bootstrap_veeam_agent_config
category: Configuration Management
type: Ansible Role
tags: veeam, backup, replication, configuration
---

## Summary

The `bootstrap_veeam_agent_config` role is designed to automate the setup and configuration of Veeam Backup & Replication (B&R) on Linux systems. It ensures that a VBR server, repository, and job are properly configured according to specified parameters.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_veeam_agent_config__architecture` | `ansible_facts['architecture'] == x86_64`                                   | Specifies the system architecture. By default, it checks if the architecture is x86_64.                                                                                                                   |
| `role_bootstrap_veeam_agent_config__veeam_vbrserver_name` | (not set)                                                                       | The name of the VBR server to be configured. Must be defined for the role to proceed with creating or checking the VBR server.                                                                              |
| `role_bootstrap_veeam_agent_config__veeam_vbrserver_endpoint` | (not set)                                                                     | The endpoint address of the VBR server. Required if `veeam_vbrserver_name` is specified.                                                                                                                    |
| `role_bootstrap_veeam_agent_config__veeam_vbrserver_login` | (not set)                                                                       | The login username for authenticating with the VBR server. Required if `veeam_vbrserver_name` is specified.                                                                                                 |
| `role_bootstrap_veeam_agent_config__veeam_vbrserver_domain` | (not set)                                                                       | The domain of the user account used to authenticate with the VBR server. Required if `veeam_vbrserver_name` is specified.                                                                                     |
| `role_bootstrap_veeam_agent_config__veeam_vbrserver_password` | (not set)                                                                     | The password for the user account used to authenticate with the VBR server. Required if `veeam_vbrserver_name` is specified.                                                                                 |
| `role_bootstrap_veeam_agent_config__veeam_repo_name`        | (not set)                                                                       | The name of the repository to be configured. Must be defined for the role to proceed with creating or checking the repository.                                                                              |
| `role_bootstrap_veeam_agent_config__veeam_repo_path`        | (not set)                                                                       | The path where the repository will store backup files. Required if `veeam_repo_name` is specified.                                                                                                          |
| `role_bootstrap_veeam_agent_config__veeam_repo_type`        | (not set)                                                                       | The type of the repository (e.g., local, network). Optional, defaults to local if not specified.                                                                                                            |
| `role_bootstrap_veeam_agent_config__veeam_job_name`         | (not set)                                                                       | The name of the backup job to be configured. Must be defined for the role to proceed with creating or checking the job.                                                                                     |
| `role_bootstrap_veeam_agent_config__veeam_job_restopoints`  | (not set)                                                                       | The maximum number of restore points to retain. Required if `veeam_job_name` is specified.                                                                                                                  |
| `role_bootstrap_veeam_agent_config__veeam_job_day`          | `Sat`                                                                           | The day of the week when the backup job should run. Defaults to Saturday if not specified.                                                                                                                |
| `role_bootstrap_veeam_agent_config__veeam_job_at`           | `20:00`                                                                         | The time of day when the backup job should start. Defaults to 8 PM (20:00) if not specified.                                                                                                              |
| `role_bootstrap_veeam_agent_config__veeam_job_backupallsystem` | `false`                                                                       | A boolean indicating whether to back up all system files. If set to true, it will use the `--backupallsystem` option when creating the job.     |
| `role_bootstrap_veeam_agent_config__veeam_job_objects`      | (not set)                                                                       | A list of specific objects to include in the backup job. Required if `veeam_job_backupallsystem` is false and `veeam_job_name` is specified. |

## Usage

To use this role, you need to define the required variables in your playbook or inventory file. Here's an example of how to configure a VBR server, repository, and job:

```yaml
- hosts: backup_servers
  roles:
    - role: bootstrap_veeam_agent_config
      vars:
        role_bootstrap_veeam_agent_config__veeam_vbrserver_name: "vbr-server"
        role_bootstrap_veeam_agent_config__veeam_vbrserver_endpoint: "192.168.1.100"
        role_bootstrap_veeam_agent_config__veeam_vbrserver_login: "admin"
        role_bootstrap_veeam_agent_config__veeam_vbrserver_domain: "example.com"
        role_bootstrap_veeam_agent_config__veeam_vbrserver_password: "securepassword"
        role_bootstrap_veeam_agent_config__veeam_repo_name: "local-repo"
        role_bootstrap_veeam_agent_config__veeam_repo_path: "/mnt/backup"
        role_bootstrap_veeam_agent_config__veeam_job_name: "daily-backup"
        role_bootstrap_veeam_agent_config__veeam_job_restopoints: 7
        role_bootstrap_veeam_agent_config__veeam_job_day: "Sun"
        role_bootstrap_veeam_agent_config__veeam_job_at: "02:00"
```

## Dependencies

- This role requires the Veeam Agent for Linux to be installed on the target systems.
- The `ansible_facts` module should be available and populated with relevant information about the system.

## Best Practices

- Ensure that all required variables are defined in your playbook or inventory file before running this role.
- Use strong, unique passwords for the VBR server authentication.
- Regularly review and update the backup job settings to meet changing requirements.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding test scenarios to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_veeam_agent_config/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_veeam_agent_config/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_veeam_agent_config/handlers/main.yml)