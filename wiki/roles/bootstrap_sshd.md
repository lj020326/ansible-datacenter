---
title: "Bootstrap Sshd Role"
role: roles/bootstrap_sshd
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_sshd]
---

# Role Documentation: `bootstrap_sshd`

## Overview

The `bootstrap_sshd` role is designed to configure and manage the OpenSSH SSH daemon (`sshd`) on various operating systems, including Debian, Ubuntu, FreeBSD, EL (CentOS/RHEL), Fedora, OpenBSD, AIX, and Alpine. This role handles installation, configuration, service management, firewall rules, SELinux policies, and more.

## Role Variables

### Default Variables

The default variables for this role are defined in `defaults/main.yml`. These can be overridden by the user to customize the behavior of the role.

| Variable Name                             | Description                                                                                         | Default Value                                                                                                                                                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sshd_enable`                             | Enable or disable the SSH daemon configuration.                                                   | `true`                                                                                                                                                                                                        |
| `sshd_skip_defaults`                      | Skip applying default configurations.                                                             | `false`                                                                                                                                                                                                       |
| `sshd_manage_service`                     | Manage the SSH service (start, stop, restart).                                                    | `true`                                                                                                                                                                                                        |
| `sshd_allow_reload`                       | Allow reloading of the SSH service without restarting it.                                         | `true`                                                                                                                                                                                                        |
| `sshd_install_service`                    | Install custom systemd service files.                                                             | `false`                                                                                                                                                                                                       |
| `sshd_service_template_service`           | Template file for the main SSH service unit.                                                      | `sshd.service.j2`                                                                                                                                                                                             |
| `sshd_service_template_at_service`        | Template file for the instanced SSH service unit.                                                 | `sshd@.service.j2`                                                                                                                                                                                            |
| `sshd_service_template_socket`            | Template file for the SSH socket unit.                                                            | `sshd.socket.j2`                                                                                                                                                                                              |
| `sshd_backup`                             | Backup existing configuration files before overwriting them.                                      | `true`                                                                                                                                                                                                        |
| `sshd_sysconfig`                          | Manage `/etc/sysconfig/sshd` on RedHat-based systems.                                             | `false`                                                                                                                                                                                                       |
| `sshd_sysconfig_override_crypto_policy`   | Override the system's crypto policy in `/etc/sysconfig/sshd`.                                     | `false`                                                                                                                                                                                                       |
| `sshd_sysconfig_use_strong_rng`           | Use a strong random number generator in `/etc/sysconfig/sshd`.                                    | `0`                                                                                                                                                                                                           |
| `sshd`                                    | Dictionary to hold SSHD configuration options.                                                      | `{}`                                                                                                                                                                                                          |
| `sshd_config_file`                        | Path to the main SSHD configuration file.                                                         | `{{ __sshd_config_file }}`                                                                                                                                                    |
| `sshd_trusted_user_ca_keys_list`          | List of trusted user CA keys.                                                                     | `[]`                                                                                                                                                                                                        |
| `sshd_principals`                         | Dictionary of authorized principals for users.                                                    | `{}`                                                                                                                                                                                                          |
| `sshd_packages`                           | List of packages to install for SSHD.                                                             | `{{ __sshd_packages }}`                                                                                                                                                                                       |
| `sshd_config_owner`                       | Owner of the SSHD configuration file.                                                             | `{{ __sshd_config_owner }}`                                                                                                                                                                                   |
| `sshd_config_group`                       | Group owner of the SSHD configuration file.                                                       | `{{ __sshd_config_group }}`                                                                                                                                                                                   |
| `sshd_config_mode`                        | Permissions for the SSHD configuration file.                                                      | `0644`                                                                                                                                                                                                        |
| `sshd_binary`                             | Path to the SSHD binary.                                                                          | `{{ __sshd_binary }}`                                                                                                                                                                                         |
| `sshd_service`                            | Name of the SSH service.                                                                          | `{{ __sshd_service }}`                                                                                                                                                                                        |
| `sshd_sftp_server`                        | Path to the SFTP server binary.                                                                   | `{{ __sshd_sftp_server }}`                                                                                                                                                                                    |
| `sshd_drop_in_dir_mode`                   | Permissions for the drop-in configuration directory.                                              | `{{ __sshd_drop_in_dir_mode }}`                                                                                                                                                                               |
| `sshd_main_config_file`                   | Path to the main SSHD configuration file (without `.d`).                                          | `{{ __sshd_main_config_file }}`                                                                                                                                                                               |
| `sshd_trustedusercakeys_directory_owner`  | Owner of the trusted user CA keys directory.                                                    | `{{ __sshd_trustedusercakeys_directory_owner }}`                                                                                                                                                              |
| `sshd_trustedusercakeys_directory_group`  | Group owner of the trusted user CA keys directory.                                                | `{{ __sshd_trustedusercakeys_directory_group }}`                                                                                                                                                              |
| `sshd_trustedusercakeys_directory_mode`   | Permissions for the trusted user CA keys directory.                                               | `{{ __sshd_trustedusercakeys_directory_mode }}`                                                                                                                                                               |
| `sshd_trustedusercakeys_file_owner`       | Owner of the trusted user CA keys file.                                                         | `{{ __sshd_trustedusercakeys_file_owner }}`                                                                                                                                                                   |
| `sshd_trustedusercakeys_file_group`       | Group owner of the trusted user CA keys file.                                                     | `{{ __sshd_trustedusercakeys_file_group }}`                                                                                                                                                                   |
| `sshd_trustedusercakeys_file_mode`        | Permissions for the trusted user CA keys file.                                                    | `{{ __sshd_trustedusercakeys_file_mode }}`                                                                                                                                                                    |
| `sshd_authorizedprincipals_directory_owner` | Owner of the authorized principals directory.                                                   | `{{ __sshd_authorizedprincipals_directory_owner }}`                                                                                                                                                           |
| `sshd_authorizedprincipals_directory_group` | Group owner of the authorized principals directory.                                             | `{{ __sshd_authorizedprincipals_directory_group }}`                                                                                                                                                           |
| `sshd_authorizedprincipals_directory_mode`  | Permissions for the authorized principals directory.                                              | `{{ __sshd_authorizedprincipals_directory_mode }}`                                                                                                                                                            |
| `sshd_authorizedprincipals_file_owner`      | Owner of the authorized principals file.                                                        | `{{ __sshd_authorizedprincipals_file_owner }}`                                                                                                                                                                |
| `sshd_authorizedprincipals_file_group`      | Group owner of the authorized principals file.                                                  | `{{ __sshd_authorizedprincipals_file_group }}`                                                                                                                                                                |
| `sshd_authorizedprincipals_file_mode`       | Permissions for the authorized principals file.                                                   | `{{ __sshd_authorizedprincipals_file_mode }}`                                                                                                                                                                 |
| `sshd_verify_hostkeys`                    | Verify host keys during installation.                                                             | `auto`                                                                                                                                                                                                        |
| `sshd_hostkey_owner`                      | Owner of the SSHD host key files.                                                                 | `{{ __sshd_hostkey_owner }}`                                                                                                                                                                                  |
| `sshd_hostkey_group`                      | Group owner of the SSHD host key files.                                                           | `{{ __sshd_hostkey_group }}`                                                                                                                                                                                  |
| `sshd_hostkey_mode`                       | Permissions for the SSHD host key files.                                                          | `0640`                                                                                                                                                                                                        |
| `sshd_config_namespace`                   | Namespace for configuration snippets.                                                             | `{}`                                                                                                                                                                                                          |
| `sshd_manage_firewall`                    | Manage firewall rules for SSH ports.                                                              | `false`                                                                                                                                                                                                       |
| `sshd_manage_selinux`                     | Manage SELinux policies for custom SSH ports.                                                     | `false`                                                                                                                                                                                                       |

### Variable Precedence

Variables can be overridden in the following order of precedence:

1. Playbook variables.
2. Inventory group or host variables.
3. Role defaults.

## Tasks

The role is structured into several tasks files, each responsible for a specific aspect of SSHD configuration and management.

### `tasks/certificates.yml`

- **Configure Trusted User CA Keys**: Creates the directory for trusted user CA keys and copies the key file to the specified location.
- **Configure Principals**: Creates directories and copies authorized principals files if `sshd_principals` is defined.

### `tasks/check_fips.yml`

- **Check Kernel FIPS Mode**: Reads the kernel FIPS mode from `/proc/sys/crypto/fips_enabled`.
- **Check Userspace FIPS Mode**: Reads the userspace FIPS mode from `/etc/system-fips`.

### `tasks/find_ports.yml`

- **Find SSH Service Port**: Determines the port(s) that the SSH service will use, considering default and custom configurations.

### `tasks/firewall.yml`

- **Ensure SSH Service or Custom Ports are Opened in Firewall**: Uses the `fedora.linux_system_roles.firewall` role to open necessary ports in the firewall.

### `tasks/install.yml`

- **OS Support Check**: Ends the host if the OS is not supported.
- **Install SSH Packages**: Installs the required SSH packages.
- **Sysconfig Configuration**: Configures `/etc/sysconfig/sshd` on RedHat-based systems.
- **Check FIPS Mode**: Includes tasks to check FIPS mode.
- **Host Key Management**: Ensures host keys are available and have the correct permissions.

### `tasks/install_config.yml`

- **Create Drop-In Directory**: Creates a directory for drop-in configuration snippets if necessary.
- **Create Complete Configuration File**: Generates the main SSHD configuration file from a template.
- **Include Path in Main Config**: Adds an include path to the main SSHD configuration file to load drop-in configurations.

### `tasks/install_namespace.yml`

- **Update Configuration File Snippet**: Updates the configuration file snippet with namespace-specific settings.

### `tasks/install_service.yml`

- **Install Systemd Service Files**: Installs custom systemd service files if required.
- **Service Management**: Ensures the SSH service is enabled and running.

### `tasks/main.yml`

- **Invoke Role Tasks**: Includes the main tasks file (`sshd.yml`) if the role is enabled.

### `tasks/selinux.yml`

- **Ensure Custom Ports are Configured in SELinux**: Uses the `fedora.linux_system_roles.selinux` role to configure custom SSH ports in SELinux.

### `tasks/sshd.yml`

- **Set Platform/Version Specific Variables**: Includes tasks to set platform-specific variables.
- **Execute Role Tasks**: Includes the main installation tasks.

### `tasks/variables.yml`

- **Ensure Ansible Facts Used by Role**: Gathers necessary facts if not already available.
- **Determine OSTree System**: Checks if the system is an OSTree-based system and sets a flag accordingly.
- **Set OS Dependent Variables**: Loads OS-specific variables based on the distribution and version.

## Handlers

The role includes handlers to manage service reloads:

- **Reload SSH Service**: Reloads the SSH service without restarting it, unless specific conditions are met (e.g., AIX or OpenWrt).

## Dependencies

This role depends on the following collections:

- `ansible.posix`
- `fedora.linux_system_roles`

These collections should be installed in your Ansible environment.

## Example Playbook

```yaml
---
- name: Configure SSHD on multiple hosts
  hosts: all
  become: yes
  roles:
    - role: dettonville.bootstrap_sshd
      vars:
        sshd_Enable: true
        sshd_skip_defaults: false
        sshd_manage_service: true
        sshd_allow_reload: true
        sshd_install_service: false
        sshd_trusted_user_ca_keys_list:
          - /etc/ssh/trusted-user-ca-keys.pub
        sshd_principals:
          user1: /etc/ssh/user1.principals
          user2: /etc/ssh/user2.principals
```

## License

This role is licensed under the LGPLv3 license.

## Author Information

- **Author**: Lee Johnson
- **Company**: Dettonville

## Supported Platforms

The role supports the following platforms and versions:

- Debian (wheezy, jessie, stretch, buster, bullseye, bookworm)
- Ubuntu (precise, trusty, xenial, bionic, focal, jammy, noble)
- FreeBSD (10.1)
- EL (6, 7, 8, 9)
- Fedora (all)
- OpenBSD (6.0)
- AIX (7.1, 7.2)
- Alpine (all)

## Notes

- Double-underscore variables are internal only and should not be modified.
- This role does not invent related roles; it relies on existing Ansible collections for additional functionality like firewall and SELinux management.

This documentation provides a comprehensive overview of the `bootstrap_sshd` role, its variables, tasks, handlers, dependencies, and example usage.