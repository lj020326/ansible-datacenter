```markdown
---
title: Ansible Role for Bootstrap BIND
original_path: roles/bootstrap_bind/README.md
category: Ansible Roles
tags: [ansible, bind, dns, authoritative, caching-forwarding]
---

# Ansible Role `bootstrap-bind`

An Ansible role for setting up BIND ISC as an **authoritative-only** or **caching-forwarding** DNS server for multiple domains on EL7 or Ubuntu Server. Specifically, the responsibilities of this role are to:

- Install BIND
- Set up the main configuration file:
  - Master server
  - Slave server
- Set up forward and reverse lookup zone files
- Set up forwarded zone files

This role supports multiple forward and reverse zones, including for IPv6. Although enabling recursion is supported (albeit *strongly* discouraged).

Configuring the firewall is not a concern of this role, so you should do this using another role (e.g., [bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base/)).

## Requirements

- **The package `python-ipaddr` should be installed on the management node** (since v3.7.0)

## Role Variables

Variables are not required, unless specified.

| Variable                     | Default              | Comments (type)                                                                                                              |
| :---                         | :---                 | :---                                                                                                                         |
| `bind_acls`                  | `[]`                 | A list of ACL definitions, which are dicts with fields `name` and `match_list`. See below for an example.                    |
| `bind_allow_query`           | `['localhost']`      | A list of hosts that are allowed to query this DNS server. Set to `['any']` to allow all hosts                                 |
| `bind_allow_recursion`       | `['any']`            | Similar to `bind_allow_query`, this option applies to recursive queries.                                                       |
| `bind_allow_transfer`        | `[]`                 | A list of IPs or ACLs allowed to do zone transfers.                                                                          |
| `bind_check_names`           | `[]`                 | Check host names for compliance with RFC 952 and RFC 1123 and take the defined action (e.g., `warn`, `ignore`, `fail`).       |
| `bind_clear_slave_zones`     | `false`              | Determines if all zone files in the slaves directory should be cleared.                                                      |
| `bind_controls`              | `[]`                 | A list of access controls for rndc utility, which are dicts with fields.  See example below for fields and usage.            |
| `bind_dnssec_enable`         | `true`               | Is DNSSEC enabled                                                                                                            |
| `bind_dnssec_validation`     | `true`               | Is DNSSEC validation enabled                                                                                                 |
| `bind_disable_ipv6`          | `false`              | Determines if IPv6 support is enabled or disabled in BIND on startup.                                                        |
| `bind_enable_rndc_controls`  | `false`              | Determines if `/etc/rndc.conf` is created and `/etc/rndc.key` removed if it exists.                                              |
| `bind_enable_selinux`        | `false`              | Determines if SELinux is enabled or disabled.                                                                                |
| `bind_enable_views`          | `false`              | Determines if views are enabled or disabled. When enabled, all zones must be assigned to a view.                             |
| `bind_extra_include_files`   | `[]`                 |                                                                                                                              |
| `bind_forward_only`          | `false`              | If `true`, BIND is set up as a caching name server                                                                           |
| `bind_forwarded_zone_domains`| n/a                  | A list of domains to configure as forward zones, with a separate dict for each domain, with relevant details                 |
| `- name`                     | `example.com`        | The domain name                                                                                                              |
| `- view`                     | -                    | The view this zone will exist in. View must be defined in `bind_views`. Same zone can be in multiple views. Examples below.  |
| `- forwarders`               | `[]`                 | A list of name servers to forward DNS requests for the zone to.                                                              |
| `- forward_only`             | `false`              | If `true`, BIND does not perform a recursive query if the forwarded query fails.                                             |
| `bind_forwarders`            | `[]`                 | A list of name servers to forward DNS requests to.                                                                           |
| `bind_listen_ipv4`           | `['127.0.0.1']`      | A list of the IPv4 address of the network interface(s) to listen on. Set to `['any']` to listen on all interfaces.             |
| `bind_listen_ipv6`           | `['::1']`            | A list of the IPv6 address of the network interface(s) to listen on                                                          |
| `bind_log`                   | `data/named.run`     | Path to the log file                                                                                                         |
| `bind_other_logs`            | -                    | A list of logging channels to configure, with a separate dict for each domain, with relevant details                         |

## Backlinks

- [Ansible Roles](/ansible-roles)
```

This improved version includes a standardized YAML frontmatter, clear structure, proper headings, and a "Backlinks" section.