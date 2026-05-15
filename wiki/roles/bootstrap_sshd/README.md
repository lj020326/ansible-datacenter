```markdown
---
title: OpenSSH Server Configuration Role Documentation
original_path: roles/bootstrap_sshd/README.md
category: Ansible Roles
tags: [OpenSSH, SSHD, Ansible, Configuration]
---

# OpenSSH Server Configuration Role

This role configures the OpenSSH daemon. It:

- By default, configures the SSH daemon with the normal OS defaults.
- Works across a variety of `UN*X` distributions.
- Can be configured using dictionaries or simple variables.
- Supports Match sets.
- Supports all `sshd_config` options. Templates are programmatically generated (see [`meta/make_option_lists`](meta/make_option_lists)).
- Tests the `sshd_config` before reloading sshd.

**WARNING:** Misconfiguration of this role can lock you out of your server! Please test your configuration and its interaction with your users' configurations before using in production!

**WARNING:** Digital Ocean allows root access via SSH passwords on Debian and Ubuntu. This module sets `PermitRootLogin without-password` by default, allowing access via SSH keys but not simple passwords. If you need this functionality, set `bootstrap_sshd__PermitRootLogin yes` for those hosts.

## Requirements

- **Ubuntu:** precise, trusty, xenial, bionic, focal, jammy, noble
- **Debian:** wheezy, jessie, stretch, buster, bullseye, bookworm
- **EL (Enterprise Linux):** 6, 7, 8, 9, 10 derived distributions
- **Fedora:** All versions
- **Alpine:** Latest version
- **FreeBSD:** 10.1
- **OpenBSD:** 6.0
- **AIX:** 7.1, 7.2
- **OpenWrt:** 21.03

It will likely work on other flavors and more direct support via suitable [vars/](vars/) files is welcome.

### Optional Requirements

If you want to use advanced functionality of this role that can configure firewall and SELinux for you, which is mostly useful when a custom port is used, the role requires additional collections specified in `meta/collection-requirements.yml`. These are not automatically installed. If you want to manage `rpm-ostree` systems, additional collections are required. Install them like this:

```bash
ansible-galaxy install -vv -r meta/collection-requirements.yml
```

For more information, see the `bootstrap_sshd__manage_firewall` and `bootstrap_sshd__manage_selinux` options below, and the `rpm-ostree` section. This additional functionality is supported only on Red Hat-based Linux.

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
| `bootstrap_sshd__packages`                             | `"{{ __bootstrap_sshd__packages }}"`                               | List of packages to install.                                               |

... [truncated - large file] ...

## Backlinks

- [Ansible Roles Documentation](/ansible-roles)
- [OpenSSH Configuration Best Practices](/openssh-best-practices)

```

This improved version includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation and context.