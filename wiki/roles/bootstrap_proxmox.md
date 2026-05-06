---
title: Bootstrap Proxmox Role Documentation
role: bootstrap_proxmox
category: Ansible Roles
type: Configuration Management
tags: proxmox, pve, virtualization, kvm, lxc
---

## Summary

The `bootstrap_proxmox` role is designed to install and configure Proxmox Virtual Environment (PVE) on Debian-based systems, specifically targeting versions Stretch and Buster. It handles various aspects of the installation and configuration process, including package management, cluster setup, Ceph storage integration, ZFS support, SSL configuration, and more.

## Variables

| Variable Name                          | Default Value                                                                 | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pve_base_dir`                         | `/etc/pve`                                                                    | Base directory for Proxmox configuration files.                                                                                                                                                             |
| `pve_cluster_conf`                     | `"{{ pve_base_dir }}/corosync.conf"`                                        | Path to the corosync configuration file used by Proxmox clusters.                                                                                                                                         |
| `_pve_cluster_addr0`                   | `"{{ ansible_facts['default_ipv4']['address'] }}"`                           | Default IPv4 address of the first cluster interface.                                                                                                                                                      |
| `remove_nag`                           | `true`                                                                        | Whether to remove the subscription nag message from the Proxmox web UI.                                                                                                                                   |
| `remove_enterprise_repo`               | `true`                                                                        | Whether to remove the Proxmox enterprise repository from APT sources.                                                                                                                                       |
| `pve_group`                            | `proxmox`                                                                     | The Ansible group name for all nodes in the Proxmox cluster.                                                                                                                                              |
| `pve_fetch_directory`                  | `fetch`                                                                       | Directory where fetched files (e.g., SSH keys) are stored during playbook execution.                                                                                                                        |
| `pve_repository_line`                  | `deb http://download.proxmox.com/debian/pve {{ ansible_facts['distribution_release'] }} pve-no-subscription` | APT repository line for Proxmox packages.                                                                                                                                                                 |
| `pve_remove_subscription_warning`      | `true`                                                                        | Whether to remove the subscription warning from the Proxmox web UI.                                                                                                                                         |
| `pve_extra_packages`                   | `[]`                                                                          | List of additional packages to install during the setup process.                                                                                                                                            |
| `pve_check_for_kernel_update`          | `true`                                                                        | Whether to check for kernel updates after installation.                                                                                                                                                     |
| `pve_reboot_on_kernel_update`          | `false`                                                                       | Whether to reboot the system if a new kernel is detected.                                                                                                                                                   |
| `pve_remove_old_kernels`               | `true`                                                                        | Whether to remove old Debian/PVE kernels after updating.                                                                                                                                                    |
| `pve_run_system_upgrades`              | `false`                                                                       | Whether to run system upgrades during the setup process.                                                                                                                                                  |
| `pve_run_proxmox_upgrades`             | `true`                                                                        | Whether to run Proxmox-specific upgrades during the setup process.                                                                                                                                          |
| `pve_watchdog`                         | `none`                                                                        | Watchdog module to use (e.g., `ipmi`).                                                                                                                                                                      |
| `pve_watchdog_ipmi_action`             | `power_cycle`                                                                 | Action for IPMI watchdog (e.g., `power_cycle`, `reset`).                                                                                                                                                |
| `pve_watchdog_ipmi_timeout`            | `10`                                                                          | Timeout for IPMI watchdog in seconds.                                                                                                                                                                       |
| `pve_zfs_enabled`                      | `false`                                                                       | Whether to enable ZFS support.                                                                                                                                                                              |
| `pve_ceph_enabled`                     | `false`                                                                       | Whether to enable Ceph storage integration.                                                                                                                                                                 |
| `pve_ceph_repository_line`             | `deb http://download.proxmox.com/debian/{% if ansible_facts['distribution_release'] == 'stretch' %}ceph-luminous stretch{% else %}ceph-nautilus buster{% endif %} main` | APT repository line for Ceph packages.                                                                                                                                                                    |
| `pve_ceph_network`                     | `"{{ (ansible_facts['default_ipv4'].network +'/'+ ansible_facts['default_ipv4']['netmask']) \| ansible.utils.ipaddr('net') }}"` | Network configuration for Ceph storage cluster.                                                                                                                                                           |
| `pve_ceph_mon_group`                   | `"{{ pve_group }}"`                                                           | Ansible group name for Ceph monitors.                                                                                                                                                                     |
| `pve_ceph_mds_group`                   | `"{{ pve_group }}"`                                                           | Ansible group name for Ceph metadata servers (MDS).                                                                                                                                                       |
| `pve_ceph_osds`                        | `[]`                                                                          | List of OSD devices to be used in the Ceph storage cluster.                                                                                                                                               |
| `pve_ceph_pools`                       | `[]`                                                                          | List of pools to create in the Ceph storage cluster.                                                                                                                                                    |
| `pve_ceph_fs`                          | `[]`                                                                          | Filesystem configurations for Ceph.                                                                                                                                                                         |
| `pve_ceph_crush_rules`                 | `[]`                                                                          | CRUSH rules for Ceph data distribution.                                                                                                                                                                     |
| `pve_cluster_enabled`                  | `false`                                                                       | Whether to enable Proxmox clustering.                                                                                                                                                                       |
| `pve_cluster_clustername`              | `"{{ pve_group }}"`                                                           | Name of the Proxmox cluster.                                                                                                                                                                                |
| `pve_datacenter_cfg`                   | `{}`                                                                          | Configuration for the data center in Proxmox.                                                                                                                                                               |
| `pve_cluster_ha_groups`                | `[]`                                                                          | High Availability (HA) group configurations for the Proxmox cluster.                                                                                                                                      |
| `pve_ssl_letsencrypt`                  | `false`                                                                       | Whether to use Let's Encrypt for SSL certificates.                                                                                                                                                        |
| `pve_roles`                            | `[]`                                                                          | List of roles to configure in Proxmox.                                                                                                                                                                      |
| `pve_groups`                           | `[]`                                                                          | List of groups to configure in Proxmox.                                                                                                                                                                     |
| `pve_users`                            | `[]`                                                                          | List of users to configure in Proxmox.                                                                                                                                                                      |
| `pve_acls`                             | `[]`                                                                          | Access Control Lists (ACLs) for Proxmox resources.                                                                                                                                                        |
| `pve_storages`                         | `[]`                                                                          | Storage configurations for Proxmox.                                                                                                                                                                         |
| `pve_ssh_port`                         | `22`                                                                          | SSH port to use for cluster communication and management.                                                                                                                                                   |
| `pve_manage_ssh`                       | `true`                                                                        | Whether to manage SSH keys and configuration for the Proxmox cluster nodes.                                                                                                                               |

