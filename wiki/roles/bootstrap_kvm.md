---
title: "Bootstrap KVM Role"
role: roles/bootstrap_kvm
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_kvm]
---

# Bootstrap KVM Role Documentation

## Purpose

The `bootstrap_kvm` role is designed to automate the setup and configuration of KVM (Kernel-based Virtual Machine) on both Debian-based and RedHat-based systems. This role handles the installation of necessary packages, configuration of KVM settings, management of virtual machines, networks, and storage pools, and includes additional system tweaks to optimize the KVM environment.

## Variables

| Variable Name                       | Default Value                         | Description                                                                 |
|-------------------------------------|---------------------------------------|-----------------------------------------------------------------------------|
| `kvm_allow_root_ssh`                | `false`                               | Allow root SSH logins.                                                     |
| `kvm_audit_level`                   | `1`                                   | Audit level for KVM.                                                       |
| `kvm_audit_logging`                 | `0`                                   | Audit logging level.                                                      |
| `kvm_auth_unix_ro`                  | `none`                                | Unix read-only authentication.                                             |
| `kvm_auth_unix_rw`                  | `none`                                | Unix read-write authentication.                                            |
| `kvm_config`                        | `false`                               | Enable KVM configuration.                                                  |
| `kvm_config_users`                  | `false`                               | Enable user configuration for KVM.                                         |
| `kvm_config_virtual_networks`       | `false`                               | Enable virtual network configuration.                                      |
| `kvm_config_storage_pools`          | `false`                               | Enable storage pool configuration.                                         |
| `kvm_disable_apparmor`              | `false`                               | Disable AppArmor profiles for libvirt.                                     |
| `kvm_enable_mdns`                   | `false`                               | Enable mDNS for KVM.                                                       |
| `kvm_enable_system_tweaks`          | `false`                               | Enable system tweaks for KVM.                                              |
| `kvm_enable_tcp`                    | `false`                               | Enable TCP for KVM.                                                        |
| `kvm_enable_tls`                    | `true`                                | Enable TLS for KVM.                                                        |
| `kvm_enable_libvirtd_syslog`        | `false`                               | Enable libvirtd syslog.                                                    |
| `kvm_images_cache_mode`             | `none`                                | Cache mode for KVM images.                                                 |
| `kvm_images_format_type`            | `qcow2`                               | Format type for KVM images.                                                |
| `kvm_images_path`                   | `/var/lib/libvirt/images`             | Path for KVM images.                                                       |
| `kvm_keepalive_interval`            | `5`                                   | Keepalive interval for KVM.                                                |
| `kvm_keepalive_count`               | `5`                                   | Keepalive count for KVM.                                                  |
| `kvm_admin_keepalive_interval`      | `5`                                   | Keepalive interval for admin.                                              |
| `kvm_admin_keepalive_count`         | `5`                                   | Keepalive count for admin.                                                |
| `kvm_listen_addr`                   | `0.0.0.0`                             | Listen address for KVM.                                                    |
| `kvm_log_level`                     | `3`                                   | Log level for KVM.                                                        |
| `kvm_manage_vms`                    | `false`                               | Enable VM management.                                                      |
| `kvm_max_anonymous_clients`         | `20`                                  | Maximum number of anonymous clients.                                       |
| `kvm_max_client_requests`           | `5`                                   | Maximum client requests.                                                  |
| `kvm_admin_max_client_requests`     | `5`                                   | Maximum admin client requests.                                             |
| `kvm_max_clients`                   | `5000`                                | Maximum number of clients.                                                 |
| `kvm_admin_max_clients`             | `5`                                   | Maximum number of admin clients.                                           |
| `kvm_max_queued_clients`            | `1000`                                | Maximum number of queued clients.                                          |
| `kvm_admin_max_queued_clients`      | `5`                                   | Maximum number of admin queued clients.                                    |
| `kvm_max_requests`                  | `20`                                  | Maximum number of requests.                                                |
| `kvm_max_workers`                   | `20`                                  | Maximum number of workers.                                                 |
| `kvm_min_workers`                   | `5`                                   | Minimum number of workers.                                                 |
| `kvm_admin_min_workers`             | `1`                                   | Minimum number of admin workers.                                           |
| `kvm_admin_max_workers`             | `5`                                   | Maximum number of admin workers.                                           |
| `kvm_ovs_timeout`                   | `5`                                   | OVS timeout for KVM.                                                      |
| `kvm_prio_workers`                  | `5`                                   | Priority workers for KVM.                                                  |
| `kvm_redhat_packages`               | `[...]`                               | List of packages to install on RedHat-based systems.                       |
| `kvm_security_driver`               | `none`                                | Security driver for KVM.                                                   |
| `kvm_sysctl_settings`               | `[...]`                               | List of sysctl settings for KVM.                                           |
| `kvm_tcp_port`                      | `16509`                               | TCP port for KVM.                                                          |
| `kvm_tls_port`                      | `16514`                               | TLS port for KVM.                                                          |
| `kvm_unix_sock_dir`                 | `/var/run/libvirt`                    | Unix socket directory for KVM.                                             |
| `kvm_users`                         | `[]`                                  | List of users to add to KVM.                                               |
| `kvm_virtual_networks`              | `[]`                                  | List of virtual networks to configure.                                     |
| `kvm_storage_pools`                 | `[]`                                  | List of storage pools to configure.                                        |
| `kvm_vms`                           | `[]`                                  | List of VMs to manage.                                                     |

