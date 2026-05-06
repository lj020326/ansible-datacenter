---
title: Bootstrap Logrotate Role Documentation
role: bootstrap_logrotate
category: System Configuration
type: Ansible Role
tags: logrotate, logging, system, configuration

## Summary
The `bootstrap_logrotate` Ansible role is designed to install and configure the `logrotate` utility on Linux systems. It manages global log rotation settings, application-specific log rotation configurations, and optional hourly rotation symlinks.

## Variables
| Variable Name                         | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_logrotate__options`        | `[]`                                                                          | A list of global options to be added to the `/etc/logrotate.conf` file.                                                                                                                                     |
| `bootstrap_logrotate__include_dir`    | `/etc/logrotate.d`                                                            | The directory where application-specific log rotation configurations are stored.                                                                                                                              |
| `bootstrap_logrotate__package`        | `logrotate`                                                                   | The name of the package to be installed for log rotation.                                                                                                                                                   |
| `bootstrap_logrotate__global_config`  | `true`                                                                        | A boolean flag indicating whether to create a global `/etc/logrotate.conf` file.                                                                                                                            |
| `bootstrap_logrotate__use_hourly_rotation` | `false`                                                                    | A boolean flag indicating whether to enable hourly log rotation by creating a symlink from `/etc/cron.hourly/logrotate` to `/etc/cron.daily/logrotate`.                                                      |
| `bootstrap_logrotate__wtmp_enable`    | `true`                                                                        | A boolean flag indicating whether to configure log rotation for the `/var/log/wtmp` file.                                                                                                                     |
| `bootstrap_logrotate__wtmp`           | `{ logs: ['/var/log/wtmp'], options: ['missingok', 'monthly', 'create 0664 root utmp', 'rotate 1'] }` | A dictionary defining log rotation settings for the `/var/log/wtmp` file, including the list of logs and their respective options.                                                                          |
| `bootstrap_logrotate__btmp_enable`    | `true`                                                                        | A boolean flag indicating whether to configure log rotation for the `/var/log/btmp` file.                                                                                                                     |
| `bootstrap_logrotate__btmp`           | `{ logs: ['/var/log/btmp'], options: ['missingok', 'monthly', 'create 0660 root utmp', 'rotate 1'] }` | A dictionary defining log rotation settings for the `/var/log/btmp` file, including the list of logs and their respective options.                                                                          |
| `bootstrap_logrotate__applications`   | `[]`                                                                          | A list of dictionaries defining application-specific log rotation configurations, each containing a name and options for specific log files.                                                                      |

## Usage
To use this role, include it in your playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_logrotate
      vars:
        bootstrap_logrotate__options:
          - compress
          - delaycompress
          - missingok
        bootstrap_logrotate__use_hourly_rotation: true
        bootstrap_logrotate__applications:
          - name: myapp
            logs:
              - /var/log/myapp.log
            options:
              - daily
              - rotate 7
```

## Dependencies
This role has no external dependencies.

## Tags
- `system`
- `logrotate`
- `log`
- `rotate`

## Best Practices
- Ensure that the log rotation settings are appropriate for your system's logging requirements.
- Regularly review and update log rotation configurations to accommodate changes in application logging behavior.
- Test log rotation configurations in a staging environment before applying them to production systems.

## Molecule Tests
This role does not include Molecule tests. However, it is recommended to create test scenarios using Molecule to validate the role's functionality across different operating systems and configurations.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_logrotate/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_logrotate/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_logrotate/meta/main.yml)