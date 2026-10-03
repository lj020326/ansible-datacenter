---
title: "Ansible Role - bootstrap_hddtemp"
role: roles/bootstrap_hddtemp
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_hddtemp]
---

# Ansible Role - bootstrap_hddtemp

This Ansible role installs and configures `hddtemp` on Debian-based Linux distributions. `hddtemp` is a utility that monitors the temperature of hard drives and provides this information via a network interface.

## Variables

| Variable Name                  | Default Value           | Description                                                                 |
|--------------------------------|-------------------------|-----------------------------------------------------------------------------|
| `hddtemp_packages`             | `['hddtemp']`           | List of packages to install for `hddtemp`                                    |
| `hddtemp_configuration_template`| `hddtemp.conf.j2`       | Template file for `hddtemp` configuration                                     |
| `hddtemp_template_configuration`| `true`                  | Whether to template the `hddtemp` configuration                               |
| `hddtemp_configuration_dir`    | `/etc/default/`         | Directory where the `hddtemp` configuration file is stored                   |
| `hddtemp_start_service`        | `true`                  | Whether to start the `hddtemp` service                                        |
| `hddtemp_daemon`               | `"true"`                | Whether to run `hddtemp` as a daemon                                          |
| `hddtemp_disks_probed`         |                         | List of disks to probe for temperature                                        |
| `hddtemp_disks_noprobe`        | `""`                    | List of disks to not probe for temperature                                    |
| `hddtemp_interface`            | `0.0.0.0`               | Network interface to listen on for `hddtemp`                                  |
| `hddtemp_port`                 | `7634`                  | Port number for `hddtemp` to listen on                                        |
| `hddtemp_db_location`          |                         | Location of the database file                                                 |
| `hddtemp_syslog_interval`      | `0`                     | Interval for logging to syslog                                                |
| `hddtemp_other_options`        | `""`                    | Additional options for `hddtemp`                                              |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_hddtemp
      vars:
        hddtemp_disks_probed:
          - /dev/sda
          - /dev/sdb
        hddtemp_interface: "127.0.0.1"
        hddtemp_port: 7635
```

## Dependencies

This role does not have any dependencies.

## Best Practices

- Ensure that the `hddtemp` service is enabled and started after configuration.
- Regularly monitor the temperature of your hard drives to prevent overheating.
- Customize the `hddtemp` configuration to suit your specific needs and environment.
- Verify that the `hddtemp` service is running correctly by checking its status.
- Review the `hddtemp` logs for any errors or warnings.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_hddtemp/defaults/main.yml)
- [tasks/configure.yml](../../roles/bootstrap_hddtemp/tasks/configure.yml)
- [tasks/main.yml](../../roles/bootstrap_hddtemp/tasks/main.yml)
- [tasks/packages.yml](../../roles/bootstrap_hddtemp/tasks/packages.yml)
- [meta/main.yml](../../roles/bootstrap_hddtemp/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_hddtemp/handlers/main.yml)