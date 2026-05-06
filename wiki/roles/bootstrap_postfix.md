---
title: "Bootstrap Postfix Role"
role: roles/bootstrap_postfix
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_postfix]
---

# Role Documentation: `bootstrap_postfix`

## Overview

The `bootstrap_postfix` Ansible role is designed to automate the installation, configuration, and management of Postfix on a target system. This role handles various aspects of Postfix setup, including package installation, service management, and configuration file customization.

## Role Variables

### Default Variables

All variables in this role are prefixed with `bootstrap_postfix__` to avoid conflicts with other roles or playbooks. Below is a comprehensive list of default variables along with their descriptions:

| Variable Name                                  | Description                                                                                           | Default Value                                                                 |
|------------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `bootstrap_postfix__config_file`               | Path to the main Postfix configuration file.                                                        | `/etc/postfix/main.cf`                                                      |
| `bootstrap_postfix__service_name`              | The name of the Postfix service.                                                                      | `postfix`                                                                     |
| `bootstrap_postfix__service_state`             | Desired state of the Postfix service (`started`, `stopped`).                                          | `started`                                                                   |
| `bootstrap_postfix__service_enabled`           | Whether to enable the Postfix service at boot time.                                                   | `true`                                                                      |
| `bootstrap_postfix__service_packages`          | List of packages to install for Postfix.                                                              | `['postfix', 'postfix-pcre']`                                               |
| `bootstrap_postfix__hostname`                  | Fully Qualified Domain Name (FQDN) of the host.                                                       | `{{ ansible_facts['fqdn'] }}`                                                 |
| `bootstrap_postfix__mailname`                  | Mail name for the system, typically the FQDN.                                                         | `{{ ansible_facts['fqdn'] }}`                                                 |
| `bootstrap_postfix__compatibility_level`       | Postfix compatibility level to use.                                                                   | `3.6`                                                                       |
| `bootstrap_postfix__map_type`                  | Type of map files used by Postfix (e.g., `hash`).                                                     | `"hash"`                                                                    |
| `bootstrap_postfix__aliases`                   | List of email aliases.                                                                                | `[]`                                                                        |
| `bootstrap_postfix__virtual_aliases`           | List of virtual email aliases.                                                                        | `[]`                                                                        |
| `bootstrap_postfix__sender_canonical_maps`     | Sender canonical maps configuration.                                                                  | `[]`                                                                        |
| `bootstrap_postfix__sender_canonical_maps_database_type` | Database type for sender canonical maps.                                                      | `"{{ bootstrap_postfix__map_type }}"`                                         |
| `bootstrap_postfix__recipient_canonical_maps`  | Recipient canonical maps configuration.                                                               | `[]`                                                                        |
| `bootstrap_postfix__recipient_canonical_maps_database_type` | Database type for recipient canonical maps.                                                 | `"{{ bootstrap_postfix__map_type }}"`                                         |
| `bootstrap_postfix__transport_maps`            | Transport maps configuration.                                                                         | `[]`                                                                        |
| `bootstrap_postfix__transport_maps_database_type` | Database type for transport maps.                                                                   | `"{{ bootstrap_postfix__map_type }}"`                                         |
| `bootstrap_postfix__sender_dependent_relayhost_maps` | Sender-dependent relay host maps configuration.                                                   | `[]`                                                                        |
| `bootstrap_postfix__smtp_header_checks`        | SMTP header checks configuration.                                                                     | `[]`                                                                        |
| `bootstrap_postfix__smtp_header_checks_database_type` | Database type for SMTP header checks.                                                           | `"{{ bootstrap_postfix__map_type }}"`                                         |
| `bootstrap_postfix__smtp_generic_maps`         | SMTP generic maps configuration.                                                                      | `[]`                                                                        |
| `bootstrap_postfix__smtp_generic_maps_database_type` | Database type for SMTP generic maps.                                                              | `"{{ bootstrap_postfix__map_type }}"`                                         |
| `bootstrap_postfix__relayhost`                 | Relay host to use for outgoing mail.                                                                  | `""`                                                                        |
| `bootstrap_postfix__relayhost_mxlookup`        | Whether to perform MX lookup for the relay host.                                                      | `false`                                                                     |
| `bootstrap_postfix__relayhost_port`            | Port number for the relay host.                                                                       | `587`                                                                       |
| `bootstrap_postfix__relaytls`                  | Whether to use TLS with the relay host.                                                               | `false`                                                                     |
| `bootstrap_postfix__sasl_auth_enable`          | Enable SASL authentication.                                                                         | `true`                                                                      |
| `bootstrap_postfix__sasl_user`                 | SASL username for authentication.                                                                     | `postmaster@{{ ansible_domain }}`                                             |
| `bootstrap_postfix__sasl_password`             | SASL password for authentication.                                                                     | `k8+haga4@#pR`                                                              |
| `bootstrap_postfix__sasl_security_options`     | Security options for SASL authentication.                                                           | `noanonymous`                                                               |
| `bootstrap_postfix__sasl_tls_security_options` | TLS security options for SASL authentication.                                                       | `noanonymous`                                                               |
| `bootstrap_postfix__sasl_mechanism_filter`     | Filter for SASL mechanisms to use.                                                                    | `""`                                                                        |
| `bootstrap_postfix__smtp_tls_security_level`   | Security level for SMTP TLS.                                                                        | `encrypt`                                                                   |
| `bootstrap_postfix__smtp_tls_wrappermode`      | Whether to use TLS wrapper mode.                                                                      | `false`                                                                     |
| `bootstrap_postfix__smtp_tls_note_starttls_offer` | Whether to offer STARTTLS in the SMTP banner.                                                     | `true`                                                                      |
| `bootstrap_postfix__inet_interfaces`           | Interfaces Postfix should listen on (`all`, `loopback-only`).                                         | `all`                                                                       |
| `bootstrap_postfix__inet_protocols`            | Protocols Postfix should support (`all`, `ipv4`, `ipv6`).                                           | `all`                                                                       |
| `bootstrap_postfix__mydestination`             | List of domains that this mail system considers local.                                                | `[ "{{ bootstrap_postfix__hostname }}", "localdomain", "localhost", "localhost.localdomain" ]` |
| `bootstrap_postfix__mynetworks`                | Networks considered as trusted.                                                                       | `[ "127.0.0.0/8", "[::ffff:127.0.0.0]/104", "[::1]/128" ]`                   |
| `bootstrap_postfix__smtpd_banner`              | Banner to display in the SMTP greeting message.                                                       | `$myhostname ESMTP $mail_name (Ubuntu)`                                       |
| `bootstrap_postfix__disable_vrfy_command`      | Whether to disable the VRFY command.                                                                  | `true`                                                                      |
| `bootstrap_postfix__message_size_limit`        | Maximum size of a message, in bytes.                                                                | `10240000`                                                                  |
| `bootstrap_postfix__smtpd_use_tls`             | Whether to use TLS for incoming connections.                                                        | `false`                                                                     |
| `bootstrap_postfix__smtpd_tls_cert_file`       | Path to the TLS certificate file.                                                                   | `/etc/ssl/certs/ssl-cert-snakeoil.pem`                                      |
| `bootstrap_postfix__smtpd_tls_key_file`        | Path to the TLS key file.                                                                           | `/etc/ssl/private/ssl-cert-snakeoil.key`                                    |
| `bootstrap_postfix__raw_options`               | Additional raw options to add to `main.cf`.                                                         | `[]`                                                                        |
| `bootstrap_postfix__backup_configs`            | Whether to back up existing configuration files before overwriting.                                   | `true`                                                                      |
| `bootstrap_postfix__main_cf`                   | Path to the main Postfix configuration file.                                                        | `/etc/postfix/main.cf`                                                      |
| `bootstrap_postfix__master_cf`                 | Path to the master Postfix configuration file.                                                      | `/etc/postfix/master.cf`                                                    |
| `bootstrap_postfix__mailname_file`             | Path to the mail name file.                                                                         | `/etc/mailname`                                                             |
| `bootstrap_postfix__aliases_file`              | Path to the aliases file.                                                                           | `/etc/aliases`                                                              |
| `bootstrap_postfix__virtual_aliases_file`      | Path to the virtual aliases file.                                                                   | `/etc/postfix/virtual`                                                      |
| `bootstrap_postfix__canonical_maps_file`       | Path to the canonical maps file.                                                                    | `/etc/postfix/canonical_maps`                                               |
| `bootstrap_postfix__sasl_passwd_file`          | Path to the SASL password file.                                                                     | `/etc/postfix/sasl_passwd`                                                  |
| `bootstrap_postfix__tls_policy_file`           | Path to the TLS policy file.                                                                        | `/etc/postfix/tls_policy`                                                   |
| `bootstrap_postfix__sender_canonical_maps_file`| Path to the sender canonical maps file.                                                             | `/etc/postfix/sender_canonical_maps`                                        |
| `bootstrap_postfix__recipient_canonical_maps_file` | Path to the recipient canonical maps file.                                                       | `/etc/postfix/recipient_canonical_maps`                                     |
| `bootstrap_postfix__transport_maps_file`       | Path to the transport maps file.                                                                    | `/etc/postfix/transport_maps`                                               |
| `bootstrap_postfix__sender_dependent_relayhost_maps_file` | Path to the sender-dependent relay host maps file.                                          | `/etc/postfix/sender_dependent_relayhost_maps`                              |
| `bootstrap_postfix__smtp_generic_maps_file`    | Path to the SMTP generic maps file.                                                                 | `/etc/postfix/generic`                                                      |
| `bootstrap_postfix__smtp_header_checks_file`   | Path to the SMTP header checks file.                                                                | `/etc/postfix/smtp_header_checks`                                           |
| `bootstrap_postfix__sender_canonical_classes`  | Classes of addresses that should be canonicalized by sender canonical maps.                         | `[]`                                                                        |
| `bootstrap_postfix__masquerade_domains`        | Domains to masquerade as.                                                                           | `[]`                                                                        |
| `bootstrap_postfix__masquerade_recipient_addresses` | Whether to masquerade recipient addresses.                                                      | `true`                                                                      |
| `bootstrap_postfix__debug_host_list`           | List of hosts for debugging purposes.                                                               | `[]`                                                                        |

