---
title: "KVM Bootstrap Role Documentation"
role: bootstrap_kvm
category: Ansible Roles
type: Configuration
tags: kvm, libvirt, virtualization
---

## Summary

The `bootstrap_kvm` role is designed to automate the setup and configuration of a KVM (Kernel-based Virtual Machine) environment on Debian and RedHat-based systems. It handles package installation, system configuration, user management, network setup, storage pool creation, and virtual machine deployment.

## Variables

| Variable Name                          | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `kvm_allow_root_ssh`                   | `false`                                                                                                 | Allows root SSH logins if set to `true`.                                                                                                                                                                    |
| `kvm_audit_level`                      | `1`                                                                                                     | Sets the audit level for libvirt.                                                                                                                                                                         |
| `kvm_audit_logging`                    | `0`                                                                                                     | Enables or disables audit logging.                                                                                                                                                                        |
| `kvm_auth_unix_ro`                     | `none`                                                                                                  | Specifies read-only authentication method for UNIX sockets.                                                                                                                                             |
| `kvm_auth_unix_rw`                     | `none`                                                                                                  | Specifies read-write authentication method for UNIX sockets.                                                                                                                                            |
| `kvm_config`                           | `false`                                                                                                 | Enables or disables the configuration of KVM settings.                                                                                                                                                  |
| `kvm_config_users`                     | `false`                                                                                                 | Enables or disables the configuration of KVM users.                                                                                                                                                       |
| `kvm_config_virtual_networks`          | `false`                                                                                                 | Enables or disables the configuration of virtual networks.                                                                                                                                                |
| `kvm_config_storage_pools`             | `false`                                                                                                 | Enables or disables the configuration of storage pools.                                                                                                                                                   |
| `kvm_disable_apparmor`                 | `false`                                                                                                 | Disables AppArmor profiles for libvirt if set to `true`.                                                                                                                                                |
| `kvm_enable_mdns`                      | `false`                                                                                                 | Enables mDNS support in libvirt.                                                                                                                                                                          |
| `kvm_enable_system_tweaks`             | `false`                                                                                                 | Applies system tweaks as defined in `kvm_sysctl_settings`.                                                                                                                                                |
| `kvm_enable_tcp`                       | `false`                                                                                                 | Enables TCP listening for libvirt if set to `true`.                                                                                                                                                         |
| `kvm_enable_tls`                       | `true`                                                                                                  | Enables TLS support for libvirt.                                                                                                                                                                          |
| `kvm_enable_libvirtd_syslog`           | `false`                                                                                                 | Enables logging of libvirtd messages to syslog.                                                                                                                                                           |
| `kvm_images_cache_mode`                | `none`                                                                                                  | Specifies the cache mode for VM images.                                                                                                                                                                   |
| `kvm_images_format_type`               | `qcow2`                                                                                                 | Specifies the format type for VM images (e.g., qcow2, raw).                                                                                                                                                 |
| `kvm_images_path`                      | `/var/lib/libvirt/images`                                                                               | Path where VM images are stored.                                                                                                                                                                          |
| `kvm_keepalive_interval`               | `5`                                                                                                     | Interval in seconds between keepalive messages for TCP connections.                                                                                                                                       |
| `kvm_keepalive_count`                  | `5`                                                                                                     | Number of keepalive messages to send before closing a connection.                                                                                                                                         |
| `kvm_admin_keepalive_interval`         | `5`                                                                                                     | Interval in seconds between keepalive messages for admin TCP connections.                                                                                                                               |
| `kvm_admin_keepalive_count`            | `5`                                                                                                     | Number of keepalive messages to send before closing an admin connection.                                                                                                                                  |
| `kvm_listen_addr`                      | `0.0.0.0`                                                                                               | IP address on which libvirt should listen for connections.                                                                                                                                              |
| `kvm_log_level`                        | `3`                                                                                                     | Log level for libvirt (1-4, where 4 is the most verbose).                                                                                                                                                 |
| `kvm_manage_vms`                       | `false`                                                                                                 | Enables or disables management of virtual machines.                                                                                                                                                       |
| `kvm_max_anonymous_clients`            | `20`                                                                                                    | Maximum number of anonymous clients allowed.                                                                                                                                                              |
| `kvm_max_client_requests`              | `5`                                                                                                     | Maximum number of client requests per connection.                                                                                                                                                         |
| `kvm_admin_max_client_requests`        | `5`                                                                                                     | Maximum number of admin client requests per connection.                                                                                                                                                   |
| `kvm_max_clients`                      | `5000`                                                                                                  | Maximum number of clients allowed.                                                                                                                                                                        |
| `kvm_admin_max_clients`                | `5`                                                                                                     | Maximum number of admin clients allowed.                                                                                                                                                                    |
| `kvm_max_queued_clients`               | `1000`                                                                                                  | Maximum number of queued client connections.                                                                                                                                                              |
| `kvm_admin_max_queued_clients`         | `5`                                                                                                     | Maximum number of queued admin client connections.                                                                                                                                                        |
| `kvm_max_requests`                     | `20`                                                                                                    | Maximum number of requests per connection.                                                                                                                                                                |
| `kvm_max_workers`                      | `20`                                                                                                    | Maximum number of worker threads for handling client requests.                                                                                                                                            |
| `kvm_min_workers`                      | `5`                                                                                                     | Minimum number of worker threads for handling client requests.                                                                                                                                            |
| `kvm_admin_min_workers`                | `1`                                                                                                     | Minimum number of admin worker threads for handling client requests.                                                                                                                                      |
| `kvm_admin_max_workers`                | `5`                                                                                                     | Maximum number of admin worker threads for handling client requests.                                                                                                                                      |
| `kvm_ovs_timeout`                      | `5`                                                                                                     | Timeout in seconds for Open vSwitch operations.                                                                                                                                                           |
| `kvm_prio_workers`                     | `5`                                                                                                     | Number of priority worker threads for handling high-priority tasks.                                                                                                                                       |
| `kvm_redhat_packages`                  | `[bridge-utils, libvirt-client, libvirt-python, libvirt, qemu-img, qemu-kvm, virt-install, virt-manager, virt-viewer]` | List of packages to install on RedHat-based systems.                                                                                                                                                    |
| `kvm_security_driver`                  | `none`                                                                                                  | Specifies the security driver for libvirt (e.g., selinux, apparmor).                                                                                                                                    |
| `kvm_sysctl_settings`                  | `[net.bridge.bridge-nf-call-ip6tables=0, net.bridge.bridge-nf-call-iptables=0, net.bridge.bridge-nf-call-arptables=0]` | List of sysctl settings to apply.                                                                                                                                                                         |
| `kvm_tcp_port`                         | `16509`                                                                                                 | TCP port for libvirt connections.                                                                                                                                                                         |
| `kvm_tls_port`                         | `16514`                                                                                                 | TLS port for libvirt connections.                                                                                                                                                                         |
| `kvm_unix_sock_dir`                    | `/var/run/libvirt`                                                                                      | Directory for UNIX sockets used by libvirt.                                                                                                                                                               |
| `kvm_users`                            | `[]`                                                                                                    | List of users to be added to the KVM group and given access to libvirt.                                                                                                                                   |
| `kvm_virtual_networks`                 | `[]`                                                                                                    | List of virtual networks to define and configure.                                                                                                                                                         |
| `kvm_storage_pools`                    | `[]`                                                                                                    | List of storage pools to define and configure.                                                                                                                                                            |
| `kvm_vms`                              | `[]`                                                                                                    | List of virtual machines to define, create disks for, and manage states.                                                                                                                                |

## Usage

To use the `bootstrap_kvm` role, include it in your playbook and set the appropriate variables as needed. Here is an example playbook:

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
            path: /var/lib/libvirt/images
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
- Required packages such as `bridge-utils`, `libvirt-client`, `qemu-kvm`, etc., depending on the OS family.

## Tags

The following tags are available to control which parts of the role are executed:

- `config_kvm`: Configures KVM settings.
- `config_users`: Manages KVM users.
- `config_ssh`: Configures SSH for root logins (if enabled).
- `config_virtual_networks`: Defines and configures virtual networks.
- `config_storage_pools`: Defines and configures storage pools.
- `config_vms`: Defines, creates disks for, and manages states of virtual machines.

## Best Practices

- Ensure that the target hosts have the necessary permissions to install packages and configure system settings.
- Use tags to selectively run parts of the role during playbook execution.
- Review and customize variables as needed to fit your specific environment requirements.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to create test scenarios using Molecule to ensure the role functions correctly in different environments.

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