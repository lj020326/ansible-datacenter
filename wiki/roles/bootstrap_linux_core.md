---
title: Bootstrap Linux Core Role Documentation
role: bootstrap_linux_core
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_linux_core` role is designed to perform essential system bootstrapping tasks on Linux systems. It covers a wide range of configurations including DNS setup, environment variables configuration, hostname management, network interfaces initialization, journald settings, timezone configuration, and more. This role ensures that the target machines are configured consistently according to best practices.

## Variables

Below is a table detailing the configurable variables within this role:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_core__setup_dns` | `true` | Whether to configure DNS settings. |
| `bootstrap_linux_core__dns_domain` | `example.int` | The domain name for DNS configuration. |
| `bootstrap_linux_core__dns_search_domains` | `[example.int]` | List of search domains for DNS resolution. |
| `bootstrap_linux_core__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | Architecture of the system (automatically detected). |
| `bootstrap_linux_core__figurine_version` | `"2.0.0"` | Version of Figurine to install. |
| `bootstrap_linux_core__figurine_url` | `"https://github.com/lj020326/figurine/releases/download/v{{ bootstrap_linux_core__figurine_version }}/figurine_linux_{{ bootstrap_linux_core__arch }}_v{{ bootstrap_linux_core__figurine_version }}.tar.gz"` | URL to download Figurine from. |
| `bootstrap_linux_core__default_path` | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` | Default PATH environment variable for all users. |
| `bootstrap_linux_core__init_netplan` | `false` | Whether to initialize Netplan configuration. |
| `bootstrap_linux_core__init_network_interfaces` | `false` | Whether to initialize network interfaces manually. |
| `bootstrap_linux_core__restart_systemd` | `true` | Whether to restart systemd services as needed. |
| `bootstrap_linux_core__stop_user_procs` | `true` | Whether to stop user processes during certain tasks. |
| `bootstrap_linux_core__init_hosts_file` | `true` | Whether to initialize the `/etc/hosts` file. |
| `bootstrap_linux_core__setup_figurine` | `true` | Whether to install and configure Figurine. |
| `bootstrap_linux_core__figurine_force_config` | `true` | Whether to force configuration of Figurine even if already installed. |
| `bootstrap_linux_core__figurine_name` | `"{{ ansible_facts['hostname'] }}"` | Name for Figurine configuration. |
| `bootstrap_linux_core__ansible_ssh_allowed_ips` | `[127.0.0.1]` | List of IPs allowed to SSH into the system. |
| `bootstrap_linux_core__network_name_servers` | `[192.168.0.1]` | List of DNS name servers. |
| `bootstrap_linux_core__set_timezone` | `true` | Whether to set the timezone. |
| `bootstrap_linux_core__timezone` | `America/New_York` | Timezone to be configured on the system. |
| `bootstrap_linux_core__setup_hostname` | `true` | Whether to configure hostname settings. |
| `bootstrap_linux_core__hostname_internal_domain` | `example.int` | Internal domain for hostname configuration. |
| `bootstrap_linux_core__hostname_hosts_file_location` | `/etc/hosts` | Location of the hosts file. |
| `bootstrap_linux_core__hostname_hosts_backup` | `true` | Whether to backup the hosts file before modification. |
| `bootstrap_linux_core__hostname_name_full` | `"{{ inventory_hostname_short }}.{{ bootstrap_linux_core__hostname_internal_domain }}"` | Full hostname. |
| `bootstrap_linux_core__hostname_name_short` | `"{{ inventory_hostname_short }}"` | Short hostname. |
| `bootstrap_linux_core__hostname_hosts` | `[ { ip: "{{ ansible_facts['default_ipv4']['address'] }}", name: "{{ bootstrap_linux_core__hostname_name_full }}", aliases: [ "{{ bootstrap_linux_core__hostname_name_short }}" ] } ]` | Host entries to be added to the hosts file. |
| `bootstrap_linux_core__systemd_sysctl_execstart` | `/lib/systemd/systemd-sysctl` | Path to systemd-sysctl executable. |
| `bootstrap_linux_core__enable_rsyslog` | `false` | Whether to enable rsyslog service. |
| `bootstrap_linux_core__setup_journald` | `true` | Whether to configure journald settings. |
| `bootstrap_linux_core__setup_host_networks` | `true` | Whether to setup host networks. |
| `bootstrap_linux_core__public_interface` | `"{{ ansible_facts['default_ipv4']['interface'] }}"` | Public network interface name. |
| `bootstrap_linux_core__network` | `{ network: { version: 2, renderer: networkd, ethernets: { "{{ bootstrap_linux_core__public_interface }}": { dhcp4: true, dhcp6: true, dhcp-identifier: mac } } } }` | Netplan configuration for the public interface. |
| `bootstrap_linux_core__setup_admin_scripts` | `true` | Whether to setup admin scripts. |
| `bootstrap_linux_core__setup_backup_scripts` | `false` | Whether to setup backup scripts. |

## Usage

To use this role, include it in your playbook and optionally override the default variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_core
      vars:
        bootstrap_linux_core__dns_domain: mydomain.com
        bootstrap_linux_core__timezone: Europe/London
```

## Dependencies

This role does not have any external dependencies, but it includes other roles conditionally:

- `bootstrap_netplan` (included when `bootstrap_linux_core__init_netplan` is true)
- `bootstrap_network_interfaces` (included when `bootstrap_linux_core__init_network_interfaces` is true)

## Best Practices

1. **Backup Configuration Files:** Ensure that any configuration files being modified are backed up before changes are made.
2. **Test Changes:** Always test changes in a staging environment before applying them to production systems.
3. **Review Logs:** Regularly review logs and system status to ensure that the configurations are applied correctly.

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