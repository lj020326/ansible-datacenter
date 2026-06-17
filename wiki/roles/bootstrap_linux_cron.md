---
title: Bootstrap Linux Cron Role Documentation
role: bootstrap_linux_cron
category: Ansible Roles
type: Configuration Management
tags: ansible, cron, linux, automation
---

## Summary

The `bootstrap_linux_cron` role is designed to manage cron jobs on Linux systems. It allows users to define and configure cron jobs using a structured format, supports the creation of daily batch scripts, and ensures that specified cron job files are present or absent as required.

## Variables

| Variable Name                           | Default Value                | Description                                                                 |
|-----------------------------------------|------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_cron__list`            | `[]`                         | A list of dictionaries defining the cron jobs to be managed. Each dictionary can specify details like name, schedule, job command, user, etc. |
| `bootstrap_linux_cron__state`           | `present`                    | The desired state for the cron jobs (`present` or `absent`).                |
| `bootstrap_linux_cron__setup_daily_scripts` | `true`                     | A boolean flag indicating whether to set up daily batch scripts and directories. |

## Usage

To use this role, include it in your playbook and define the necessary variables. Here is an example of how to configure a simple cron job:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__list:
          - name: "Daily Backup"
            schedule: [0, 2, '*', '*', '*']  # Every day at 2 AM
            job: "/usr/local/bin/backup.sh"
            user: root
```

To remove a cron job, you can specify the state as `absent`:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__list:
          - name: "Daily Backup"
            schedule: [0, 2, '*', '*', '*']
            job: "/usr/local/bin/backup.sh"
            user: root
            state: absent
```

## Dependencies

This role does not have any external dependencies. It relies solely on Ansible's built-in modules.

## Best Practices

- **Consistent Naming**: Ensure that the names of your cron jobs are descriptive and unique to avoid conflicts.
- **State Management**: Use the `state` parameter to manage the presence or absence of cron jobs effectively.
- **User Specification**: Always specify the user under which the cron job should run, defaulting to `root` if not specified.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to write and execute Molecule tests to ensure the reliability and correctness of the role in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_cron/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_cron/tasks/main.yml)
- [tasks/setup-daily-scripts.yml](../../roles/bootstrap_linux_cron/tasks/setup-daily-scripts.yml)