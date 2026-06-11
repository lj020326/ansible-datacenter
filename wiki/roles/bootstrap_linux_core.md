---
title: "bootstrap_linux_core Role Documentation"
role: bootstrap_linux_core
category: Ansible Roles
type: Configuration Management
tags: linux, core, bootstrap, ansible

---

## Summary

The `bootstrap_linux_core` role is designed to perform essential system bootstrapping tasks on Linux systems. It includes configurations for DNS settings, environment variables, network interfaces, hostname setup, timezone configuration, and more. This role aims to provide a solid foundation for further system customization and deployment.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_core__setup_dns` | `true` | Enable DNS configuration setup. |
| `bootstrap_linux_core__dns_domain` | `example.int` | The domain name to be used in the resolver config. |
| `bootstrap_linux_core__dns_search_domains` | `[example.int]` | List of search domains for DNS resolution. |
| `bootstrap_linux_core__arch` | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"` | Architecture of the system, automatically detected. |
| `bootstrap_linux_core__figurine_version` | `"2.0.0"` | Version of Figurine to be installed. |
| `bootstrap_linux_core__figurine_url` | `"https://github.com/lj020326/figurine/releases/download/v{{ bootstrap_linux_core__figurine_version }}/figurine_linux_{{ bootstrap_linux_core__arch }}_v{{ bootstrap_linux_core__figurine_version }}.tar.gz"` | URL to download Figurine from. |
| `bootstrap_linux_core__default_path` | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` | Default PATH environment variable for all users. |
| `bootstrap_linux_core__init_netplan` | `false` | Enable Netplan configuration setup. |
| `bootstrap_linux_core__init_network_interfaces` | `false` | Enable network interfaces configuration setup. |
| `bootstrap_linux_core__restart_systemd` | `true` | Restart systemd services as needed. |
| `bootstrap_linux_core__stop_user_procs` | `true` | Stop user processes during certain tasks. |
| `bootstrap_linux_core__init_hosts_file` | `true` | Initialize the hosts file with necessary entries. |
| `bootstrap_linux_core__setup_figurine` | `true` | Setup Figurine on the system. |
| `bootstrap_linux_core__figurine_force_config` | `true` | Force configuration of Figurine even if it's already installed. |
| `bootstrap_linux_core__figurine_name` | `"{{ ansible_facts['hostname'] }}"` | Name to be used for Figurine configuration. |
| `bootstrap_linux_core__ansible_ssh_allowed_ips` | `[127.0.0.1]` | List of IPs allowed to SSH into the system. |
| `bootstrap_linux_core__network_name_servers` | `[192.168.0.1]` | List of DNS name servers. |
| `bootstrap_linux_core__set_timezone` | `true` | Enable timezone configuration setup. |
| `bootstrap_linux_core__timezone` | `America/New_York` | Timezone to be set on the system. |
| `bootstrap_linux_core__setup_hostname` | `true` | Enable hostname configuration setup. |
| `bootstrap_linux_core__hostname_internal_domain` | `example.int` | Internal domain for the hostname. |
| `bootstrap_linux_core__hostname_hosts_file_location` | `/etc/hosts` | Location of the hosts file to be configured. |
| `bootstrap_linux_core__hostname_hosts_backup` | `true` | Backup the hosts file before making changes. |
| `bootstrap_linux_core__hostname_name_full` | `"{{ inventory_hostname_short }}.{{ bootstrap_linux_core__hostname_internal_domain }}"` | Full hostname of the system. |
| `bootstrap_linux_core__hostname_name_short` | `"{{ inventory_hostname_short }}"` | Short hostname of the system. |
| `bootstrap_linux_core__hostname_hosts` | `[{"ip": "{{ ansible_facts['default_ipv4']['address'] }}", "name": "{{ bootstrap_linux_core__hostname_name_full }}", "aliases": ["{{ bootstrap_linux_core__hostname_name_short }}"]}]` | List of host entries to be added to the hosts file. |
| `bootstrap_linux_core__systemd_sysctl_execstart` | `/lib/systemd/systemd-sysctl` | Path to systemd-sysctl executable. |
| `bootstrap_linux_core__enable_rsyslog` | `false` | Enable rsyslog service setup. |
| `bootstrap_linux_core__setup_journald` | `true` | Setup journald for persistent logging. |
| `bootstrap_linux_core__setup_host_networks` | `true` | Setup host network configurations. |
| `bootstrap_linux_core__public_interface` | `"{{ ansible_facts['default_ipv4']['interface'] }}"` | Public network interface to be configured. |
| `bootstrap_linux_core__network` | `{ "network": { "version": 2, "renderer": "networkd", "ethernets": { "{{ bootstrap_linux_core__public_interface }}": { "dhcp4": true, "dhcp6": true, "dhcp-identifier": "mac" } } } }` | Netplan configuration for network interfaces. |
| `bootstrap_linux_core__setup_admin_scripts` | `true` | Setup administrative scripts on the system. |
| `bootstrap_linux_core__setup_backup_scripts` | `false` | Setup backup scripts on the system. |

## Usage

To use this role, include it in your playbook and optionally override any of the default variables as needed.

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_core
      vars:
        bootstrap_linux_core__dns_domain: mydomain.com
        bootstrap_linux_core__timezone: Europe/London
```

## Dependencies

This role does not have external dependencies, but it may include other roles such as `bootstrap_netplan` and `bootstrap_network_interfaces` if specified in the variables.

## Best Practices

- Always ensure that your inventory is up-to-date with the correct hostnames and IP addresses.
- Review and customize the default variables to match your specific environment requirements.
- Test changes in a staging environment before applying them to production systems.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios for testing different configurations and environments.

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