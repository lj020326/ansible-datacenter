---
title: Bootstrap BIND Role Documentation
role: bootstrap_bind
category: DNS Configuration
type: Ansible Role
tags: bind, dns, networking, system
---

## Summary

The `bootstrap_bind` role is designed to set up ISC BIND on RHEL/CentOS 6/7, Ubuntu 16.04/18.04 LTS (Xenial/Bionic), Debian Jessie/Stretch, or Arch Linux as an authoritative DNS server for one or more domains, functioning either as a master or slave server.

## Variables

| Variable Name                      | Default Value                                  | Description                                                                 |
|------------------------------------|------------------------------------------------|-----------------------------------------------------------------------------|
| `bind_enable_views`                | `false`                                        | Enable BIND views.                                                          |
| `bind_enable_selinux`              | `false`                                        | Enable SELinux for BIND.                                                    |
| `bind_enable_rndc_controls`        | `false`                                        | Enable rndc controls for BIND management.                                   |
| `bind_disable_ipv6`                | `false`                                        | Disable IPv6 support in BIND.                                               |
| `bind_clear_slave_zones`           | `false`                                        | Clear existing slave zones on the server.                                   |
| `bind_backup_conf`                 | `true`                                         | Backup configuration files before making changes.                           |
| `bind_tsig_keys`                   | `[]`                                           | List of TSIG keys for secure DNS updates.                                     |
| `bind_statements`                  | `[]`                                           | Custom BIND statements to include in the configuration.                     |
| `bind_servers`                     | `[]`                                           | List of BIND servers.                                                       |
| `bind_controllers`                 | `[]`                                           | List of controllers for BIND management.                                    |
| `bind_log`                         | `data/named.run`                               | Log file path for BIND.                                                     |
| `bind_zone_domains`                | `- name: example.com<br>  view: default<br>  hostmaster_email: hostmaster<br>  networks:<br>    - "{{ gateway_ipv4_subnet_1_2 }}.2"` | List of domains to manage with BIND, including network details.             |
| `bind_zone_primary_server_ip`      | `192.168.111.222`                              | IP address of the primary DNS server.                                       |
| `bind_acls`                        | `[]`                                           | Access control lists for BIND.                                              |
| `bind_listen_ipv4`                 | `- 127.0.0.1`                                  | List of IPv4 addresses to listen on.                                        |
| `bind_listen_ipv6`                 | `- ::1`                                        | List of IPv6 addresses to listen on.                                        |
| `bind_allow_query`                 | `- localhost`                                  | List of IP addresses allowed to query the DNS server.                         |
| `bind_recursion`                   | `false`                                        | Enable recursion in BIND.                                                   |
| `bind_allow_recursion`             | `- any`                                        | List of IP addresses allowed to use recursion.                              |
| `bind_forward_only`                | `false`                                        | Set BIND to forward-only mode.                                              |
| `bind_forwarders`                  | `[]`                                           | List of DNS forwarders.                                                   |
| `bind_rrset_order`                 | `random`                                       | Order of resource record sets in responses.                                 |
| `bind_statistics_channels`         | `false`                                        | Enable statistics channels for BIND.                                          |
| `bind_statistics_port`             | `8053`                                         | Port for the statistics channel.                                            |
| `bind_statistics_host`             | `127.0.0.1`                                    | Host for the statistics channel.                                            |
| `bind_statistics_allow`            | `- 127.0.0.1`                                  | List of IP addresses allowed to access the statistics channel.              |
| `bind_dnssec_enable`               | `false`                                        | Enable DNSSEC in BIND.                                                      |
| `bind_dnssec_validation`           | `true`                                         | Validate DNSSEC data in BIND.                                               |
| `bind_extra_include_files`         | `[]`                                           | List of extra files to include in the BIND configuration.                   |
| `bind_zone_ttl`                    | `1W`                                           | Time-to-live for zone records.                                              |
| `bind_zone_time_to_refresh`        | `1D`                                           | Time before a slave server refreshes its zone data from the master.         |
| `bind_zone_time_to_retry`          | `1H`                                           | Time between retries if a refresh fails.                                    |
| `bind_zone_time_to_expire`         | `1W`                                           | Time after which stale data is discarded if a refresh fails.                |
| `bind_zone_minimum_ttl`            | `1D`                                           | Minimum TTL for records in the zone.                                        |
| `bind_zone_dir`                    | `"{{ bind_dir }}"`                             | Directory where zone files are stored.                                      |
| `bind_zone_file_mode`              | `"0640"`                                       | File mode for zone files.                                                   |

## Usage
To use this role, include it in your playbook and specify the necessary variables as needed. Here is an example:

```yaml
- hosts: dns_servers
  roles:
    - role: bootstrap_bind
      vars:
        bind_zone_domains:
          - name: example.com
            view: default
            hostmaster_email: hostmaster@example.com
            networks:
              - "192.168.1.0/24"
        bind_zone_primary_server_ip: 192.168.1.1
```

## Dependencies
This role has no external dependencies.

## Tags
- `bind`: General tag for all BIND-related tasks.
- `pretask`: Tag for pre-task configurations.

## Best Practices
- Always ensure that the `bind_zone_primary_server_ip` is correctly set to avoid configuration issues.
- Use TSIG keys (`bind_tsig_keys`) for secure DNS updates if required.
- Configure access control lists (`bind_acls`) and allowed query addresses (`bind_allow_query`) carefully to enhance security.

## Molecule Tests
This role does not include Molecule tests at this time. Consider adding them for automated testing in the future.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_bind/defaults/main.yml)
- [tasks/common.yml](../../roles/bootstrap_bind/tasks/common.yml)
- [tasks/main.yml](../../roles/bootstrap_bind/tasks/main.yml)
- [tasks/master.yml](../../roles/bootstrap_bind/tasks/master.yml)
- [tasks/slave.yml](../../roles/bootstrap_bind/tasks/slave.yml)
- [meta/main.yml](../../roles/bootstrap_bind/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_bind/handlers/main.yml)