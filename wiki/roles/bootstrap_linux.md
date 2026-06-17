---
title: Bootstrap Linux Role Documentation
role: bootstrap_linux
category: System Configuration
type: Ansible Role
tags: linux, bootstrap, configuration, automation
---

## Summary

The `bootstrap_linux` role is designed to perform a comprehensive setup and configuration of a Linux system. This includes setting up essential services, configuring security settings, installing necessary packages, and ensuring the system is ready for further deployment tasks. The role provides flexibility through various variables that allow customization based on specific requirements.

## Variables

| Variable Name                                 | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux__os_python_interpreter`      | `/usr/bin/env python3`                                                      | Specifies the Python interpreter to be used by Ansible.                                                                                                                                                       |
| `bootstrap_linux__firewalld_default_zone`     | `internal`                                                                    | Sets the default zone for firewalld.                                                                                                                                                                        |
| `bootstrap_linux__firewalld_enabled`          | `true`                                                                        | Enables or disables firewalld on the system.                                                                                                                                                                |
| `bootstrap_linux__firewalld_ports__linux`     | `[10000/tcp]`                                                                 | List of ports to be opened in firewalld for Linux systems.                                                                                                                                                    |
| `bootstrap_linux__firewalld_services__ssh`    | `[{name: ssh}]`                                                               | List of services to be enabled in firewalld, specifically SSH.                                                                                                                                            |
| `bootstrap_linux__firewalld_default_zone_networks` | `[127.0.0.0/8, 172.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16]`                    | List of networks to be associated with the default firewalld zone.                                                                                                                                          |
| `bootstrap_linux__install_vmware_tools`       | `false`                                                                       | Installs VMware Tools if set to true.                                                                                                                                                                       |
| `bootstrap_linux__setup_ntp`                  | `true`                                                                        | Configures NTP on the system for time synchronization.                                                                                                                                                      |
| `bootstrap_linux__setup_firewalld`            | `true`                                                                        | Sets up and configures firewalld according to specified settings.                                                                                                                                           |
| `bootstrap_linux__setup_postfix`              | `true`                                                                        | Installs and configures Postfix for email handling.                                                                                                                                                         |
| `bootstrap_linux__setup_java`                 | `true`                                                                        | Installs Java on the system.                                                                                                                                                                                |
| `bootstrap_linux__setup_sshd`                 | `true`                                                                        | Configures SSH daemon settings.                                                                                                                                                                             |
| `bootstrap_linux__setup_ldap_client`          | `true`                                                                        | Sets up LDAP client configuration for user authentication.                                                                                                                                                    |
| `bootstrap_linux__setup_logrotate`            | `true`                                                                        | Configures log rotation policies to manage log files efficiently.                                                                                                                                           |
| `bootstrap_linux__setup_nfs`                  | `true`                                                                        | Installs and configures NFS service for network file sharing.                                                                                                                                               |
| `bootstrap_linux__setup_samba_client`         | `false`                                                                       | Sets up Samba client configuration if needed.                                                                                                                                                               |
| `bootstrap_linux__setup_webmin`               | `true`                                                                        | Installs and configures Webmin for web-based system administration.                                                                                                                                         |
| `bootstrap_linux__setup_network`              | `true`                                                                        | Configures network settings on the system.                                                                                                                                                                  |
| `bootstrap_linux__setup_stepca`               | `false`                                                                       | Sets up step-ca for certificate authority services if required.                                                                                                                                             |
| `bootstrap_linux__setup_caroot`               | `false`                                                                       | Configures caroot settings if applicable.                                                                                                                                                                   |
| `bootstrap_linux__setup_crons`                | `true`                                                                        | Manages cron jobs on the system.                                                                                                                                                                            |
| `bootstrap_linux__setup_docker`               | `false`                                                                       | Installs and configures Docker for container management.                                                                                                                                                    |
| `bootstrap_linux__setup_gpu_drivers`          | `false`                                                                       | Installs GPU drivers if necessary for systems with NVIDIA GPUs.                                                                                                                                             |
| `bootstrap_linux__deploy_ca_certs`            | `false`                                                                       | Deploys CA certificates to the system if required.                                                                                                                                                          |
| `bootstrap_linux__deploy_pki_certs`           | `true`                                                                        | Deploys PKI certificates to the system for secure communication.                                                                                                                                            |
| `bootstrap_linux__harden`                     | `false`                                                                       | Applies hardening measures to enhance system security.                                                                                                                                                    |
| `bootstrap_linux__container_types`            | `[docker, container, containerd]`                                             | List of container types supported by the role.                                                                                                                                                              |

## Usage

To use the `bootstrap_linux` role in your Ansible playbook, include it as follows:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux
      vars:
        bootstrap_linux__setup_ntp: false
        bootstrap_linux__install_vmware_tools: true
```

This example disables NTP setup and enables VMware Tools installation.

## Dependencies

The `bootstrap_linux` role depends on the following roles:

- `bootstrap_pip`
- `bootstrap_ansible_user`
- `bootstrap_linux_user`
- `bootstrap_linux_package`
- `bootstrap_linux_core`
- `bootstrap_linux_mount`
- `bootstrap_linux_cron`
- `bootstrap_vmware_tools`
- `bootstrap_logrotate`
- `bootstrap_ntp`
- `bootstrap_postfix`
- `bootstrap_java`
- `bootstrap_linux_firewalld`
- `bootstrap_sshd`
- `bootstrap_ldap_client`
- `bootstrap_nfs_service`
- `bootstrap_samba_client`
- `bootstrap_stepca`
- `deploy_ca_certs`
- `deploy_pki_certs`
- `bootstrap_webmin`
- `bootstrap_gpu_drivers`
- `bootstrap_docker`
- `harden_os_linux`

Ensure these roles are available in your Ansible environment.

## Best Practices

1. **Customize Variables:** Adjust the role variables to fit your specific requirements.
2. **Test Thoroughly:** Use Molecule tests or similar tools to verify that the role behaves as expected on different systems.
3. **Security Considerations:** Enable hardening measures (`bootstrap_linux__harden`) and manage certificates appropriately.
4. **Documentation:** Maintain clear documentation of any customizations made to the role.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to create test scenarios using Molecule to ensure the role functions correctly across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux/defaults/main.yml)
- [tasks/disable-systemd-tmpmount.yml](../../roles/bootstrap_linux/tasks/disable-systemd-tmpmount.yml)
- [tasks/main.yml](../../roles/bootstrap_linux/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_linux/handlers/main.yml)