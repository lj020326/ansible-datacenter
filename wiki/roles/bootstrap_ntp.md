---
title: Bootstrap NTP Role Documentation
role: bootstrap_ntp
category: System Configuration
type: Ansible Role
tags: ntp, chrony, timezone, synchronization

---

## Summary

The `bootstrap_ntp` role is designed to configure Network Time Protocol (NTP) or Chrony on target systems. It manages the installation and configuration of NTP services, ensuring that system clocks are synchronized with specified NTP servers. The role also handles the management of timezones, service states, and synchronization options.

## Variables

| Variable Name                         | Default Value                                                                                             | Description                                                                                                                                                                                                 |
|---------------------------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ntp__enabled`              | `true`                                                                                                    | Enables or disables the NTP/Chrony configuration.                                                                                                                                                           |
| `bootstrap_ntp__timezone`             | `Etc/UTC`                                                                                                 | Sets the system timezone.                                                                                                                                                                                   |
| `bootstrap_ntp__manage_config`        | `true`                                                                                                    | Manages the NTP/Chrony configuration file.                                                                                                                                                                  |
| `bootstrap_ntp__area`                 | `""`                                                                                                      | Specifies the geographic area for NTP pool servers (e.g., "us").                                                                                                                                            |
| `bootstrap_ntp__server_options`       | `iburst xleave`                                                                                           | Options to be used with NTP server entries in the configuration file.                                                                                                                                       |
| `bootstrap_ntp__servers_default`      | <pre>\- 0{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 1{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 2{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 3{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org</pre> | Default NTP server pool entries.                                                                                                                                                                            |
| `bootstrap_ntp__peers`                | `[]`                                                                                                      | List of peer servers to be included in the configuration file.                                                                                                                                            |
| `bootstrap_ntp__restrict`             | <pre>\- 127.0.0.1<br>\- ::1</pre>                                                                         | Restrict access to NTP service from specified IP addresses or networks.                                                                                                                                   |
| `bootstrap_ntp__allow_networks`       | `[]`                                                                                                      | List of networks allowed to access the NTP service.                                                                                                                                                       |
| `bootstrap_ntp__cron_handler_enabled` | `false`                                                                                                   | Enables or disables cron handler restarts when timezone changes occur.                                                                                                                                    |
| `bootstrap_ntp__tinker_panic`         | `false`                                                                                                   | Enables or disables panic mode in Chrony configuration.                                                                                                                                                   |
| `bootstrap_ntp__local_stratum_enabled`| `false`                                                                                                   | Enables or disables local stratum configuration in NTP/Chrony.                                                                                                                                            |
| `bootstrap_ntp__local_stratum_conf`   | `"9"`                                                                                                     | Sets the local stratum value if enabled.                                                                                                                                                                    |
| `bootstrap_ntp__keys_enabled`         | `false`                                                                                                   | Enables or disables key authentication for NTP/Chrony.                                                                                                                                                  |
| `bootstrap_ntp__keys_file`            | `/etc/chrony.keys`                                                                                        | Path to the keys file used for authentication if enabled.                                                                                                                                                 |
| `bootstrap_ntp__leapsectz_enabled`    | `false`                                                                                                   | Enables or disables leap second correction based on timezone rules in Chrony.                                                                                                                             |
| `bootstrap_ntp__cmdport_disabled`     | `false`                                                                                                   | Disables the command port for NTP/Chrony if enabled.                                                                                                                                                      |
| `bootstrap_ntp__log_info`             | `[]`                                                                                                      | Additional log information to be included in the configuration file.                                                                                                                                      |
| `bootstrap_ntp__role_action`          | `all`                                                                                                     | Specifies actions to perform (e.g., sync, test).                                                                                                                                                          |
| `bootstrap_ntp__chrony_waitsync`      | `true`                                                                                                    | Waits for synchronization when using Chrony.                                                                                                                                                                |
| `bootstrap_ntp__do_not_sync`          | `false`                                                                                                   | Prevents the role from performing time synchronization if enabled.                                                                                                                                        |

## Usage

To use the `bootstrap_ntp` role, include it in your playbook and configure the necessary variables as needed. Here is an example:

```yaml
- name: Configure NTP on servers
  hosts: all
  roles:
    - role: bootstrap_ntp
      vars:
        bootstrap_ntp__timezone: "America/New_York"
        bootstrap_ntp__area: "us"
```

## Dependencies

This role does not have any external dependencies other than the Ansible control node and target systems having access to package repositories for NTP/Chrony packages.

## Best Practices

- Ensure that the `bootstrap_ntp__timezone` is set correctly according to your server's location.
- Use the `bootstrap_ntp__area` variable to specify a geographic area for more accurate time synchronization.
- Review and adjust the `bootstrap_ntp__restrict` and `bootstrap_ntp__allow_networks` variables to secure access to the NTP service.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ntp/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_ntp/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_ntp/tasks/main.yml)
- [tasks/sync-chrony.yml](../../roles/bootstrap_ntp/tasks/sync-chrony.yml)
- [tasks/sync-ntp.yml](../../roles/bootstrap_ntp/tasks/sync-ntp.yml)
- [tasks/test-chrony.yml](../../roles/bootstrap_ntp/tasks/test-chrony.yml)
- [tasks/test-ntp.yml](../../roles/bootstrap_ntp/tasks/test-ntp.yml)
- [handlers/main.yml](../../roles/bootstrap_ntp/handlers/main.yml)