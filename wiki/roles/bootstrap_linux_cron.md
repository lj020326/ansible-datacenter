---
title: Bootstrap Linux Cron Role Documentation
role: bootstrap_linux_cron
category: System Management
type: Ansible Role
tags: cron, linux, automation
---

## Summary

The `bootstrap_linux_cron` role is designed to manage cron jobs on Linux systems. It allows users to define and configure cron jobs using a structured format, supporting both schedule arrays and standard cron module inputs. The role can add or remove cron jobs based on the provided configuration.

## Variables

| Variable Name                      | Default Value | Description                                                                 |
|------------------------------------|---------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_cron__list`       | `[]`          | A list of dictionaries defining cron jobs to be managed.                    |
| `bootstrap_linux_cron__state`      | `present`     | The state of the cron job (can be `present` or `absent`).                 |

## Usage

To use this role, define your cron jobs in the `bootstrap_linux_cron__list` variable. Each item in the list should be a dictionary with keys corresponding to the cron job parameters.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__list:
          - name: "Daily Backup"
            schedule: [0, 2, "*", "*", "*"]
            job: "/usr/local/bin/backup.sh"
            user: "root"
          - name: "Weekly Report"
            minute: "30"
            hour: "14"
            day: "*"
            month: "*"
            weekday: "0"
            job: "/usr/local/bin/report.sh"
            user: "admin"
```

## Dependencies

This role does not have any external dependencies.

## Tags

- `cron` - Manage cron jobs.

To run the role with a specific tag, use:

```bash
ansible-playbook playbook.yml --tags=cron
```

## Best Practices

1. **Use Descriptive Names**: Ensure that each cron job has a descriptive name for easier management.
2. **Specify Users**: Always specify the user under which the cron job should run to avoid permission issues.
3. **Backup Cron Files**: Use the `backup` parameter to create backups of existing cron files before making changes.

## Molecule Tests

This role does not currently include Molecule tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_cron/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_cron/tasks/main.yml)