---
title: "Bootstrap Postfix Role"
role: roles/bootstrap_postfix
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_postfix]
---

# Bootstrap Postfix Role

The `bootstrap_postfix` role is designed to install, configure, and manage the Postfix mail server on a target system. It provides a flexible and comprehensive way to set up Postfix with various customization options, ensuring that the mail server is configured according to best practices and organizational requirements.

## Table of Contents
- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Platform Compatibility](#platform-compatibility)

## Variables

The following table lists the variables used by the `bootstrap_postfix` role, along with their default values and descriptions:

| Variable Name                                | Default Value                                                                 | Description                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_postfix_config_file`             | `/etc/postfix/main.cf`                                                       | Path to the Postfix main configuration file.                                |
| `bootstrap_postfix_service_name`            | `postfix`                                                                     | Name of the Postfix service.                                                |
| `bootstrap_postfix_service_state`           | `started`                                                                     | Desired state of the Postfix service (started, stopped).                     |
| `bootstrap_postfix_service_enabled`         | `true`                                                                       | Whether the Postfix service should be enabled.                               |
| `bootstrap_postfix_service_packages`        | `['postfix', 'postfix-pcre']`                                                 | List of packages to install for Postfix.                                    |
| `bootstrap_postfix_hostname`                | `{{ ansible_facts['fqdn'] }}`                                                 | Fully qualified domain name of the host.                                     |
| `bootstrap_postfix_mailname`                | `{{ ansible_facts['fqdn'] }}`                                                 | Mail name for the server.                                                    |
| `bootstrap_postfix_compatibility_level`     | `3.6`                                                                         | Compatibility level for Postfix.                                             |
| `bootstrap_postfix_map_type`                | `hash`                                                                       | Type of database for Postfix maps (hash, btree, etc.).                       |
| `bootstrap_postfix_aliases`                 | `[]`                                                                          | List of aliases for Postfix.                                                 |
| `bootstrap_postfix_virtual_aliases`         | `[]`                                                                          | List of virtual aliases for Postfix.                                         |
| `bootstrap_postfix_sender_canonical_maps`   | `[]`                                                                          | List of sender canonical maps.                                               |
| `bootstrap_postfix_sender_canonical_maps_database_type` | `{{ bootstrap_postfix_map_type }}` | Database type for sender canonical maps.                                     |
| `bootstrap_postfix_recipient_canonical_maps` | `[]`                                                                          | List of recipient canonical maps.                                            |
| `bootstrap_postfix_recipient_canonical_maps_database_type` | `{{ bootstrap_postfix_map_type }}` | Database type for recipient canonical maps.                                  |
| `bootstrap_postfix_transport_maps`          | `[]`                                                                          | List of transport maps.                                                      |
| `bootstrap_postfix_transport_maps_database_type` | `{{ bootstrap_postfix_map_type }}` | Database type for transport maps.                                            |
| `bootstrap_postfix_sender_dependent_relayhost_maps` | `[]` | List of sender-dependent relayhost maps.                                      |
| `bootstrap_postfix_smtp_header_checks`      | `[]`                                                                          | List of SMTP header checks.                                                  |
| `bootstrap_postfix_smtp_header_checks_database_type` | `{{ bootstrap_postfix_map_type }}` | Database type for SMTP header checks.                                        |
| `bootstrap_postfix_smtp_generic_maps`       | `[]`                                                                          | List of SMTP generic maps.                                                   |
| `bootstrap_postfix_smtp_generic_maps_database_type` | `{{ bootstrap_postfix_map_type }}` | Database type for SMTP generic maps.                                         |
| `bootstrap_postfix_relayhost`               | `""`                                                                          | Relayhost for outgoing mail.                                                 |
| `bootstrap_postfix_relayhost_mxlookup`      | `false`                                                                       | Whether to use MX lookup for relayhost.                                      |
| `bootstrap_postfix_relayhost_port`          | `587`                                                                         | Port for relayhost.                                                          |

[... continue with remaining variables ...]

## Usage

Provide examples of how to use the role, including minimal playbook examples and any special considerations.

## Dependencies

List any dependencies required by this role.

## Platform Compatibility

Specify the platforms that this role is compatible with.