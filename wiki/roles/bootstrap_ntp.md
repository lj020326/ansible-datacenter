---
title: "Bootstrap NTP Role Documentation"
role: bootstrap_ntp
category: Ansible Roles
type: Configuration Management
tags: ntp, chrony, timezone, synchronization
---

## Summary

The `bootstrap_ntp` role is designed to configure and manage Network Time Protocol (NTP) services on target systems. It supports both `chronyd` and `ntpd` daemons, allowing for flexible configuration of NTP servers, peers, restrictions, and other related settings. The role also includes mechanisms for timezone management, synchronization checks, and handling of system-specific configurations.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ntp__enabled`                | `true`                                                                        | Enable or disable the NTP service.                                                                                                                                                                          |
| `bootstrap_ntp__timezone`               | `Etc/UTC`                                                                     | Set the system timezone.                                                                                                                                                                                    |
| `bootstrap_ntp__manage_config`          | `true`                                                                        | Manage the NTP configuration file.                                                                                                                                                                        |
| `bootstrap_ntp__area`                   | `""`                                                                          | Specify an area for NTP server selection (e.g., `us` for North America).                                                                                                                                    |
| `bootstrap_ntp__server_options`         | `iburst xleave`                                                               | Options to use when configuring NTP servers.                                                                                                                                                                |
| `bootstrap_ntp__servers_default`        | `[0.pool.ntp.org, 1.pool.ntp.org, 2.pool.ntp.org, 3.pool.ntp.org]`           | Default list of NTP servers. The area is appended if specified.                                                                                                                                             |
| `bootstrap_ntp__peers`                  | `[]`                                                                          | List of NTP peers to configure.                                                                                                                                                                             |
| `bootstrap_ntp__restrict`               | `[127.0.0.1, ::1]`                                                            | List of IP addresses or networks to restrict access to the NTP service.                                                                                                                                     |
| `bootstrap_ntp__allow_networks`         | `[]`                                                                          | List of networks that are allowed to access the NTP service.                                                                                                                                              |
| `bootstrap_ntp__cron_handler_enabled`   | `false`                                                                       | Enable or disable the cron handler for restarting services.                                                                                                                                                 |
| `bootstrap_ntp__tinker_panic`           | `false`                                                                       | Enable or disable panic mode in chrony.                                                                                                                                                                   |
| `bootstrap_ntp__local_stratum_enabled`  | `false`                                                                       | Enable or disable local stratum configuration.                                                                                                                                                            |
| `bootstrap_ntp__local_stratum_conf`     | `"9"`                                                                         | Local stratum configuration value.                                                                                                                                                                        |
| `bootstrap_ntp__keys_enabled`           | `false`                                                                       | Enable or disable key-based authentication for NTP.                                                                                                                                                       |
| `bootstrap_ntp__keys_file`              | `/etc/chrony.keys`                                                            | Path to the file containing keys for NTP authentication.                                                                                                                                                |
| `bootstrap_ntp__leapsectz_enabled`      | `false`                                                                       | Enable or disable leap second handling in chrony.                                                                                                                                                         |
| `bootstrap_ntp__cmdport_disabled`       | `false`                                                                       | Disable the command port in chrony.                                                                                                                                                                       |
| `bootstrap_ntp__log_info`               | `[]`                                                                          | Additional log information to include in the NTP configuration.                                                                                                                                           |
| `bootstrap_ntp__role_action`            | `all`                                                                         | Define actions to perform (e.g., sync, test).                                                                                                                                                             |
| `bootstrap_ntp__chrony_waitsync`        | `true`                                                                        | Enable or disable waiting for synchronization in chrony.                                                                                                                                                |
| `bootstrap_ntp__do_not_sync`            | `false`                                                                       | Disable forced time synchronization.                                                                                                                                                                      |

## Usage

To use the `bootstrap_ntp` role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook

```yaml
- name: Configure NTP on servers
  hosts: all
  roles:
    - role: bootstrap_ntp
      vars:
        bootstrap_ntp__timezone: "America/New_York"
        bootstrap_ntp__servers_default:
          - 0.us.pool.ntp.org
          - 1.us.pool.ntp.org
          - 2.us.pool.ntp.org
          - 3.us.pool.ntp.org
```

## Dependencies

- `community.general` collection for the `timezone` module.
- `ansible.utils` collection for IP address manipulation.

Ensure these collections are installed in your Ansible environment:

```bash
ansible-galaxy collection install community.general ansible.utils
```

## Best Practices

1. **Timezone Configuration**: Always specify a valid timezone to ensure accurate timekeeping.
2. **NTP Server Selection**: Use geographically close NTP servers for better synchronization performance.
3. **Security Considerations**: Enable key-based authentication if your environment requires secure NTP communication.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems and configurations. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed in your environment:

```bash
pip install molecule
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