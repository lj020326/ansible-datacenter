---
title: Bootstrap NTP Role Documentation
role: bootstrap_ntp
category: System Configuration
type: Ansible Role
tags: ntp, chrony, timezone, synchronization

---

## Summary

The `bootstrap_ntp` role is designed to configure and manage Network Time Protocol (NTP) services on target systems. It supports both `ntpd` and `chronyd` daemons, allowing for flexible time synchronization across various Linux distributions. The role ensures that the system's timezone is set correctly and provides options to synchronize hardware clocks and test NTP configurations.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ntp__enabled`                | `true`                                                                        | Enables or disables the role's configuration of NTP services.                                                                                                                                             |
| `bootstrap_ntp__timezone`               | `Etc/UTC`                                                                     | Sets the system timezone.                                                                                                                                                                                   |
| `bootstrap_ntp__manage_config`          | `true`                                                                        | Determines whether to manage the NTP configuration file.                                                                                                                                                |
| `bootstrap_ntp__area`                   | `""`                                                                          | Specifies an area for NTP pool servers (e.g., "asia" for asia.pool.ntp.org).                                                                                                                               |
| `bootstrap_ntp__server_options`         | `iburst xleave`                                                               | Options to pass to the NTP server entries in the configuration file.                                                                                                                                      |
| `bootstrap_ntp__servers_default`        | <pre>\- 0{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 1{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 2{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 3{{ '.' + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org</pre> | Default NTP server pool entries.                                                                                                                                                                            |
| `bootstrap_ntp__peers`                  | `[]`                                                                          | List of peer servers to synchronize with.                                                                                                                                                                 |
| `bootstrap_ntp__restrict`               | <pre>\- 127.0.0.1<br>\- ::1</pre>                                             | Restrict access to the NTP service for specified IP addresses or networks.                                                                                                                                |
| `bootstrap_ntp__allow_networks`         | `[]`                                                                          | List of networks allowed to synchronize with the NTP server.                                                                                                                                              |
| `bootstrap_ntp__cron_handler_enabled`   | `false`                                                                       | Enables a handler to restart cron if the timezone changes.                                                                                                                                                |
| `bootstrap_ntp__tinker_panic`           | `false`                                                                       | Configures chrony to panic if the time difference is too large (chrony only).                                                                                                                             |
| `bootstrap_ntp__local_stratum_enabled`  | `false`                                                                       | Enables setting a local stratum value for chrony.                                                                                                                                                         |
| `bootstrap_ntp__local_stratum_conf`     | `"9"`                                                                         | Sets the local stratum value if enabled (chrony only).                                                                                                                                                    |
| `bootstrap_ntp__keys_enabled`           | `false`                                                                       | Enables key-based authentication for NTP (chrony only).                                                                                                                                                   |
| `bootstrap_ntp__keys_file`              | `/etc/chrony.keys`                                                            | Path to the keys file if key-based authentication is enabled (chrony only).                                                                                                                               |
| `bootstrap_ntp__leapsectz_enabled`      | `false`                                                                       | Enables leap second handling based on timezone data (chrony only).                                                                                                                                        |
| `bootstrap_ntp__cmdport_disabled`       | `false`                                                                       | Disables the command port for chrony.                                                                                                                                                                     |
| `bootstrap_ntp__log_info`               | `[]`                                                                          | Additional logging information to include in the configuration file.                                                                                                                                      |
| `bootstrap_ntp__role_action`            | `all`                                                                         | Specifies actions to perform (e.g., sync, test).                                                                                                                                                        |
| `bootstrap_ntp__chrony_waitsync`        | `true`                                                                        | Waits for chrony to synchronize time before proceeding.                                                                                                                                                   |
| `bootstrap_ntp__do_not_sync`            | `false`                                                                       | Prevents the role from performing any synchronization actions.                                                                                                                                            |
| `bootstrap_ntp__packages`               | <pre>\- ntp<br>\- ntpdate</pre>                                               | List of packages to install for NTP services.                                                                                                                                                             |

## Usage

To use this role, include it in your playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ntp
      vars:
        bootstrap_ntp__timezone: "America/New_York"
        bootstrap_ntp__servers_default:
          - 0.us.pool.ntp.org
          - 1.us.pool.ntp.org
```

## Dependencies

- `ansible.utils` collection for IP address manipulation.
- `community.general.timezone` module for setting the system timezone.

Ensure that these dependencies are installed in your Ansible environment:

```bash
ansible-galaxy collection install ansible.utils community.general
```

## Best Practices

1. **Timezone Configuration**: Always specify a valid timezone to ensure accurate timekeeping.
2. **Server Options**: Customize server options based on network conditions and security requirements.
3. **Restrictions**: Use the `bootstrap_ntp__restrict` variable to secure access to your NTP service.
4. **Testing**: Regularly test NTP synchronization to verify that your system is accurately synchronized.

## Molecule Tests

This role includes Molecule tests to validate its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

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