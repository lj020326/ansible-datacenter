---
title: "Proxmox Bootstrap Role"
role: bootstrap_proxmox
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_proxmox]
---

# Proxmox Bootstrap Role

The `bootstrap_proxmox` role is designed to install and configure Proxmox Virtual Environment (PVE) on Debian-based systems. This role handles the setup of Proxmox repositories, configuration of cluster settings, management of SSH keys, and various other Proxmox-specific configurations.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `pve_base_dir` | `/etc/pve` | Base directory for Proxmox configuration files. |
| `pve_cluster_conf` | `{{ pve_base_dir }}/corosync.conf` | Path to the Proxmox cluster configuration file. |
| `_pve_cluster_addr0` | `{{ ansible_facts['default_ipv4']['address'] }}` | Primary cluster address. |
| `remove_nag` | `true` | Remove the Proxmox subscription nag screen. |
| `remove_enterprise_repo` | `true` | Remove the Proxmox enterprise repository. |
| `pve_group` | `proxmox` | Group name for Proxmox hosts. |
| `pve_fetch_directory` | `fetch` | Directory to fetch SSH keys. |
| `pve_repository_line` | `deb http://download.proxmox.com/debian/pve {{ ansible_facts['distribution_release'] }} pve-no-subscription` | Proxmox repository line for APT sources. |
| `pve_remove_subscription_warning` | `true` | Remove subscription warning messages. |
| `pve_extra_packages` | `[]` | List of additional packages to install. |
| `pve_check_for_kernel_update` | `true` | Check for kernel updates. |
| `pve_reboot_on_kernel_update` | `false` | Reboot on kernel update. |
| `pve_remove_old_kernels` | `true` | Remove old kernels. |
| `pve_run_system_upgrades` | `false` | Run system upgrades. |
| `pve_run_proxmox_upgrades` | `true` | Run Proxmox upgrades. |
| `pve_watchdog` | `none` | Watchdog configuration. |
| `pve_watchdog_ipmi_action` | `power_cycle` | IPMI watchdog action. |
| `pve_watchdog_ipmi_timeout` | `10` | IPMI watchdog timeout. |
| `pve_zfs_enabled` | `false` | Enable ZFS support. |
| `pve_ceph_enabled` | `false` | Enable Ceph support. |
| `pve_ceph_repository_line` | `deb http://download.proxmox.com/debian/{% if ansible_facts['distribution_release'] == 'stretch' %}ceph-luminous stretch{% else %}ceph-nautilus buster{% endif %} main` | Ceph repository line for APT sources. |
| `pve_ceph_network` | `{{ (ansible_facts['default_ipv4'].network +'/'+ ansible_facts['default_ipv4']['netmask']) | ansible.utils.ipaddr('net') }}` | Ceph network configuration. |
| `pve_ceph_mon_group` | `{{ pve_group }}` | Group name for Ceph monitors. |
| `pve_ceph_mds_group` | `{{ pve_group }}` | Group name for Ceph MDS. |
| `pve_ceph_osds` | `[]` | List of Ceph OSDs. |
| `pve_ceph_pools` | `[]` | List of Ceph pools. |
| `pve_ceph_fs` | `[]` | List of Ceph file systems. |
| `pve_ceph_crush_rules` | `[]` | List of Ceph crush rules. |
| `pve_cluster_enabled` | `false` | Enable Proxmox cluster. |
| `pve_cluster_clustername` | `{{ pve_group }}` | Proxmox cluster name. |
| `pve_datacenter_cfg` | `{}` | Proxmox datacenter configuration. |
| `pve_cluster_ha_groups` | `[]` | List of Proxmox HA groups. |
| `pve_ssl_letsencrypt` | `false` | Enable Let's Encrypt SSL. |
| `pve_roles` | `[]` | List of Proxmox roles. |
| `pve_groups` | `[]` | List of Proxmox groups. |
| `pve_users` | `[]` | List of Proxmox users. |
| `pve_acls` | `[]` | List of Proxmox ACLs. |
| `pve_storages` | `[]` | List of Proxmox storages. |
| `pve_ssh_port` | `22` | SSH port for Proxmox. |
| `pve_manage_ssh` | `true` | Manage SSH configuration. |

## Usage

To use this role, include it in your playbook and define the necessary variables:

```yaml
- hosts: proxmox
  roles:
    - role: bootstrap_proxmox
      vars:
        pve_group: "proxmox"
        pve_cluster_enabled: true
        pve_cluster_clustername: "my-cluster"
        pve_ceph_enabled: true
        pve_zfs_enabled: true
```

## Dependencies

This role does not have any external dependencies. It relies on the standard Ansible modules and the Proxmox API.

## Best Practices

- Ensure that all hosts in the Proxmox cluster are reachable and have consistent network configurations.
- Regularly update the Proxmox repositories and packages to benefit from the latest features and security updates.
- Monitor the Proxmox cluster for any issues and address them promptly to maintain high availability.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_proxmox/defaults/main.yml)
- [tasks/ceph.yml](../../roles/bootstrap_proxmox/tasks/ceph.yml)
- [tasks/disable_nmi_watchdog.yml](../../roles/bootstrap_proxmox/tasks/disable_nmi_watchdog.yml)
- [tasks/identify_needed_packages.yml](../../roles/bootstrap_proxmox/tasks/identify_needed_packages.yml)
- [tasks/ipmi_watchdog.yml](../../roles/bootstrap_proxmox/tasks/ipmi_watchdog.yml)
- [tasks/kernel_module_cleanup.yml](../../roles/bootstrap_proxmox/tasks/kernel_module_cleanup.yml)
- [tasks/kernel_updates.yml](../../roles/bootstrap_proxmox/tasks/kernel_updates.yml)
- [tasks/load_variables.yml](../../roles/bootstrap_proxmox/tasks/load_variables.yml)
- [tasks/main.yml](../../roles/bootstrap_proxmox/tasks/main.yml)
- [tasks/pve_add_node.yml](../../roles/bootstrap_proxmox/tasks/pve_add_node.yml)
- [tasks/pve_cluster_config.yml](../../roles/bootstrap_proxmox/tasks/pve_cluster_config.yml)
- [tasks/remove-enterprise-repo.yml](../../roles/bootstrap_proxmox/tasks/remove-enterprise-repo.yml)
- [tasks/remove-nag.yml](../../roles/bootstrap_proxmox/tasks/remove-nag.yml)
- [tasks/ssh_cluster_config.yml](../../roles/bootstrap_proxmox/tasks/ssh_cluster_config.yml)
- [tasks/ssl_config.yml](../../roles/bootstrap_proxmox/tasks/ssl_config.yml)
- [tasks/ssl_letsencrypt.yml](../../roles/bootstrap_proxmox/tasks/ssl_letsencrypt.yml)
- [tasks/zfs.yml](../../roles/bootstrap_proxmox/tasks/zfs.yml)
- [meta/main.yml](../../roles/bootstrap_proxmox/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_proxmox/handlers/main.yml)