### Internal Variables

Variables prefixed with double underscores (`__`) are internal and should not be modified directly by users of the role.

- `__postfix_installed_version_info`: Stores the output from the `postconf -d mail_version` command.
- `__postfix_installed_version`: Extracted version number from `__postfix_installed_version_info`.

## Tasks

The tasks in this role are designed to perform the following actions:

1. **Set OS-specific variables**: Include OS-specific variable files if available, otherwise use default values.
2. **Display debug information**: Output key variables for debugging purposes.
3. **Ensure Postfix is installed**: Install the necessary packages for Postfix.
4. **Retrieve and display Postfix version**: Get the installed version of Postfix.
5. **Create necessary directories and files**: Ensure that `/etc/postfix` directory exists and create a placeholder file.
6. **Find existing hash DB files**: Locate any existing hash database files in `/etc/postfix`.
7. **Configure main.cf**: Generate the `main.cf` configuration file based on provided variables.
8. **Configure master.cf**: Generate the `master.cf` configuration file if necessary.
9. **Manage aliases and virtual aliases**: Update alias files and regenerate maps as needed.
10. **Configure SASL authentication**: Set up SASL authentication for Postfix.
11. **Configure TLS settings**: Apply TLS configurations based on provided variables.

## Handlers

Handlers in this role are triggered by specific tasks to perform actions like restarting the Postfix service or regenerating map files.

