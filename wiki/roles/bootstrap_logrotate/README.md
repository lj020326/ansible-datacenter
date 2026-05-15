---
title: Ansible Role for logrotate
original_path: roles/bootstrap_logrotate/README.md
category: Ansible Roles
tags: [logrotate, ansible, configuration]
---

# Ansible Role: logrotate

## Description

This role installs and configures `logrotate` on target systems.

## Installation

To install this role using Ansible Galaxy, run the following command:

```bash
ansible-galaxy install ansible-datacenter.logrotate
```

## Requirements

- No specific requirements are needed for this role.

## Role Variables

### Include Files

Path to the include files directory.

```yaml
bootstrap_logrotate__include_dir: /etc/logrotate.d
```

### Global Configuration

Enable or disable global configuration of `/etc/logrotate.conf`.

```yaml
bootstrap_logrotate__global_config: true
```

### Hourly Rotation

Enable or disable hourly rotation using cron.

```yaml
bootstrap_logrotate__use_hourly_rotation: false
```

### Logrotate Options

List of global options for `logrotate`.

```yaml
bootstrap_logrotate__options:
  - weekly
  - rotate 4
  - create
  - dateext
  - su root syslog
```

### Package Name

Name of the package to install `logrotate`.

```yaml
bootstrap_logrotate__package: logrotate
```

### Default Configuration for wtmp and btmp

Configuration for `wtmp`:

```yaml
bootstrap_logrotate__wtmp_enable: true
bootstrap_logrotate__wtmp:
  logs:
    - /var/log/wtmp
  options:
    - missingok
    - monthly
    - create 0664 root utmp
    - rotate 1
```

Configuration for `btmp`:

```yaml
bootstrap_logrotate__btmp_enable: true
bootstrap_logrotate__btmp:
  logs:
    - /var/log/btmp
  options:
    - missingok
    - monthly
    - create 0660 root utmp
    - rotate 1
```

### Applications Configuration

Additional log files can be configured for `logrotate`.

```yaml
bootstrap_logrotate__applications: []
```

#### Example

Example configuration for additional applications:

```yaml
bootstrap_logrotate__applications:
  - name: name-your-log-rotate-application
    definitions:
      - logs:
          - /var/log/apt/term.log
          - /var/log/apt/history.log
        options:
          - su user group
          - rotate 12
          - monthly
          - missingok
          - notifempty
        postrotate:
          - /path/to/some/script
```

## Dependencies

- No dependencies are required for this role.

## Example Playbook

```yaml
- hosts: all
  roles:
    - bootstrap_logrotate
```

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [logrotate Man Page](https://linux.die.net/man/8/logrotate)

---