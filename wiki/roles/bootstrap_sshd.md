---
title: "Bootstrap SSH Daemon (SSHD) Role"
role: roles/bootstrap_sshd
category: System
type: Role
tags: [ansible, role, bootstrap_sshd]
---

# Bootstrap SSH Daemon (SSHD) Role

The `bootstrap_sshd` role is designed to configure and manage the OpenSSH SSH daemon (sshd) on various operating systems. This role provides a comprehensive set of options to customize the SSH daemon configuration, including managing service files, handling certificates, configuring firewall and SELinux settings, and more.

## Table of Contents

- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)

## Variables

The following table lists the variables used by this role along with their default values and descriptions:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_sshd__enable` | `true` | Enable or disable the role. |
| `bootstrap_sshd__skip_defaults` | `false` | Skip default configuration values. |
| `bootstrap_sshd__manage_service` | `true` | Manage the SSH service. |
| `bootstrap_sshd__allow_reload` | `true` | Allow reloading the SSH service. |
| `bootstrap_sshd__install_service` | `false` | Install the SSH service files. |
| `bootstrap_sshd__service_template_service` | `sshd.service.j2` | Template for the SSH service file. |
| `bootstrap_sshd__service_template_at_service` | `sshd@.service.j2` | Template for the instanced SSH service file. |
| `bootstrap_sshd__service_template_socket` | `sshd.socket.j2` | Template for the SSH socket file. |
| `bootstrap_sshd__backup` | `true` | Backup existing configuration files. |
| `bootstrap_sshd__sysconfig` | `false` | Enable sysconfig configuration. |
| `bootstrap_sshd__sysconfig_override_crypto_policy` | `false` | Override crypto policy in sysconfig. |
| `bootstrap_sshd__sysconfig_use_strong_rng` | `0` | Use strong RNG in sysconfig. |
| `bootstrap_sshd__config` | `{}` | SSH daemon configuration. |
| `bootstrap_sshd__config_file` | `{{ __bootstrap_sshd__config_file }}` | Path to the SSH daemon configuration file. |
| `bootstrap_sshd__trusted_user_ca_keys_list` | `[]` | List of trusted user CA keys. |
| `bootstrap_sshd__principals` | `{}` | Principals configuration. |
| `bootstrap_sshd__packages` | `{{ __bootstrap_sshd__packages }}` | SSH packages to install. |
| `bootstrap_sshd__config_owner` | `{{ __bootstrap_sshd__config_owner }}` | Owner of the SSH daemon configuration file. |
| `bootstrap_sshd__config_group` | `{{ __bootstrap_sshd__config_group }}` | Group of the SSH daemon configuration file. |
| `bootstrap_sshd__config_mode` | `{{ __bootstrap_sshd__config_mode \| d('0644') }}` | Mode of the SSH daemon configuration file. |
| `bootstrap_sshd__binary` | `{{ __bootstrap_sshd__binary }}` | Path to the SSH daemon binary. |
| `bootstrap_sshd__service` | `{{ __bootstrap_sshd__service }}` | Name of the SSH service. |
| `bootstrap_sshd__sftp_server` | `{{ __bootstrap_sshd__sftp_server }}` | Path to the SFTP server binary. |
| `bootstrap_sshd__drop_in_dir_mode` | `{{ __bootstrap_sshd__drop_in_dir_mode }}` | Mode of the drop-in directory. |
| `bootstrap_sshd__main_config_file` | `{{ __bootstrap_sshd__main_config_file }}` | Path to the main SSH daemon configuration file. |
| `bootstrap_sshd__trustedusercakeys_directory_owner` | `{{ __bootstrap_sshd__trustedusercakeys_directory_owner }}` | Owner of the trusted user CA keys directory. |
| `bootstrap_sshd__trustedusercakeys_directory_group` | `{{ __bootstrap_sshd__trustedusercakeys_directory_group }}` | Group of the trusted user CA keys directory. |
| `bootstrap_sshd__trustedusercakeys_directory_mode` | `{{ __bootstrap_sshd__trustedusercakeys_directory_mode }}` | Mode of the trusted user CA keys directory. |
| `bootstrap_sshd__trustedusercakeys_file_owner` | `{{ __bootstrap_sshd__trustedusercakeys_file_owner }}` | Owner of the trusted user CA keys file. |
| `bootstrap_sshd__trustedusercakeys_file_group` | `{{ __bootstrap_sshd__trustedusercakeys_file_group }}` | Group of the trusted user CA keys file. |
| `bootstrap_sshd__trustedusercakeys_file_mode` | `{{ __bootstrap_sshd__trustedusercakeys_file_mode }}` | Mode of the trusted user CA keys file. |
| `bootstrap_sshd__authorizedprincipals_directory_owner` | `{{ __bootstrap_sshd__authorizedprincipals_directory_owner }}` | Owner of the authorized principals directory. |
| `bootstrap_sshd__authorizedprincipals_directory_group` | `{{ __bootstrap_sshd__authorizedprincipals_directory_group }}` | Group of the authorized principals directory. |
| `bootstrap_sshd__authorizedprincipals_directory_mode` | `{{ __bootstrap_sshd__authorizedprincipals_directory_mode }}` | Mode of the authorized principals directory. |
| `bootstrap_sshd__authorizedprincipals_file_owner` | `{{ __bootstrap_sshd__authorizedprincipals_file_owner }}` | Owner of the authorized principals file. |
| `bootstrap_sshd__authorizedprincipals_file_group` | `{{ __bootstrap_sshd__authorizedprincipals_file_group }}` | Group of the authorized principals file. |
| `bootstrap_sshd__authorizedprincipals_file_mode` | `{{ __bootstrap_sshd__authorizedprincipals_file_mode }}` | Mode of the authorized principals file. |
| `bootstrap_sshd__verify_hostkeys` | `auto` | Verify host keys. |
| `bootstrap_sshd__hostkey_owner` | `{{ __bootstrap_sshd__hostkey_owner }}` | Owner of the host keys. |
| `bootstrap_sshd__hostkey_group` | `{{ __bootstrap_sshd__hostkey_group }}` | Group of the host keys. |
| `bootstrap_sshd__hostkey_mode` | `{{ __bootstrap_sshd__hostkey_mode \| d('0640') }}` | Mode of the host keys. |
| `bootstrap_sshd__config_namespace` | | Configuration namespace. |
| `bootstrap_sshd__manage_firewall` | `false` | Manage firewall settings. |
| `bootstrap_sshd__manage_selinux` | `false` | Manage SELinux settings. |

## Usage

To use this role, include it in your playbook and set the desired variables:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_sshd
      vars:
        bootstrap_sshd__enable: true
        bootstrap_sshd__config:
          PermitRootLogin: "no"
          PasswordAuthentication: "no"
```

## Dependencies

This role requires the following collections:

- `ansible.posix`
- `fedora.linux_system_roles` (version 1.0.0 or later)

## Best Practices

- Always test the role in a development environment before deploying it to production.
- Use the `bootstrap_sshd__backup` variable to ensure that existing configuration files are backed up before making changes.
- Customize the SSH daemon configuration using the `bootstrap_sshd__config` variable to meet your specific requirements.
- Use the `bootstrap_sshd__manage_firewall` and `bootstrap_sshd__manage_selinux` variables to manage firewall and SELinux settings as needed.
- Regularly review and update the role to ensure compatibility with the latest versions of the required collections.
- Document any customizations or overrides made to the role for future reference and troubleshooting.