---
title: OpenSSH Server Role
original_path: roles/bootstrap_sshd/README.md
category: Ansible Roles
tags: [SSH, OpenSSH, Server, Configuration, Security]
harvested_date: '2026-08-07T18:07:09.418225+00:00'
source_type: legacy_markdown
---

# OpenSSH Server Role

This role configures the OpenSSH daemon. It:

- By default configures the SSH daemon with the normal OS defaults.
- Works across a variety of `UN*X` distributions.
- Can be configured by dict or simple variables.
- Supports Match sets.
- Supports all `sshd_config` options. Templates are programmatically generated.
  (see [`meta/make_option_lists`](meta/make_option_lists)).
- Tests the `sshd_config` before reloading sshd.

**WARNING:** Misconfiguration of this role can lock you out of your server!
Please test your configuration and its interaction with your users configuration
before using in production!

**WARNING:** Digital Ocean allows root with passwords via SSH on Debian and
Ubuntu. This is not the default assigned by this module - it will set
`PermitRootLogin without-password` which will allow access via SSH key but not
via simple password. If you need this functionality, be sure to set
`bootstrap_sshd__PermitRootLogin yes` for those hosts.

## Requirements

- Ubuntu precise, trusty, xenial, bionic, focal, jammy, noble
- Debian wheezy, jessie, stretch, buster, bullseye, bookworm
- EL 6, 7, 8, 9, 10 derived distributions
- All Fedora
- Latest Alpine
- FreeBSD 10.1
- OpenBSD 6.0
- AIX 7.1, 7.2
- OpenWrt 21.03

It will likely work on other flavors and more direct support via suitable
[vars/](vars/) files is welcome.

### Optional Requirements

If you want to use advanced functionality of this role that can configure
firewall and SELinux for you, which is mostly useful when custom port is used,
the role requires additional collections which are specified in
`meta/collection-requirements.yml`. These are not automatically installed.
If you want to manage `rpm-ostree` systems, additional collections are required.
You must install them like this:

```bash
ansible-galaxy install -vv -r meta/collection-requirements.yml
```

For more information, see `bootstrap_sshd__manage_firewall` and `bootstrap_sshd__manage_selinux`
options below, and the `rpm-ostree` section.  This additional functionality is
supported only on Red Hat based Linux.

## Variables

| Variable Name                                          | Default Value                                                    | Description                                                                |
|--------------------------------------------------------|------------------------------------------------------------------|----------------------------------------------------------------------------|
| `bootstrap_sshd__enable`                               | `true`                                                           | Enable or disable the execution of this role.                              |
| `bootstrap_sshd__skip_defaults`                        | `false`                                                          | Skip applying default configurations if set to true.                       |
| `bootstrap_sshd__manage_service`                       | `true`                                                           | Manage the SSH service (start, stop, enable, disable).                     |
| `bootstrap_sshd__allow_reload`                         | `true`                                                           | Allow reloading of the SSH service when configuration changes are made.    |
| `bootstrap_sshd__install_service`                      | `false`                                                          | Install custom systemd service files for SSHD.                             |
| `bootstrap_sshd__service_template_service`             | `sshd.service.j2`                                                | Template file for the main SSHD service unit.                              |
| `bootstrap_sshd__service_template_at_service`          | `sshd@.service.j2`                                               | Template file for the instanced SSHD service unit.                         |
| `bootstrap_sshd__service_template_socket`              | `sshd.socket.j2`                                                 | Template file for the SSHD socket unit.                                    |
| `bootstrap_sshd__backup`                               | `true`                                                           | Backup existing configuration files before making changes.                 |
| `bootstrap_sshd__sysconfig`                            | `false`                                                          | Manage the `/etc/sysconfig/sshd` file on RedHat-based systems.             |
| `bootstrap_sshd__sysconfig_override_crypto_policy`     | `false`                                                          | Override the crypto policy in the sysconfig file.                          |
| `bootstrap_sshd__sysconfig_use_strong_rng`             | `0`                                                              | Use a strong random number generator in the sysconfig file.                |
| `bootstrap_sshd__config`                               | `{}`                                                             | Custom SSHD configuration options as a dictionary.                         |
| `bootstrap_sshd__config_file`                          | `"{{ __bootstrap_sshd__config_file }}"`                          | Path to the main SSHD configuration file.                                  |
| `bootstrap_sshd__trusted_user_ca_keys_list`            | `[]`                                                             | List of trusted user CA keys.                                              |
| `bootstrap_sshd__principals`                           | `{}`                                                             | Dictionary of authorized principals for users.                             |
| `bootstrap_sshd__packages`                             | `"{{ __bootstrap_sshd__packages }}"`                             | List of packages to install.                                               |

## Examples

### Basic Usage

```yaml
- hosts: all
  roles:
    - bootstrap_sshd
```

### Custom Configuration

```yaml
- hosts: all
  roles:
    - role: bootstrap_sshd
      vars:
        bootstrap_sshd__config:
          PermitRootLogin: "without-password"
          PasswordAuthentication: "no"
```

## Testing Configuration

The role tests the `sshd_config` before reloading sshd to ensure that the configuration is valid. This is done by using the `sshd -T` command to parse the configuration file and check for syntax errors.

## Idempotency

This role is designed to be idempotent, meaning that applying the role multiple times should not result in different outcomes. The role will only make changes if the configuration has changed.

## Using Match Sets

Match sets allow you to apply configuration options to specific users, groups, or hosts. For example:

```yaml
bootstrap_sshd__config:
  Match User ansible:
    ForceCommand: /usr/bin/ansible-playbook
```

## Error Handling and Troubleshooting

If you encounter issues with this role, please check the following:

1. Ensure that the required packages are installed.
2. Verify that the configuration file is valid by running `sshd -T` manually.
3. Check the logs for any error messages.
4. If you are using a custom port, make sure that the firewall and SELinux settings are correctly configured.

## Backlinks

- [Link to related documentation or pages](URL)