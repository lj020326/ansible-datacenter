---
title: "Proxmox Bootstrap Role Documentation"
role: bootstrap_proxmox
category: Ansible Roles
type: Configuration
tags: proxmox, pve, virtualization, kvm, lxc

## Summary
The `bootstrap_proxmox` role is designed to install and configure Proxmox VE on Debian-based systems. It supports clustering, Ceph storage integration, ZFS configuration, and various other system-level configurations such as SSH management, SSL certificates, and kernel updates.

## Variables

| Variable Name                         | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pve_base_dir`                        | `/etc/pve`                                                                                            | Base directory for Proxmox configuration files.                                                                                                                                                             |
| `pve_cluster_conf`                    | `"{{ pve_base_dir }}/corosync.conf"`                                                                    | Path to the corosync cluster configuration file.                                                                                                                                                            |
| `_pve_cluster_addr0`                  | `"{{ ansible_facts['default_ipv4']['address'] }}"`                                                      | Default IPv4 address for the first cluster interface.                                                                                                                                                       |
| `remove_nag`                          | `true`                                                                                                  | Whether to remove the Proxmox no-subscription nag message.                                                                                                                                                |
| `remove_enterprise_repo`              | `true`                                                                                                  | Whether to remove the Proxmox enterprise repository.                                                                                                                                                      |
| `pve_group`                           | `proxmox`                                                                                               | The Ansible group that contains all nodes in the Proxmox cluster.                                                                                                                                         |
| `pve_fetch_directory`                 | `fetch`                                                                                                 | Directory where fetched files (e.g., SSH keys) are stored.                                                                                                                                                  |
| `pve_repository_line`                 | `deb http://download.proxmox.com/debian/pve {{ ansible_facts['distribution_release'] }} pve-no-subscription` | APT repository line for Proxmox VE packages.                                                                                                                                                                |
| `pve_remove_subscription_warning`     | `true`                                                                                                  | Whether to remove the subscription warning in the web interface.                                                                                                                                          |
| `pve_extra_packages`                  | `[]`                                                                                                    | List of additional packages to install with Proxmox VE.                                                                                                                                                   |
| `pve_check_for_kernel_update`         | `true`                                                                                                  | Whether to check for kernel updates.                                                                                                                                                                        |
| `pve_reboot_on_kernel_update`         | `false`                                                                                                 | Whether to reboot the system after a kernel update is detected.                                                                                                                                           |
| `pve_remove_old_kernels`              | `true`                                                                                                  | Whether to remove old Debian and Proxmox kernels.                                                                                                                                                           |
| `pve_run_system_upgrades`             | `false`                                                                                                 | Whether to run system upgrades during the playbook execution.                                                                                                                                             |
| `pve_run_proxmox_upgrades`            | `true`                                                                                                  | Whether to run Proxmox-specific upgrades during the playbook execution.                                                                                                                                   |
| `pve_watchdog`                        | `none`                                                                                                  | Watchdog module to use (e.g., `ipmi`).                                                                                                                                                                      |
| `pve_watchdog_ipmi_action`            | `power_cycle`                                                                                           | Action for IPMI watchdog (e.g., `power_cycle`, `reset`).                                                                                                                                                |
| `pve_watchdog_ipmi_timeout`           | `10`                                                                                                    | Timeout for IPMI watchdog in seconds.                                                                                                                                                                       |
| `pve_zfs_enabled`                     | `false`                                                                                                 | Whether to enable ZFS support.                                                                                                                                                                              |
| `pve_ceph_enabled`                    | `false`                                                                                                 | Whether to enable Ceph storage integration.                                                                                                                                                               |
| `pve_ceph_repository_line`            | `deb http://download.proxmox.com/debian/{% if ansible_facts['distribution_release'] == 'stretch' %}ceph-luminous stretch{% else %}ceph-nautilus buster{% endif %} main` | APT repository line for Ceph packages.                                                                                                                                                                      |
| `pve_ceph_network`                    | `"{{ (ansible_facts['default_ipv4'].network +'/'+ ansible_facts['default_ipv4']['netmask']) \| ansible.utils.ipaddr('net') }}"` | Network configuration for Ceph cluster.                                                                                                                                                                   |
| `pve_ceph_mon_group`                  | `"{{ pve_group }}"`                                                                                      | Ansible group containing the Ceph monitors.                                                                                                                                                               |
| `pve_ceph_mds_group`                  | `"{{ pve_group }}"`                                                                                      | Ansible group containing the Ceph metadata servers (MDS).                                                                                                                                                 |
| `pve_ceph_osds`                       | `[]`                                                                                                    | List of OSD devices for Ceph storage.                                                                                                                                                                       |
| `pve_ceph_pools`                      | `[]`                                                                                                    | List of Ceph pools to create.                                                                                                                                                                               |
| `pve_ceph_fs`                         | `[]`                                                                                                    | List of Ceph filesystems to create.                                                                                                                                                                         |
| `pve_ceph_crush_rules`                | `[]`                                                                                                    | List of CRUSH rules for Ceph storage.                                                                                                                                                                       |
| `pve_cluster_enabled`                 | `false`                                                                                                 | Whether clustering is enabled.                                                                                                                                                                              |
| `pve_cluster_clustername`             | `"{{ pve_group }}"`                                                                                      | Name of the Proxmox cluster.                                                                                                                                                                                |
| `pve_datacenter_cfg`                  | `{}`                                                                                                    | Configuration for the datacenter in the Proxmox cluster.                                                                                                                                                  |
| `pve_cluster_ha_groups`               | `[]`                                                                                                    | List of HA groups to configure in the Proxmox cluster.                                                                                                                                                    |
| `pve_ssl_letsencrypt`                 | `false`                                                                                                 | Whether to use Let's Encrypt for SSL certificates.                                                                                                                                                        |
| `pve_roles`                           | `[]`                                                                                                    | List of roles to assign to users or groups.                                                                                                                                                                 |
| `pve_groups`                          | `[]`                                                                                                    | List of groups to create in the Proxmox cluster.                                                                                                                                                            |
| `pve_users`                           | `[]`                                                                                                    | List of users to create in the Proxmox cluster.                                                                                                                                                             |
| `pve_acls`                            | `[]`                                                                                                    | Access control lists for Proxmox resources.                                                                                                                                                                 |
| `pve_storages`                        | `[]`                                                                                                    | Storage configurations for the Proxmox cluster.                                                                                                                                                           |
| `pve_ssh_port`                        | `22`                                                                                                    | SSH port to use for connecting to Proxmox nodes.                                                                                                                                                            |
| `pve_manage_ssh`                      | `true`                                                                                                  | Whether to manage SSH keys and configuration for the Proxmox cluster.                                                                                                                                   |

## Usage

To use this role, include it in your playbook and specify any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Bootstrap Proxmox VE
  hosts: proxmox_group
  become: yes
  roles:
    - role: bootstrap_proxmox
      vars:
        pve_ceph_enabled: true
        pve_zfs_enabled: false
        pve_cluster_enabled: true
```

## Dependencies

This role does not have any external dependencies. However, it requires the `community.general` and `ansible.posix` collections to be installed:

```bash
ansible-galaxy collection install community.general ansible.posix
```

## Best Practices

- Ensure all nodes in the cluster are included in the specified Ansible group.
- Verify that network configurations for clustering (e.g., `pve_cluster_addr0`) are correct and reachable between nodes.
- Use Let's Encrypt for SSL certificates to ensure secure communication with the Proxmox web interface.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to test the role in a controlled environment before deploying it to production.

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