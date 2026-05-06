---
title: Bootstrap Linux Core Role Documentation
role: bootstrap_linux_core
category: System Configuration
type: Ansible Role
tags: linux, core, configuration, dns, hostname, journald, timezone, scripts

---

## Summary

The `bootstrap_linux_core` role is designed to perform essential system configurations on Linux hosts. It covers various aspects such as DNS setup, environment variable configuration, hostname management, journald settings, timezone adjustment, and script installations. This role ensures that the target systems are properly configured for optimal performance and security.

## Variables

| Variable Name                                    | Default Value                                                                                      | Description                                                                                                                                                                                                 |
|--------------------------------------------------|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_core__setup_dns`                | `true`                                                                                             | Whether to configure DNS settings.                                                                                                                                                                          |
| `bootstrap_linux_core__dns_domain`               | `example.int`                                                                                      | The domain name for DNS configuration.                                                                                                                                                                      |
| `bootstrap_linux_core__dns_search_domains`       | `["example.int"]`                                                                                  | List of search domains for DNS resolution.                                                                                                                                                                    |
| `bootstrap_linux_core__default_path`             | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`                                     | The default PATH environment variable to be set for all users.                                                                                                                                                |
| `bootstrap_linux_core__init_netplan`             | `false`                                                                                            | Whether to initialize Netplan configuration.                                                                                                                                                                |
| `bootstrap_linux_core__init_network_interfaces`  | `false`                                                                                            | Whether to initialize network interfaces manually.                                                                                                                                                            |
| `bootstrap_linux_core__restart_systemd`          | `true`                                                                                             | Whether to restart systemd services after configuration changes.                                                                                                                                                |
| `bootstrap_linux_core__stop_user_procs`          | `true`                                                                                             | Whether to stop user processes during system reboots or restarts.                                                                                                                                             |
| `bootstrap_linux_core__init_hosts_file`          | `true`                                                                                             | Whether to configure the `/etc/hosts` file.                                                                                                                                                                 |
| `bootstrap_linux_core__setup_figurine`           | `true`                                                                                             | Whether to install and configure figurine, a tool for managing user logins.                                                                                                                                   |
| `bootstrap_linux_core__figurine_force_config`    | `true`                                                                                             | Whether to force reconfiguration of figurine settings.                                                                                                                                                      |
| `bootstrap_linux_core__figurine_name`            | `"{{ ansible_facts['hostname'] }}"`                                                                  | The name to be used for configurine figurine.                                                                                                                                                                 |
| `bootstrap_linux_core__ansible_ssh_allowed_ips`  | `["127.0.0.1"]`                                                                                    | List of IP addresses allowed to SSH into the system.                                                                                                                                                          |
| `bootstrap_linux_core__network_name_servers`     | `["192.168.0.1"]`                                                                                  | List of DNS name servers.                                                                                                                                                                                   |
| `bootstrap_linux_core__set_timezone`             | `true`                                                                                             | Whether to set the system timezone.                                                                                                                                                                         |
| `bootstrap_linux_core__timezone`                 | `America/New_York`                                                                                 | The timezone to be set for the system.                                                                                                                                                                      |
| `bootstrap_linux_core__setup_hostname`           | `true`                                                                                             | Whether to configure the hostname of the system.                                                                                                                                                              |
| `bootstrap_linux_core__hostname_internal_domain` | `example.int`                                                                                      | The internal domain name to be used in the hostname configuration.                                                                                                                                          |
| `bootstrap_linux_core__hostname_hosts_file_location` | `/etc/hosts`                                                                                       | Location of the hosts file to be configured.                                                                                                                                                                |
| `bootstrap_linux_core__hostname_hosts_backup`    | `true`                                                                                             | Whether to backup the existing hosts file before making changes.                                                                                                                                            |
| `bootstrap_linux_core__hostname_name_full`       | `"{{ inventory_hostname_short }}.{{ bootstrap_linux_core__hostname_internal_domain }}"`            | The full hostname of the system.                                                                                                                                                                            |
| `bootstrap_linux_core__hostname_name_short`      | `"{{ inventory_hostname_short }}"`                                                                   | The short hostname of the system.                                                                                                                                                                           |
| `bootstrap_linux_core__hostname_hosts`           | `[{"ip": "{{ ansible_facts['default_ipv4']['address'] }}", "name": "{{ bootstrap_linux_core__hostname_name_full }}", "aliases": ["{{ bootstrap_linux_core__hostname_name_short }}"]}]` | List of host entries to be added to the hosts file.                                                                                                                                                         |
| `bootstrap_linux_core__systemd_sysctl_execstart` | `/lib/systemd/systemd-sysctl`                                                                        | Path to the systemd sysctl executable.                                                                                                                                                                      |
| `bootstrap_linux_core__enable_rsyslog`           | `false`                                                                                            | Whether to enable and configure rsyslog.                                                                                                                                                                    |
| `bootstrap_linux_core__setup_journald`           | `true`                                                                                             | Whether to configure journald for persistent logging.                                                                                                                                                       |
| `bootstrap_linux_core__setup_host_networks`      | `true`                                                                                             | Whether to set up host network configurations using Netplan or manual interfaces.                                                                                                                           |
| `bootstrap_linux_core__public_interface`         | `"{{ ansible_facts['default_ipv4']['interface'] }}"`                                                 | The public network interface to be configured.                                                                                                                                                                |
| `bootstrap_linux_core__network`                  | `{ "network": { "version": 2, "renderer": "networkd", "ethernets": { "{{ bootstrap_linux_core__public_interface }}": { "dhcp4": true, "dhcp6": true, "dhcp-identifier": "mac" } } } }` | Netplan configuration for the public network interface.                                                                                                                                                   |
| `bootstrap_linux_core__setup_admin_scripts`      | `true`                                                                                             | Whether to install and configure administrative scripts.                                                                                                                                                    |
| `bootstrap_linux_core__setup_backup_scripts`     | `false`                                                                                            | Whether to install and configure backup scripts.                                                                                                                                                            |
| `bootstrap_linux_core__admin_script_dir`         | `/opt/scripts`                                                                                     | Directory where administrative scripts will be installed.                                                                                                                                                   |
| `bootstrap_linux_core__admin_log_dir`            | `/var/log/admin`                                                                                   | Directory for logs related to administrative scripts.                                                                                                                                                       |
| `bootstrap_linux_core__backup_script_dir`        | `/opt/scripts`                                                                                     | Directory where backup scripts will be installed.                                                                                                                                                           |
| `bootstrap_linux_core__fwbackups_dir`            | `/srv/backups/fwbackups`                                                                           | Directory for firewall backups.                                                                                                                                                                             |
| `bootstrap_linux_core__backups_dir`              | `/srv/backups`                                                                                     | Directory for general system backups.                                                                                                                                                                       |
| `bootstrap_linux_core__backups_log_dir`          | `/var/log/backups`                                                                                 | Directory for logs related to backup scripts.                                                                                                                                                               |
| `bootstrap_linux_core__backups_email_from`       | `"admin@example.com"`                                                                              | Email address used as the sender in backup notifications.                                                                                                                                                 |

