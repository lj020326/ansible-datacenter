---
title: Bootstrap Linux Core Role Documentation
role: bootstrap_linux_core
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_linux_core` role is designed to perform essential system bootstrapping tasks on Linux hosts, ensuring that core configurations such as DNS settings, environment variables, hostname, network interfaces, and system logging are properly set up. This role aims to provide a solid foundation for further system configuration and management.

## Variables

Below is a comprehensive list of the configurable variables within this role:

| Variable Name                               | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|---------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_core__setup_dns`           | `true`                                                                                                | Whether to configure DNS settings.                                                                                                                                                                          |
| `bootstrap_linux_core__dns_domain`          | `example.int`                                                                                       | The primary domain name for DNS configuration.                                                                                                                                                              |
| `bootstrap_linux_core__dns_search_domains`  | `['example.int']`                                                                                    | List of domains to search in the order they are listed.                                                                                                                                                     |
| `bootstrap_linux_core__arch`                | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                                    | System architecture, automatically detected based on Ansible facts.                                                                                                                                         |
| `bootstrap_linux_core__figurine_version`    | `"2.0.0"`                                                                                             | Version of the Figurine tool to be installed.                                                                                                                                                               |
| `bootstrap_linux_core__figurine_url`        | `"https://github.com/lj020326/figurine/releases/download/v{{ bootstrap_linux_core__figurine_version }}/figurine_linux_{{ bootstrap_linux_core__arch }}_v{{ bootstrap_linux_core__figurine_version }}.tar.gz"` | URL to download the Figurine tool based on version and architecture.                                                                                                                                      |
| `bootstrap_linux_core__default_path`        | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`                                        | Default PATH environment variable for all users.                                                                                                                                                            |
| `bootstrap_linux_core__init_netplan`        | `false`                                                                                               | Whether to initialize Netplan configuration.                                                                                                                                                              |
| `bootstrap_linux_core__init_network_interfaces` | `false`                                                                                            | Whether to initialize network interfaces using a different method (e.g., `/etc/network/interfaces`).                                                                                                      |
| `bootstrap_linux_core__restart_systemd`     | `true`                                                                                                | Whether to restart systemd services after configuration changes.                                                                                                                                            |
| `bootstrap_linux_core__stop_user_procs`     | `true`                                                                                                | Whether to stop user processes during system reboots or restarts.                                                                                                                                         |
| `bootstrap_linux_core__init_hosts_file`     | `true`                                                                                                | Whether to initialize the `/etc/hosts` file with hostnames and IP addresses.                                                                                                                              |
| `bootstrap_linux_core__setup_figurine`      | `true`                                                                                                | Whether to install and configure the Figurine tool.                                                                                                                                                       |
| `bootstrap_linux_core__figurine_force_config` | `true`                                                                                              | Whether to force reconfiguration of Figurine even if it is already installed.                                                                                                                             |
| `bootstrap_linux_core__figurine_name`       | `"{{ ansible_facts['hostname'] }}"`                                                                    | Name used for Figurine configuration, defaults to the current hostname.                                                                                                                                   |
| `bootstrap_linux_core__ansible_ssh_allowed_ips` | `['127.0.0.1']`                                                                                    | List of IP addresses allowed to connect via SSH.                                                                                                                                                            |
| `bootstrap_linux_core__network_name_servers`| `['192.168.0.1']`                                                                                    | List of DNS name servers.                                                                                                                                                                                   |
| `bootstrap_linux_core__set_timezone`        | `true`                                                                                                | Whether to set the system timezone.                                                                                                                                                                         |
| `bootstrap_linux_core__timezone`            | `America/New_York`                                                                                  | Timezone to be configured on the system.                                                                                                                                                                    |
| `bootstrap_linux_core__setup_hostname`      | `true`                                                                                                | Whether to configure the hostname and update `/etc/hosts`.                                                                                                                                                |
| `bootstrap_linux_core__hostname_internal_domain` | `example.int`                                                                                    | Internal domain name for hostnames.                                                                                                                                                                         |
| `bootstrap_linux_core__hostname_hosts_file_location` | `/etc/hosts`                                                                                 | Location of the hosts file to be updated.                                                                                                                                                                   |
| `bootstrap_linux_core__hostname_hosts_backup` | `true`                                                                                              | Whether to create a backup of the hosts file before updating it.                                                                                                                                          |
| `bootstrap_linux_core__hostname_name_full`  | `"{{ inventory_hostname_short }}.{{ bootstrap_linux_core__hostname_internal_domain }}"`             | Full hostname including domain.                                                                                                                                                                             |
| `bootstrap_linux_core__hostname_name_short` | `"{{ inventory_hostname_short }}"`                                                                    | Short hostname without the domain.                                                                                                                                                                          |
| `bootstrap_linux_core__hostname_hosts`      | `[ { ip: "{{ ansible_facts['default_ipv4']['address'] }}", name: "{{ bootstrap_linux_core__hostname_name_full }}", aliases: [ "{{ bootstrap_linux_core__hostname_name_short }}" ] } ]` | List of host entries to be added to the hosts file.                                                                                                                                                       |
| `bootstrap_linux_core__systemd_sysctl_execstart` | `/lib/systemd/systemd-sysctl`                                                                      | ExecStart path for systemd sysctl service.                                                                                                                                                                  |
| `bootstrap_linux_core__enable_rsyslog`      | `false`                                                                                               | Whether to enable and configure rsyslog.                                                                                                                                                                    |
| `bootstrap_linux_core__setup_journald`      | `true`                                                                                                | Whether to configure journald settings.                                                                                                                                                                     |
| `bootstrap_linux_core__setup_host_networks` | `true`                                                                                                | Whether to set up host network configurations using Netplan or other methods.                                                                                                                             |
| `bootstrap_linux_core__public_interface`    | `"{{ ansible_facts['default_ipv4']['interface'] }}"`                                                   | Public network interface, automatically detected based on Ansible facts.                                                                                                                                    |
| `bootstrap_linux_core__network`             | `{ network: { version: 2, renderer: networkd, ethernets: { "{{ bootstrap_linux_core__public_interface }}": { dhcp4: true, dhcp6: true, dhcp-identifier: mac } } } }` | Netplan configuration for the public interface.                                                                                                                                                           |
| `bootstrap_linux_core__setup_admin_scripts` | `true`                                                                                                | Whether to set up administrative scripts and cron jobs.                                                                                                                                                     |
| `bootstrap_linux_core__setup_backup_scripts`| `false`                                                                                               | Whether to set up backup scripts and cron jobs.                                                                                                                                                             |

## Usage

To use the `bootstrap_linux_core` role, include it in your Ansible playbook as follows:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_core
      vars:
        bootstrap_linux_core__dns_domain: mydomain.com
        bootstrap_linux_core__timezone: Europe/London
```

## Dependencies

This role does not have any external dependencies. However, it includes and utilizes other roles such as `bootstrap_netplan` and `bootstrap_network_interfaces` for network configuration tasks.

## Best Practices

- **Backup Configuration Files:** Always ensure that critical configuration files like `/etc/hosts`, `/etc/resolv.conf`, and `/etc/sysctl.d/*` are backed up before making changes.
- **Test Changes in a Staging Environment:** Before applying the role to production systems, test it thoroughly in a staging environment to avoid any unintended disruptions.
- **Review Logs:** Regularly review system logs and Ansible output for any errors or warnings that may indicate issues with the configuration.

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