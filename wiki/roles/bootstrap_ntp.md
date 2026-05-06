---
title: "Bootstrap NTP Role Documentation"
role: bootstrap_ntp
category: Ansible Roles
type: Configuration Management
tags: ntp, chrony, timezone, synchronization

---

## Summary

The `bootstrap_ntp` role is designed to configure Network Time Protocol (NTP) or Chrony on a system. It manages the installation and configuration of NTP/Chrony services, sets the system timezone, and ensures that the system time is synchronized with specified NTP servers. The role also includes options for managing configuration files, handling cron jobs, and performing synchronization tests.

## Variables

The following variables can be configured in `defaults/main.yml` to customize the behavior of the `bootstrap_ntp` role:

| Variable Name                         | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ntp__enabled`              | `true`                                                                                            | Enable or disable NTP/Chrony configuration.                                                                                                                                                                 |
| `bootstrap_ntp__timezone`             | `Etc/UTC`                                                                                       | Set the system timezone.                                                                                                                                                                                    |
| `bootstrap_ntp__manage_config`        | `true`                                                                                            | Manage the NTP/Chrony configuration file.                                                                                                                                                                   |
| `bootstrap_ntp__area`                 | `""`                                                                                              | Specify an area for NTP pool servers (e.g., "us" for North America).                                                                                                                                         |
| `bootstrap_ntp__server_options`       | `iburst xleave`                                                                                 | Options to be used with NTP/Chrony server entries.                                                                                                                                                            |
| `bootstrap_ntp__servers_default`      | <pre>\- 0{{ '. + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 1{{ '. + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 2{{ '. + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org<br>\- 3{{ '. + bootstrap_ntp__area if bootstrap_ntp__area else '' }}.pool.ntp.org</pre> | Default NTP server pool entries.                                                                                                                                                                            |
| `bootstrap_ntp__peers`                | `[]`                                                                                            | List of peer servers for synchronization.                                                                                                                                                                   |
| `bootstrap_ntp__restrict`             | <pre>\- 127.0.0.1<br>\- ::1</pre>                                                                | Restrict access to the NTP/Chrony service (e.g., allow only localhost).                                                                                                                                     |
| `bootstrap_ntp__allow_networks`       | `[]`                                                                                            | List of networks allowed to synchronize with the NTP/Chrony server.                                                                                                                                         |
| `bootstrap_ntp__cron_handler_enabled` | `false`                                                                                           | Enable or disable cron handler for NTP/Chrony synchronization.                                                                                                                                            |
| `bootstrap_ntp__tinker_panic`         | `false`                                                                                           | Enable or disable the panic option in Chrony configuration.                                                                                                                                                 |
| `bootstrap_ntp__local_stratum_enabled`| `false`                                                                                           | Enable or disable local stratum configuration for NTP/Chrony.                                                                                                                                             |
| `bootstrap_ntp__local_stratum_conf`   | `"9"`                                                                                             | Local stratum value if enabled.                                                                                                                                                                             |
| `bootstrap_ntp__keys_enabled`         | `false`                                                                                           | Enable or disable key authentication in Chrony configuration.                                                                                                                                             |
| `bootstrap_ntp__keys_file`            | `/etc/chrony.keys`                                                                              | Path to the keys file for Chrony key authentication.                                                                                                                                                        |
| `bootstrap_ntp__leapsectz_enabled`    | `false`                                                                                           | Enable or disable leap second handling in Chrony configuration.                                                                                                                                           |
| `bootstrap_ntp__cmdport_disabled`     | `false`                                                                                           | Disable the command port for NTP/Chrony service.                                                                                                                                                            |
| `bootstrap_ntp__log_info`             | `[]`                                                                                            | Additional log information to be included in the NTP/Chrony configuration.                                                                                                                                |
| `bootstrap_ntp__role_action`          | `all`                                                                                             | Define actions to perform (e.g., all, sync, test).                                                                                                                                                        |
| `bootstrap_ntp__chrony_waitsync`      | `true`                                                                                            | Enable or disable waiting for synchronization in Chrony.                                                                                                                                                    |
| `bootstrap_ntp__do_not_sync`          | `false`                                                                                           | Disable automatic time synchronization.                                                                                                                                                                     |

## Usage

To use the `bootstrap_ntp` role, include it in your playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ntp
      vars:
        bootstrap_ntp__timezone: "America/New_York"
        bootstrap_ntp__area: "us"
```

## Dependencies

The `bootstrap_ntp` role depends on the following collections and modules:

- `ansible.builtin`
- `community.general.timezone`
- `ansible.utils.ipaddr`

Ensure these are installed in your Ansible environment.

## Tags

The `bootstrap_ntp` role uses the following tags to control task execution:

- `ntp`: Manage NTP/Chrony configuration.
- `timezone`: Set system timezone.
- `sync`: Perform time synchronization.
- `test`: Run tests for NTP/Chrony synchronization.

Example usage with tags:

```bash
ansible-playbook playbook.yml --tags ntp,timezone
```

## Best Practices

1. **Backup Configuration Files**: The role creates backups of existing configuration files before making changes.
2. **Conditional Execution**: Use the `bootstrap_ntp__enabled` variable to conditionally enable or disable NTP/Chrony configuration.
3. **Customization**: Customize variables in `defaults/main.yml` or override them in your playbook for specific configurations.

## Molecule Tests

The `bootstrap_ntp` role includes Molecule tests to verify its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

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