## Usage

To use the `bootstrap_kvm` role, include it in your playbook and set the desired variables. Here is an example playbook:

```yaml
---
- hosts: kvm_hosts
  roles:
    - role: bootstrap_kvm
      vars:
        kvm_config: true
        kvm_config_users: true
        kvm_users:
          - user1
          - user2
        kvm_config_virtual_networks: true
        kvm_virtual_networks:
          - name: default
            state: active
            autostart: true
        kvm_config_storage_pools: true
        kvm_storage_pools:
          - name: default
            path: /var/lib/libvirt/images
            state: active
            autostart: true
        kvm_manage_vms: true
        kvm_vms:
          - name: testvm
            state: running
            autostart: true
            disks:
              - name: testvm
                size: 10G
```

## Dependencies

This role depends on the following Ansible collections:

- `community.libvirt`
- `ansible.posix`

Ensure these collections are installed before running the playbook:

```bash
ansible-galaxy collection install community.libvirt
ansible-galaxy collection install ansible.posix
```

## Best Practices

- Always test the role in a development environment before deploying it to production.
- Regularly update the role to ensure compatibility with the latest versions of Ansible and the target operating systems.
- Use the role's variables to customize the KVM setup according to your specific requirements.
- Monitor the KVM environment and adjust the settings as needed to optimize performance and security.
- Consider the security implications of enabling remote access to KVM (TCP, TLS) and configure appropriate firewall rules.
- Regularly review and update the list of users with access to KVM to maintain proper access control.

## Default Behavior

By default, the role installs the necessary KVM packages but doesn't enable any advanced configuration options. All configuration-related variables are set to `false` by default, meaning that users, virtual networks, storage pools, and VM management need to be explicitly enabled through variables.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_kvm/defaults/main.yml)
- [tasks/apparmor.yml](../../roles/bootstrap_kvm/tasks/apparmor.yml)
- [tasks/config_kvm.yml](../../roles/bootstrap_kvm/tasks/config_kvm.yml)
- [tasks/config_ssh.yml](../../roles/bootstrap_kvm/tasks/config_ssh.yml)
- [tasks/config_storage_pools.yml](../../roles/bootstrap_kvm/tasks/config_storage_pools.yml)
- [tasks/config_virtual_networks.yml](../../roles/bootstrap_kvm/tasks/config_virtual_networks.yml)
- [tasks/config_vms.yml](../../roles/bootstrap_kvm/tasks/config_vms.yml)
- [tasks/hw_virtualization_check.yml](../../roles/bootstrap_kvm/tasks/hw_virtualization_check.yml)
- [tasks/install_packages_debian.yml](../../roles/bootstrap_kvm/tasks/install_packages_debian.yml)
- [tasks/install_packages_redhat.yml](../../roles/bootstrap_kvm/tasks/install_packages_redhat.yml)
- [tasks/main.yml](../../roles/bootstrap_kvm/tasks/main.yml)
- [tasks/set_facts.yml](../../roles/bootstrap_kvm/tasks/set_facts.yml)
- [tasks/system_tweaks.yml](../../roles/bootstrap_kvm/tasks/system_tweaks.yml)
- [tasks/users.yml](../../roles/bootstrap_kvm/tasks/users.yml)
- [handlers/main.yml](../../roles/bootstrap_kvm/handlers/main.yml)