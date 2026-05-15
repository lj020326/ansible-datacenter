---
title: Bootstrap HDDTemp Role Documentation
role: bootstrap_hddtemp
category: System Management
type: Ansible Role
tags: hddtemp, system, monitoring
---

## Summary

The `bootstrap_hddtemp` role is designed to install and configure the `hddtemp` service on Debian-based Linux distributions. This service provides a way to monitor the temperature of hard disk drives via S.M.A.R.T. data.

## Variables

| Variable Name                   | Default Value                          | Description                                                                 |
|---------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `hddtemp_packages`              | `['hddtemp']`                          | List of packages to install for HDD temperature monitoring.                 |
| `hddtemp_configuration_template`| `hddtemp.conf.j2`                      | Template file used for generating the hddtemp configuration.                |
| `hddtemp_template_configuration`| `true`                                 | Whether to template the hddtemp configuration file.                         |
| `hddtemp_configuration_dir`     | `/etc/default/`                        | Directory where the hddtemp configuration file will be placed.              |
| `hddtemp_start_service`         | `true`                                 | Whether to start and enable the hddtemp service.                            |
| `hddtemp_daemon`                | `"true"`                               | Daemon mode for hddtemp (set as a string).                                    |
| `hddtemp_disks_probed`          |                                        | List of disks to be probed by hddtemp.                                      |
| `hddtemp_disks_noprobe`         | `""`                                   | Disks that should not be probed by hddtemp.                                 |
| `hddtemp_interface`             | `0.0.0.0`                              | Network interface for the hddtemp daemon to listen on.                      |
| `hddtemp_port`                  | `7634`                                 | Port number for the hddtemp daemon to listen on.                            |
| `hddtemp_db_location`           |                                        | Location of the S.M.A.R.T. database file used by hddtemp.                   |
| `hddtemp_syslog_interval`       | `0`                                    | Interval in seconds between syslog messages about disk temperatures.        |
| `hddtemp_other_options`         | `""`                                   | Additional options to pass to the hddtemp command line.                     |

## Usage
To use this role, include it in your playbook and optionally override any of the default variables as needed.

```yaml
- hosts: all
  roles:
    - role: bootstrap_hddtemp
      vars:
        hddtemp_disks_probed: ['/dev/sda', '/dev/sdb']
        hddtemp_interface: '127.0.0.1'
```

## Dependencies
This role has no external dependencies.

## Tags
- `system`
- `hddtemp`

## Best Practices
- Ensure that the disks you want to monitor are correctly specified in the `hddtemp_disks_probed` variable.
- Adjust network settings (`hddtemp_interface`, `hddtemp_port`) according to your security requirements.
- Regularly check the logs and status of the hddtemp service to ensure it is functioning properly.

## Molecule Tests
This role does not include Molecule tests at this time. Consider adding them for automated testing in future updates.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_hddtemp/defaults/main.yml)
- [tasks/configure.yml](../../roles/bootstrap_hddtemp/tasks/configure.yml)
- [tasks/main.yml](../../roles/bootstrap_hddtemp/tasks/main.yml)
- [tasks/packages.yml](../../roles/bootstrap_hddtemp/tasks/packages.yml)
- [meta/main.yml](../../roles/bootstrap_hddtemp/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_hddtemp/handlers/main.yml)