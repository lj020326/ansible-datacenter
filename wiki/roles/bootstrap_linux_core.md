---
title: "Bootstrap Linux Core Role"
role: bootstrap_linux_core
category: System
type: Role
tags: [ansible, role, bootstrap_linux_core]
---

```yaml
---
title: Bootstrap Linux Core Role
role: bootstrap_linux_core
category: System
type: Role
summary: |
  The `bootstrap_linux_core` role is designed to provide a comprehensive baseline configuration for Linux systems. It covers a wide range of system setup tasks including DNS configuration, environment setup, hostname configuration, system updates, and more. This role is intended to be used as a foundation for building more specific system configurations.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_core__setup_dns` | `true` | Whether to setup DNS configuration |
| `bootstrap_linux_core__dns_domain` | `example.int` | The DNS domain to set |
| `bootstrap_linux_core__dns_search_domains` | `['example.int']` | List of DNS search domains |
| `bootstrap_linux_core__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | Architecture of the system |
| `bootstrap_linux_core__setup_os_update` | `true` | Whether to setup OS update scripts |
| `bootstrap_linux_core__reset_daily_scripts` | `true` | Whether to reset daily scripts |
| `bootstrap_linux_core__figurine_version` | `"2.0.0"` | Version of figurine to install |
| `bootstrap_linux_core__figurine_url` | `"https://github.com/lj020326/figurine/releases/download/v{{ bootstrap_linux_core__figurine_version }}/figurine_linux_{{ bootstrap_linux_core__arch }}_v{{ bootstrap_linux_core__figurine_version }}.tar.gz"` | URL to download figurine |
| `bootstrap_linux_core__default_path` | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` | Default PATH for the system |
| `bootstrap_linux_core__init_netplan` | `false` | Whether to initialize netplan |
| `bootstrap_linux_core__init_network_interfaces` | `false` | Whether to initialize network interfaces |
| `bootstrap_linux_core__restart_systemd` | `true` | Whether to restart systemd services |
| `bootstrap_linux_core__stop_user_procs` | `true` | Whether to stop user processes |
| `bootstrap_linux_core__init_hosts_file` | `true` | Whether to initialize the hosts file |
| `bootstrap_linux_core__setup_figurine` | `true` | Whether to setup figurine |
| `bootstrap_linux_core__figurine_force_config` | `true` | Whether to force figurine configuration |
| `bootstrap_linux_core__figurine_name` | `{{ ansible_facts['hostname'] }}` | Name for figurine |
| `bootstrap_linux_core__ansible_ssh_allowed_ips` | `['127.0.0.1']` | List of allowed IPs for SSH |
| `bootstrap_linux_core__network_name_servers` | `['192.168.0.1']` | List of DNS name servers |
| `bootstrap_linux_core__set_timezone` | `true` | Whether to set the timezone |
| `bootstrap_linux_core__timezone` | `America/New_York` | Timezone to set |
| `bootstrap_linux_core__setup_hostname` | `true` | Whether to setup hostname |
| `bootstrap_linux_core__hostname_internal_domain` | `example.int` | Internal domain for hostname |
| `bootstrap_linux_core__hostname_hosts_file_location` | `/etc/hosts` | Location of the hosts file |
| `bootstrap_linux_core__hostname_hosts_backup` | `true` | Whether to backup the hosts file |
| `bootstrap_linux_core__hostname_name_full` | `{{ inventory_hostname_short }}.{{ bootstrap_linux_core__hostname_internal_domain }}` | Full hostname |
| `bootstrap_linux_core__hostname_name_short` | `{{ inventory_hostname_short }}` | Short hostname |
| `bootstrap_linux_core__hostname_hosts` | `[{'ip': '{{ ansible_facts['default_ipv4']['address'] }}', 'name': '{{ bootstrap_linux_core__hostname_name_full }}', 'aliases': ['{{ bootstrap_linux_core__hostname_name_short }}']}]` | Hosts configuration |
| `bootstrap_linux_core__systemd_sysctl_execstart` | `/lib/systemd/systemd-sysctl` | Path to systemd-sysctl |
| `bootstrap_linux_core__enable_rsyslog` | `false` | Whether to enable rsyslog |
| `bootstrap_linux_core__setup_journald` | `true` | Whether to setup journald |
| `bootstrap_linux_core__setup_host_networks` | `true` | Whether to setup host networks |
| `bootstrap_linux_core__public_interface` | `{{ ansible_facts['default_ipv4']['interface'] }}` | Public network interface |
| `bootstrap_linux_core__network` | `{'network': {'version': 2, 'renderer': 'networkd', 'ethernets': {'{{ bootstrap_linux_core__public_interface }}': {'dhcp4': true, 'dhcp6': true, 'dhcp-identifier': 'mac'}}}}` | Network configuration |

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: all
  roles:
    - bootstrap_linux_core
```

You can override the default variables by defining them in your playbook or inventory:

```yaml
- hosts: all
  vars:
    bootstrap_linux_core__dns_domain: "my.domain.com"
    bootstrap_linux_core__timezone: "Europe/London"
  roles:
    - bootstrap_linux_core
```

## Dependencies

This role does not have any specific dependencies, but it may rely on other roles for certain tasks, such as:
- `bootstrap_netplan` for network configuration
- `bootstrap_network_interfaces` for network interface setup

## Best Practices

- Apply the role to a clean system to avoid conflicts with existing configurations.
- Review and customize the default variables to match your specific requirements.
- Test the role in a staging environment before applying it to production systems.
- Regularly update the role to benefit from new features and security improvements.

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
- [tasks/setup-os-update.yml](../../roles/bootstrap_linux_core/tasks/setup-os-update.yml)
- [tasks/sysctl.yml](../../roles/bootstrap_linux_core/tasks/sysctl.yml)
- [tasks/timezone.yml](../../roles/bootstrap_linux_core/tasks/timezone.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_core/handlers/main.yml)