## Usage

To use this role, include it in your Ansible playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_core
      vars:
        bootstrap_linux_core__dns_domain: mydomain.com
        bootstrap_linux_core__timezone: Europe/London
```

## Dependencies

This role does not have any external dependencies. However, it includes tasks that may require certain packages to be installed on the target system (e.g., `rsyslog`, `figurine`). These will be installed if they are not already present.

## Tags

- `dns`: Configures DNS settings.
- `hostname`: Sets up hostname and `/etc/hosts` file.
- `journald`: Configures journald for persistent logging.
- `timezone`: Sets the system timezone.
- `scripts`: Installs administrative and backup scripts.
- `network`: Configures network interfaces using Netplan or manual setup.

## Best Practices

- Always back up important configuration files before running this role, especially if you are modifying DNS settings or hostnames.
- Ensure that the specified directories for scripts and logs exist and have appropriate permissions.
- Test changes in a non-production environment to verify that they do not disrupt system functionality.

## Molecule Tests

This role includes Molecule tests to ensure its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_core/defaults/main.yml)
- [tasks/dns.yml](../../roles/bootstrap_linux_core/tasks/dns.yml)
- [tasks/env.yml](../../roles/bootstrap_linux_core/tasks/env.yml)
- [tasks/figurine.yml](../../roles/bootstrap_linux_core/tasks/figurine.yml)
- [tasks/host-networks.yml](../../roles/bootstrap_linux_core/tasks/host-networks.yml)
- [tasks/hostname.yml](../../roles/bootstrap_linux_core/tasks/hostname.yml)
- [tasks/journald.yml](../../roles/bootstrap_linux_core/tasks/journald.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_core/tasks/main.yml)
- [tasks/motd.yml](../../roles/bootstrap_linux_core/tasks/motd.yml)
- [tasks/setup-admin-scripts.yml](../../roles/bootstrap_linux_core/tasks/setup-admin-scripts.yml)
- [tasks/setup-backup-scripts.yml](../../roles/bootstrap_linux_core/tasks/setup-backup-scripts.yml)
- [tasks/sysctl.yml](../../roles/bootstrap_linux_core/tasks/sysctl.yml)
- [tasks/timezone.yml](../../roles/bootstrap_linux_core/tasks/timezone.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_core/handlers/main.yml)