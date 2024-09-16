# Ansible Role: logrotate

## Description

Installs and configures logrotate.

## Installation

```bash
  ansible-galaxy install ansible-datacenter.logrotate
```

## Requirements

None.

## Role Variables

### include files

Path to the include files.

```yml
bootstrap_logrotate__include_dir: /etc/logrotate.d
```

### bootstrap_logrotate__global_config

Enable/disable global configuration of `/etc/logrotate.conf`.

```yml
bootstrap_logrotate__global_config: true
```

### bootstrap_logrotate__use_hourly_rotation

Enable/disable hourly rotation with cron.

```yml
bootstrap_logrotate__use_hourly_rotation: false
```

### logrotate options

List of global options.

```yml
bootstrap_logrotate__options:
  - weekly
  - rotate 4
  - create
  - dateext
  - su root syslog
```

### Package

Package name to install `logrotate`.

```yml
bootstrap_logrotate__package: logrotate
```

### default config

Logrotate for `wtmp`:

```yml
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

Logrotate for `btmp`:

```yml
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

### Applications config

More log files can be added that will logorate.

```yml
bootstrap_logrotate__applications: []
```

#### Example

The following options are available.

```yml
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

None

## Example Playbook

```yml
- hosts: all
  roles:
    - bootstrap_logrotate
```
