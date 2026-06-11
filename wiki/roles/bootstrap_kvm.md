---
title: "KVM Bootstrap Role Documentation"
role: bootstrap_kvm
category: Ansible Roles
type: Infrastructure Configuration
tags: kvm, libvirt, virtualization, ansible-role
---

## Summary

The `bootstrap_kvm` role is designed to automate the setup and configuration of a KVM (Kernel-based Virtual Machine) environment on Debian and RedHat-based systems. This role handles package installation, system tweaks, user management, network configuration, storage pool setup, and VM management.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `kvm_allow_root_ssh`                  | `false`                                                                     | Allows root SSH logins if set to `true`.                                                                                                                                                                    |
| `kvm_audit_level`                     | `1`                                                                         | Sets the audit level for libvirt.                                                                                                                                                                         |
| `kvm_audit_logging`                   | `0`                                                                         | Enables or disables audit logging.                                                                                                                                                                        |
| `kvm_auth_unix_ro`                    | `none`                                                                      | Specifies read-only authentication method for UNIX socket connections.                                                                                                                                    |
| `kvm_auth_unix_rw`                    | `none`                                                                      | Specifies read-write authentication method for UNIX socket connections.                                                                                                                                   |
| `kvm_config`                          | `false`                                                                     | Enables or disables the configuration of KVM settings.                                                                                                                                                  |
| `kvm_config_users`                    | `false`                                                                     | Enables or disables user configuration for KVM.                                                                                                                                                         |
| `kvm_config_virtual_networks`         | `false`                                                                     | Enables or disables virtual network configuration.                                                                                                                                                        |
| `kvm_config_storage_pools`            | `false`                                                                     | Enables or disables storage pool configuration.                                                                                                                                                           |
| `kvm_disable_apparmor`                | `false`                                                                     | Disables AppArmor profiles for libvirt if set to `true`.                                                                                                                                                |
| `kvm_enable_mdns`                     | `false`                                                                     | Enables mDNS support in libvirt.                                                                                                                                                                          |
| `kvm_enable_system_tweaks`            | `false`                                                                     | Applies system tweaks as specified by `kvm_sysctl_settings`.                                                                                                                                            |
| `kvm_enable_tcp`                      | `false`                                                                     | Enables TCP listening for libvirt connections.                                                                                                                                                            |
| `kvm_enable_tls`                      | `true`                                                                      | Enables TLS support for secure connections.                                                                                                                                                               |
| `kvm_enable_libvirtd_syslog`          | `false`                                                                     | Enables logging of libvirtd to syslog.                                                                                                                                                                    |
| `kvm_images_cache_mode`               | `none`                                                                      | Sets the cache mode for VM images.                                                                                                                                                                        |
| `kvm_images_format_type`              | `qcow2`                                                                     | Specifies the format type for VM images (e.g., qcow2, raw).                                                                                                                                             |
| `kvm_images_path`                     | `/var/lib/libvirt/images`                                                   | Path where VM images are stored.                                                                                                                                                                          |
| `kvm_keepalive_interval`              | `5`                                                                         | Interval between keep-alive messages in seconds.                                                                                                                                                        |
| `kvm_keepalive_count`                 | `5`                                                                         | Number of keep-alive messages to send before considering a connection dead.                                                                                                                               |
| `kvm_admin_keepalive_interval`        | `5`                                                                         | Keep-alive interval for admin connections.                                                                                                                                                                |
| `kvm_admin_keepalive_count`           | `5`                                                                         | Keep-alive count for admin connections.                                                                                                                                                                   |
| `kvm_listen_addr`                     | `0.0.0.0`                                                                   | IP address to listen on for libvirt connections.                                                                                                                                                        |
| `kvm_log_level`                       | `3`                                                                         | Log level for libvirtd (1-4, where 4 is the most verbose).                                                                                                                                                |
| `kvm_manage_vms`                      | `false`                                                                     | Enables or disables VM management tasks.                                                                                                                                                                  |
| `kvm_max_anonymous_clients`           | `20`                                                                        | Maximum number of anonymous clients allowed.                                                                                                                                                              |
| `kvm_max_client_requests`             | `5`                                                                         | Maximum number of client requests per connection.                                                                                                                                                       |
| `kvm_admin_max_client_requests`       | `5`                                                                         | Maximum number of admin client requests per connection.                                                                                                                                                 |
| `kvm_max_clients`                     | `5000`                                                                      | Maximum number of clients allowed.                                                                                                                                                                        |
| `kvm_admin_max_clients`               | `5`                                                                         | Maximum number of admin clients allowed.                                                                                                                                                                  |
| `kvm_max_queued_clients`              | `1000`                                                                      | Maximum number of queued client connections.                                                                                                                                                              |
| `kvm_admin_max_queued_clients`        | `5`                                                                         | Maximum number of queued admin client connections.                                                                                                                                                      |
| `kvm_max_requests`                    | `20`                                                                        | Maximum number of requests per connection.                                                                                                                                                                |
| `kvm_max_workers`                     | `20`                                                                        | Maximum number of worker threads for handling requests.                                                                                                                                                   |
| `kvm_min_workers`                     | `5`                                                                         | Minimum number of worker threads for handling requests.                                                                                                                                                   |
| `kvm_admin_min_workers`               | `1`                                                                         | Minimum number of admin worker threads for handling requests.                                                                                                                                             |
| `kvm_admin_max_workers`               | `5`                                                                         | Maximum number of admin worker threads for handling requests.                                                                                                                                             |
| `kvm_ovs_timeout`                     | `5`                                                                         | Timeout value for OVS operations in seconds.                                                                                                                                                            |
| `kvm_prio_workers`                    | `5`                                                                         | Number of priority worker threads for handling requests.                                                                                                                                                |
| `kvm_redhat_packages`                 | `[bridge-utils, libvirt-client, libvirt-python, libvirt, qemu-img, qemu-kvm, virt-install, virt-manager, virt-viewer]` | List of packages to install on RedHat-based systems.                                                                                                                                                  |
| `kvm_security_driver`                 | `none`                                                                      | Specifies the security driver for libvirt (e.g., selinux, apparmor).                                                                                                                                    |
| `kvm_sysctl_settings`                 | `[net.bridge.bridge-nf-call-ip6tables=0, net.bridge.bridge-nf-call-iptables=0, net.bridge.bridge-nf-call-arptables=0]` | List of sysctl settings to apply.                                                                                                                                                                       |
| `kvm_tcp_port`                        | `16509`                                                                     | TCP port for libvirt connections.                                                                                                                                                                         |
| `kvm_tls_port`                        | `16514`                                                                     | TLS port for secure libvirt connections.                                                                                                                                                                  |
| `kvm_unix_sock_dir`                   | `/var/run/libvirt`                                                          | Directory for UNIX socket files.                                                                                                                                                                          |
| `kvm_users`                           | `[]`                                                                        | List of users to be added to the KVM group and UNIX socket group.                                                                                                                                         |
| `kvm_virtual_networks`                | `[]`                                                                        | List of virtual networks to define and configure.                                                                                                                                                       |
| `kvm_storage_pools`                   | `[]`                                                                        | List of storage pools to define, set state, and manage autostart.                                                                                                                                       |
| `kvm_vms`                             | `[]`                                                                        | List of VMs to define, create disks for, and manage states.                                                                                                                                               |

