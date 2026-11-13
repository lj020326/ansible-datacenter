---
title: "Bootstrap Linux Cron Role"
role: bootstrap_linux_cron
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_cron]
---

```yaml
title: Bootstrap Linux Cron Role
role: bootstrap_linux_cron
category: Roles
type: ansible-role
summary: |
  The `bootstrap_linux_cron` role is designed to manage cron jobs on Linux systems. It allows users to define cron jobs using either a schedule array format or standard module inputs, and provides flexibility in specifying job parameters like name, state, user, and more. The role also handles the removal of cron job files when required.
```

## Variables

| Variable Name                | Default Value | Description                                                                 |
|------------------------------|---------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_cron__list` | `[]`          | A list of cron jobs to be managed. Each item in the list can have various attributes like `name`, `state`, `schedule`, `job`, etc. |
| `bootstrap_linux_cron__state`| `present`     | The desired state of the cron jobs (`present` or `absent`).                  |

## Usage

To use the `bootstrap_linux_cron` role, include it in your playbook and define the cron jobs you want to manage in the `bootstrap_linux_cron__list` variable. Each cron job can be defined with various attributes as shown in the example below:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_linux_cron
      vars:
        bootstrap_linux_cron__list:
          - name: "Example Job"
            state: "present"
            schedule:
              - "0"
              - "2"
              - "*"
              - "*"
              - "*"
            job: "/path/to/command"
            user: "root"
            cron_file: "example_cron"
```

## Dependencies

This role does not have any external dependencies. It uses the `ansible.builtin.cron` module, which is included in Ansible by default.

## Best Practices

- Always specify a unique `name` for each cron job to avoid conflicts.
- Use the `cron_file` attribute to group related cron jobs together.
- Define cron jobs with the most specific schedule possible to avoid unnecessary executions.
- Regularly review and update the cron jobs to ensure they are still needed and functioning as expected.