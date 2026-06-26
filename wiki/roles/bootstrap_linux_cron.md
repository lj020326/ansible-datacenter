---
title: Bootstrap Linux Cron Role Documentation
role: bootstrap_linux_cron
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_linux_cron` role is designed to manage cron jobs on Linux systems. It allows users to define and configure cron tasks using a structured format, supports the creation of daily batch scripts for system maintenance, and provides options to reset or setup these scripts as needed.

## Variables

| Variable Name                           | Default Value              | Description                                                                 |
|-----------------------------------------|----------------------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_cron__list`            | `[]`                       | A list of cron jobs to be managed. Each item should define the job details.  |
| `bootstrap_linux_cron__state`           | `present`                  | The state of the cron jobs (can be `present` or `absent`).                 |
| `bootstrap_linux_cron__setup_daily_scripts` | `true`                   | Whether to setup daily batch scripts for system maintenance.                |
| `bootstrap_linux_cron__reset_daily_scripts` | `true`                   | Whether to reset existing daily batch scripts before setting up new ones.   |

## Usage

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__list:
          - name: "Daily OS Update"
            job: "/usr/local/bin/run-os-update.sh"
            special_time: daily
            user: root
            state: present
```

### Example Cron Job Definition

```yaml
bootstrap_linux_cron__list:
  - name: "Backup Database"
    job: "/usr/local/bin/backup-db.sh"
    schedule: [0, 2, '*', '*', '*']  # Every day at 2 AM
    user: dbadmin
    state: present
```

### Example Daily Script Setup

To setup daily batch scripts for system maintenance:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__setup_daily_scripts: true
        bootstrap_linux_cron__reset_daily_scripts: false
```

## Dependencies

This role does not have any external dependencies. It relies on the `ansible.builtin` modules available in Ansible.

## Best Practices

- **State Management**: Always specify the state (`present` or `absent`) for each cron job to avoid unintended removals.
- **User Specification**: Define the user under which the cron jobs should run, especially if they require elevated privileges.
- **Script Paths**: Ensure that all scripts referenced in the cron jobs are correctly placed and have executable permissions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_cron/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_cron/tasks/main.yml)
- [tasks/setup-daily-scripts.yml](../../roles/bootstrap_linux_cron/tasks/setup-daily-scripts.yml)