## Usage

To use the `bootstrap_kvm` role, include it in your playbook and configure the necessary variables as per your environment requirements.

### Example Playbook

```yaml
---
- name: Bootstrap KVM Environment
  hosts: kvm_hosts
  become: true
  roles:
    - role: bootstrap_kvm
      vars:
        kvm_config: true
        kvm_config_users: true
        kvm_config_virtual_networks: true
        kvm_config_storage_pools: true
        kvm_manage_vms: true
        kvm_users:
          - user1
          - user2
        kvm_virtual_networks:
          - name: default
            state: active
            autostart: true
        kvm_storage_pools:
          - name: default-pool
            path: /var/lib/libvirt/images/default-pool
            state: active
            autostart: true
        kvm_vms:
          - name: vm1
            host: localhost
            disks:
              - size: 20G
            state: running
            autostart: true
```

## Dependencies

- `community.libvirt` Ansible collection for managing libvirt resources.
- `ansible.posix` Ansible collection for system configuration tasks.

Ensure these collections are installed in your environment:

```bash
ansible-galaxy collection install community.libvirt ansible.posix
```

## Best Practices

1. **Security**: Always use TLS (`kvm_enable_tls: true`) to secure libvirt connections.
2. **Resource Management**: Configure appropriate limits for clients and workers based on expected load.
3. **Monitoring**: Enable logging (`kvm_log_level`) and audit logging (`kvm_audit_logging`) for better monitoring and troubleshooting.
4. **User Management**: Manage users carefully by specifying them in `kvm_users` to ensure they have the necessary permissions.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios to validate the role's functionality across different environments.

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