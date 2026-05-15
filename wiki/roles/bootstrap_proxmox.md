---
title: "Proxmox Bootstrap Role"
role: bootstrap_proxmox
category: Ansible Roles
type: Configuration Management
tags: proxmox, pve, virtualization, kvm, lxc
---

## Summary

The `bootstrap_proxmox` role is designed to automate the installation and configuration of Proxmox Virtual Environment (PVE) on Debian-based systems. It supports clustering, Ceph storage integration, ZFS setup, and various other configurations such as SSH management, SSL certificates, and watchdog settings.

## Variables

| Variable Name                         | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|-----------------------------------------|------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pve_base_dir`                          | `/etc/pve`                                                                                           | Base directory for Proxmox configuration files.                                                                                                                                                             |
| `pve_cluster_conf`                      | `"{{ pve_base_dir }}/corosync.conf"`                                                                 | Path to the corosync configuration file used in clustering.                                                                                                                                                 |
| `_pve_cluster_addr0`                    | `"{{ ansible_facts['default_ipv4']['address'] }}"`                                                    | Default IPv4 address for cluster communication.                                                                                                                                                             |
| `remove_nag`                            | `true`                                                                                               | Whether to remove the subscription nag message from Proxmox GUI.                                                                                                                                          |
| `remove_enterprise_repo`                | `true`                                                                                               | Whether to remove the enterprise repository from APT sources.                                                                                                                                             |
| `pve_group`                             | `proxmox`                                                                                            | The Ansible group that contains all nodes in the Proxmox cluster.                                                                                                                                         |
| `pve_fetch_directory`                   | `fetch`                                                                                              | Directory where fetched files (e.g., SSH keys) are stored.                                                                                                                                                  |
| `pve_repository_line`                   | `deb http://download.proxmox.com/debian/pve {{ ansible_facts['distribution_release'] }} pve-no-subscription` | APT repository line for Proxmox VE packages.                                                                                                                                                              |
| `pve_remove_subscription_warning`       | `true`                                                                                               | Whether to remove the subscription warning from the Proxmox web interface.                                                                                                                                |
| `pve_extra_packages`                    | `[]`                                                                                                 | List of additional packages to install during the setup.                                                                                                                                                    |
| `pve_check_for_kernel_update`           | `true`                                                                                               | Whether to check for kernel updates.                                                                                                                                                                        |
| `pve_reboot_on_kernel_update`           | `false`                                                                                              | Whether to reboot the system if a new kernel is detected.                                                                                                                                                   |
| `pve_remove_old_kernels`                | `true`                                                                                               | Whether to remove old kernels after updating.                                                                                                                                                               |
| `pve_run_system_upgrades`               | `false`                                                                                              | Whether to run system upgrades during the setup.                                                                                                                                                            |
| `pve_run_proxmox_upgrades`              | `true`                                                                                               | Whether to run Proxmox-specific upgrades during the setup.                                                                                                                                                |
| `pve_watchdog`                          | `none`                                                                                               | Watchdog type (e.g., `ipmi`, `softdog`).                                                                                                                                                                  |
| `pve_watchdog_ipmi_action`              | `power_cycle`                                                                                        | Action to perform when IPMI watchdog triggers.                                                                                                                                                              |
| `pve_watchdog_ipmi_timeout`             | `10`                                                                                                 | Timeout for the IPMI watchdog in seconds.                                                                                                                                                                   |
| `pve_zfs_enabled`                       | `false`                                                                                              | Whether ZFS is enabled and should be configured.                                                                                                                                                            |
| `pve_ceph_enabled`                      | `false`                                                                                              | Whether Ceph storage is enabled and should be configured.                                                                                                                                                   |
| `pve_ceph_repository_line`              | `deb http://download.proxmox.com/debian/{% if ansible_facts['distribution_release'] == 'stretch' %}ceph-luminous stretch{% else %}ceph-nautilus buster{% endif %} main` | APT repository line for Ceph packages.                                                                                                                                                                    |
| `pve_ceph_network`                      | `"{{ (ansible_facts['default_ipv4'].network +'/'+ ansible_facts['default_ipv4']['netmask']) | ansible.utils.ipaddr('net') }}"`                                               | Network configuration for Ceph storage.                                                                                                                                                                     |
| `pve_ceph_mon_group`                    | `"{{ pve_group }}"`                                                                                    | Ansible group containing the Ceph monitors.                                                                                                                                                                 |
| `pve_ceph_mds_group`                    | `"{{ pve_group }}"`                                                                                    | Ansible group containing the Ceph metadata servers (MDS).                                                                                                                                                   |
| `pve_ceph_osds`                         | `[]`                                                                                                 | List of OSD devices to be used in Ceph storage.                                                                                                                                                             |
| `pve_ceph_pools`                        | `[]`                                                                                                 | List of Ceph pools to create.                                                                                                                                                                               |
| `pve_ceph_fs`                           | `[]`                                                                                                 | List of Ceph filesystems to create.                                                                                                                                                                         |
| `pve_ceph_crush_rules`                  | `[]`                                                                                                 | List of CRUSH rules for Ceph storage.                                                                                                                                                                       |
| `pve_cluster_enabled`                   | `false`                                                                                              | Whether clustering is enabled and should be configured.                                                                                                                                                     |
| `pve_cluster_clustername`               | `"{{ pve_group }}"`                                                                                    | Name of the Proxmox cluster.                                                                                                                                                                                |
| `pve_datacenter_cfg`                    | `{}`                                                                                                 | Configuration for the datacenter in the Proxmox cluster.                                                                                                                                                  |
| `pve_cluster_ha_groups`                 | `[]`                                                                                                 | List of High Availability (HA) groups to configure in the Proxmox cluster.                                                                                                                                |
| `pve_ssl_letsencrypt`                   | `false`                                                                                              | Whether to use Let's Encrypt for SSL certificates.                                                                                                                                                        |
| `pve_roles`                             | `[]`                                                                                                 | List of roles to assign to nodes in the Proxmox cluster.                                                                                                                                                  |
| `pve_groups`                            | `[]`                                                                                                 | List of groups to create in the Proxmox cluster.                                                                                                                                                            |
| `pve_users`                             | `[]`                                                                                                 | List of users to create in the Proxmox cluster.                                                                                                                                                             |
| `pve_acls`                              | `[]`                                                                                                 | Access Control Lists (ACLs) to configure in the Proxmox cluster.                                                                                                                                          |
| `pve_storages`                            | `[]`                                                                                                 | List of storage configurations for the Proxmox cluster.                                                                                                                                                   |
| `pve_ssh_port`                          | `22`                                                                                                 | Port used for SSH connections.                                                                                                                                                                              |
| `pve_manage_ssh`                        | `true`                                                                                               | Whether to manage SSH keys and configuration for cluster nodes.                                                                                                                                           |

## Usage

To use the `bootstrap_proxmox` role, include it in your playbook and specify any necessary variables as needed. Below is an example of how you might structure a playbook to deploy Proxmox with clustering enabled:

```yaml
---
- hosts: proxmox_nodes
  become: yes
  roles:
    - role: bootstrap_proxmox
      vars:
        pve_cluster_enabled: true
        pve_cluster_ha_groups:
          - name: ha_group1
            comment: "High Availability Group 1"
            nodes: node1,node2
            nofailback: true
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules and Proxmox VE packages.

## Best Practices

- Ensure all nodes in the cluster are part of the same Ansible group specified by `pve_group`.
- Configure network settings appropriately before running the playbook to avoid issues with clustering.
- Review and adjust variables as necessary for your specific environment, especially when enabling features like Ceph or ZFS.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to test the role in a controlled environment before deploying it in production.

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