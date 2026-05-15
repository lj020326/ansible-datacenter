---
title: Bootstrap Veeam Agent Role Documentation
role: bootstrap_veeam_agent
category: Ansible Roles
type: Configuration
tags: veeam, agent, backup, ansible
---

## Summary

The `bootstrap_veeam_agent` role is designed to automate the installation and configuration of the Veeam Backup & Replication (VBR) Agent on various operating systems including CentOS, Debian, and Windows. This role ensures that the Veeam Agent is installed, configured with necessary agreements, and services are properly managed.

## Variables

| Variable Name                         | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_veeam_agent__architecture` | `ansible_facts['architecture'] == x86_64`                                                       | Specifies the architecture of the system. By default, it checks if the architecture is x86_64.                                                                                                                |
| `role_bootstrap_veeam_agent__veeam_recovery_media_url` | `http://repository.veeam.com/backup/linux/agent/veeam-recovery-media/x64/veeam-recovery-media-4.0.0.iso` | URL to the Veeam Recovery Media ISO file.                                                                                                                                                                       |
| `role_bootstrap_veeam_agent__veeam_vbrserver_name`     | (empty)                                                                                         | Name of the VBR server. This variable is required for configuring the agent to connect to a specific VBR server.                                                                                             |
| `role_bootstrap_veeam_agent__veeam_vbrserver_endpoint` | (empty)                                                                                         | Endpoint URL of the VBR server. Required for agent configuration.                                                                                                                                             |
| `role_bootstrap_veeam_agent__veeam_vbrserver_login`    | (empty)                                                                                         | Login username for authenticating with the VBR server.                                                                                                                                                      |
| `role_bootstrap_veeam_agent__veeam_vbrserver_domain`   | (empty)                                                                                         | Domain name for the login user, if applicable.                                                                                                                                                                |
| `role_bootstrap_veeam_agent__veeam_vbrserver_password` | (empty)                                                                                         | Password for the login user. This should be handled securely in your inventory or using Ansible Vault.                                                                                                          |
| `role_bootstrap_veeam_agent__veeam_repo_name`          | (empty)                                                                                         | Name of the backup repository where backups will be stored.                                                                                                                                                   |
| `role_bootstrap_veeam_agent__veeam_repo_path`          | (empty)                                                                                         | Path to the backup repository on the VBR server.                                                                                                                                                              |
| `role_bootstrap_veeam_agent__veeam_job_name`           | (empty)                                                                                         | Name of the backup job that will be created or configured for this agent.                                                                                                                                     |
| `role_bootstrap_veeam_agent__veeam_job_restopoints`    | (empty)                                                                                         | Number of restore points to keep in the backup job configuration.                                                                                                                                             |
| `role_bootstrap_veeam_agent__veeam_job_day`            | (empty)                                                                                         | Day of the week when the backup job should run.                                                                                                                                                               |
| `role_bootstrap_veeam_agent__veeam_job_at`             | (empty)                                                                                         | Time of day when the backup job should start, in HH:MM format.                                                                                                                                                |

## Usage

To use this role, include it in your playbook and provide the necessary variables for VBR server details, repository information, and backup job configuration.

### Example Playbook

```yaml
- name: Bootstrap Veeam Agent on CentOS
  hosts: centos_servers
  roles:
    - role: bootstrap_veeam_agent
      vars:
        role_bootstrap_veeam_agent__veeam_vbrserver_name: vbr-server.example.com
        role_bootstrap_veeam_agent__veeam_vbrserver_endpoint: https://vbr-server.example.com:9398/
        role_bootstrap_veeam_agent__veeam_vbrserver_login: admin
        role_bootstrap_veeam_agent__veeam_vbrserver_password: "{{ vault_veeam_password }}"
        role_bootstrap_veeam_agent__veeam_repo_name: DefaultBackupRepo
        role_bootstrap_veeam_agent__veeam_job_name: DailyFullBackup
        role_bootstrap_veeam_agent__veeam_job_restopoints: 7
        role_bootstrap_veeam_agent__veeam_job_day: Monday
        role_bootstrap_veeam_agent__veeam_job_at: "02:00"
```

## Dependencies

- **CentOS**: Requires the `ansible.builtin.package` module.
- **Debian**: Requires the `ansible.builtin.apt_key`, `ansible.builtin.apt_repository`, and `ansible.builtin.package` modules.
- **Windows**: Requires the `chocolatey.chocolatey.win_chocolatey` and `ansible.windows.win_regedit` modules.

## Best Practices

1. **Secure Passwords**: Use Ansible Vault to manage sensitive information such as passwords.
2. **Variable Naming**: Always use the `role_bootstrap_veeam_agent__` prefix for all user-configurable variables.
3. **Testing**: Test your playbooks in a staging environment before deploying them to production.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure the role behaves as expected across different operating systems and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_veeam_agent/defaults/main.yml)
- [tasks/CentOS.yml](../../roles/bootstrap_veeam_agent/tasks/CentOS.yml)
- [tasks/Debian.yml](../../roles/bootstrap_veeam_agent/tasks/Debian.yml)
- [tasks/Windows.yml](../../roles/bootstrap_veeam_agent/tasks/Windows.yml)
- [tasks/main.yml](../../roles/bootstrap_veeam_agent/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_veeam_agent/handlers/main.yml)