## Usage

To use the `bootstrap_proxmox` role, include it in your Ansible playbook and specify any necessary variables as needed. Below is an example of how you might structure a playbook that uses this role:

```yaml
---
- name: Bootstrap Proxmox Cluster
  hosts: proxmox_group
  become: yes
  roles:
    - role: bootstrap_proxmox
      vars:
        pve_cluster_enabled: true
        pve_ceph_enabled: true
        pve_zfs_enabled: false
        pve_extra_packages:
          - vim
          - htop
```

In this example, the playbook targets hosts in the `proxmox_group` and enables both Proxmox clustering and Ceph storage integration while disabling ZFS support. It also installs additional packages such as `vim` and `htop`.

## Dependencies

This role does not have any external dependencies beyond standard Ansible modules and the specified Debian distributions (Stretch and Buster).

## Tags

The following tags are available for use with this role:

- `skiponlxc`: Skips tasks that should not be executed within LXC containers.
- `create_osd`: Manages creation of Ceph Object Storage Devices (OSDs).
- `ceph_volume`: Handles operations related to Ceph volumes.

To run specific tagged tasks, you can use the `--tags` option with Ansible:

```bash
ansible-playbook -i inventory playbook.yml --tags create_osd
```

## Best Practices

1. **Backup Configuration Files**: Always ensure that important configuration files are backed up before making changes.
2. **Test in a Staging Environment**: Before deploying the role to production, test it thoroughly in a staging environment.
3. **Use Tags for Granular Control**: Utilize tags to control which parts of the role are executed, allowing for more granular management and troubleshooting.
4. **Review Logs**: Regularly review Ansible logs and Proxmox logs to ensure that everything is functioning as expected.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to set up Molecule tests to ensure the reliability and maintainability of the role in future updates.

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