- `restart_postfix`: Restart the Postfix service if changes require it.
- `new_aliases`: Regenerate aliases using `newaliases` command.
- `new_virtual_aliases`: Regenerate virtual aliases using `postmap`.
- `postmap_sasl_passwd`: Regenerate SASL password maps.
- `postmap_generic`: Regenerate SMTP generic maps.
- `postmap_sender_canonical_maps`: Regenerate sender canonical maps.
- `postmap_sender_dependent_relayhost_maps`: Regenerate sender-dependent relay host maps.
- `postmap_recipient_canonical_maps`: Regenerate recipient canonical maps.
- `postmap_transport_maps`: Regenerate transport maps.

## Usage

To use this role, include it in your playbook and provide any necessary variable overrides. Here is an example playbook:

```yaml
---
- name: Configure Postfix on target hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_postfix
      vars:
        bootstrap_postfix__relayhost: smtp.example.com
        bootstrap_postfix__sasl_user: user@example.com
        bootstrap_postfix__sasl_password: securepassword
```

## Notes

- **Double-underscore variables**: These are internal and should not be modified directly.
- **No related roles**: This role does not depend on any other roles. It is self-contained for configuring Postfix.

This documentation provides a comprehensive overview of the `bootstrap_postfix` Ansible role, including its purpose, variables, tasks, handlers, usage instructions, and important notes.