---
title: SnapRAID Bootstrap Role Documentation
role: bootstrap_snapraid
category: Storage Management
type: Ansible Role
tags: snapraid, backup, automation, debian
---

## Summary

The `bootstrap_snapraid` role is designed to automate the installation and configuration of SnapRAID on Debian-based systems. It handles the installation of SnapRAID from source, sets up a configuration file, installs additional tools for health checks and automated parity runs, and configures cron jobs for regular maintenance tasks.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| role_bootstrap_snapraid__apt_package_name  | snapraid                                                                        | The name of the SnapRAID package to install.                                                                                                                                                                |
| role_bootstrap_snapraid__bin_path       | /usr/local/bin/snapraid                                                       | Path where the SnapRAID binary will be installed.                                                                                                                                                           |
| role_bootstrap_snapraid__force_install  | false                                                                         | Force installation even if SnapRAID is already installed.                                                                                                                                                   |
| role_bootstrap_snapraid__src_dir        | /var/lib/src/snapraid                                                         | Directory to clone and build SnapRAID from source.                                                                                                                                                          |
| role_bootstrap_snapraid__healthchecks_dir | /opt/snapraid-checks                                                          | Directory for the snapraid-checks tools.                                                                                                                                                                    |
| role_bootstrap_snapraid__healthcheck_io_uuid | ""                                                                           | UUID for health checks using services like Healthchecks.io.                                                                                                                                                |
| role_bootstrap_snapraid__email_address  | ""                                                                            | Email address for sending notifications (if configured).                                                                                                                                                  |
| role_bootstrap_snapraid__email_pass     | ""                                                                            | Password for the email account used to send notifications.                                                                                                                                                |
| role_bootstrap_snapraid__email_address_from | "{{ role_bootstrap_snapraid__email_address }}"                                 | Sender email address for notifications. Defaults to `role_bootstrap_snapraid__email_address`.                                                                                                             |
| role_bootstrap_snapraid__email_address_to   | "{{ role_bootstrap_snapraid__email_address }}"                                 | Recipient email address for notifications. Defaults to `role_bootstrap_snapraid__email_address`.                                                                                                          |
| role_bootstrap_snapraid__email_sendon     | error                                                                         | Send email on specific conditions (e.g., error).                                                                                                                                                            |
| role_bootstrap_snapraid__smtp_host      | smtp.gmail.com                                                                | SMTP server host for sending emails.                                                                                                                                                                        |
| role_bootstrap_snapraid__smtp_port      | 465                                                                           | Port used by the SMTP server.                                                                                                                                                                               |
| role_bootstrap_snapraid__use_ssl        | true                                                                          | Use SSL/TLS for secure email transmission.                                                                                                                                                                  |
| role_bootstrap_snapraid__config_excludes| []                                                                            | List of directories to exclude from SnapRAID configuration.                                                                                                                                                |
| role_bootstrap_snapraid__config_hidden_files_enabled | false                                                               | Enable hidden files in the SnapRAID configuration.                                                                                                                                                        |
| role_bootstrap_snapraid__config_hidden_files | nohidden                                                                    | Hidden files setting for the SnapRAID configuration. Defaults to `nohidden`.                                                                                                                              |
| role_bootstrap_snapraid__config_path    | /etc/snapraid.conf                                                            | Path where the SnapRAID configuration file will be placed.                                                                                                                                                |
| role_bootstrap_snapraid__healthcheck_url| https://hc-ping.com/{{ role_bootstrap_snapraid__healthcheck_io_uuid }}          | URL for health checks using services like Healthchecks.io. Defaults to a template string incorporating `role_bootstrap_snapraid__healthcheck_io_uuid`.                                                      |
| role_bootstrap_snapraid__run_path       | /opt/snapraid-runner                                                          | Directory for the snapraid-runner tool.                                                                                                                                                                     |
| role_bootstrap_snapraid__run_conf     | "{{ role_bootstrap_snapraid__run_path }}/snapraid-runner.conf"                 | Path to the configuration file for snapraid-runner. Defaults to a template string incorporating `role_bootstrap_snapraid__run_path`.                                                                      |
| role_bootstrap_snapraid__run_bin      | "{{ role_bootstrap_snapraid__run_path }}/snapraid-runner.py"                   | Path to the snapraid-runner script. Defaults to a template string incorporating `role_bootstrap_snapraid__run_path`.                                                                                      |
| role_bootstrap_snapraid__run_command  | python3 {{ role_bootstrap_snapraid__run_bin }} -c {{ role_bootstrap_snapraid__run_conf}} && curl -fsS --retry 3 {{ role_bootstrap_snapraid__healthcheck_url }} > /dev/null | Command to run snapraid-runner and send a health check ping. Defaults to a template string incorporating various other variables.              |
| role_bootstrap_snapraid__run_scrub    | true                                                                          | Enable scrubbing of disks as part of the maintenance routine.                                                                                                                                             |
| role_bootstrap_snapraid__run_scrub_percent | 22                                                                           | Percentage of files to be scrubbed during each run.                                                                                                                                                       |
| role_bootstrap_snapraid__run_scrub_age  | 8                                                                             | Age in days after which files are eligible for scrubbing.                                                                                                                                                   |
| role_bootstrap_snapraid__touch        | true                                                                          | Touch the parity file to update its timestamp as part of the maintenance routine.                                                                                                                         |
| role_bootstrap_snapraid__deletethreshold| 250                                                                           | Threshold for the number of deletions that can occur before a sync is required.                                                                                                                             |
| role_bootstrap_snapraid__cron_jobs    | - job: "{{ role_bootstrap_snapraid__run_command }}"<br>name: snapraid_runner<br>weekday: "*"<br>hour: "01" | List of cron jobs to schedule for running SnapRAID maintenance tasks. Defaults to a template string incorporating `role_bootstrap_snapraid__run_command`. |

## Usage

To use the `bootstrap_snapraid` role, include it in your playbook and provide any necessary variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_snapraid
      vars:
        role_bootstrap_snapraid__healthcheck_io_uuid: "your-healthchecks-io-uuid"
        role_bootstrap_snapraid__email_address: "your-email@example.com"
        role_bootstrap_snapraid__email_pass: "your-email-password"
```

## Dependencies

This role has the following dependencies:

- `ansible.builtin.git` for cloning repositories.
- `ansible.builtin.apt` for installing packages on Debian-based systems.

Ensure that these modules are available in your Ansible environment.

## Best Practices

1. **Backup Configuration**: Always back up your existing SnapRAID configuration before applying this role to avoid data loss.
2. **Email Notifications**: Configure email notifications carefully, especially if using a service like Gmail, which may require additional security settings (e.g., app-specific passwords).
3. **Health Checks**: Use health check services to monitor the status of your SnapRAID setup and receive alerts in case of failures.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_snapraid/defaults/main.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_snapraid/tasks/install-debian.yml)
- [tasks/install-snapraid-checks.yml](../../roles/bootstrap_snapraid/tasks/install-snapraid-checks.yml)
- [tasks/install-snapraid-runner.yml](../../roles/bootstrap_snapraid/tasks/install-snapraid-runner.yml)
- [tasks/main.yml](../../roles/bootstrap_snapraid/tasks/main.yml)