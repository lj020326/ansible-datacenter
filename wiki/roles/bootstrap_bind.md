---
title: "Bootstrap Bind Role"
role: roles/bootstrap_bind
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_bind]
---

# Ansible Role - bootstrap_bind

This Ansible role sets up ISC BIND on RHEL/CentOS 6/7, Ubuntu 16.04/18.04 LTS (Xenial/Bionic), or Arch Linux as an authoritative DNS server for one or more domains (master and/or slave).

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bind_enable_views` | `false` | Enable BIND views. |
| `bind_enable_selinux` | `false` | Enable SELinux for BIND. |
| `bind_enable_rndc_controls` | `false` | Enable rndc controls for BIND. |
| `bind_disable_ipv6` | `false` | Disable IPv6 for BIND. |
| `bind_clear_slave_zones` | `false` | Clear existing slave zones. |
| `bind_backup_conf` | `true` | Backup BIND configuration. |
| `bind_tsig_keys` | `[]` | TSIG keys for BIND. |
| `bind_statements` | `[]` | Additional BIND statements. |
| `bind_servers` | `[]` | List of BIND servers. |
| `bind_controllers` | `[]` | List of BIND controllers. |
| `bind_log` | `data/named.run` | Log file for BIND. |
| `bind_zone_domains` | `[{"name": "example.com", "view": "default", "hostmaster_email": "hostmaster", "networks": ["{{ gateway_ipv4_subnet_1_2 }}.2"]}]` | List of zone domains. |
| `bind_zone_primary_server_ip` | `192.168.111.222` | Primary server IP for BIND zones. |
| `bind_acls` | `[]` | Access control lists for BIND. |
| `bind_listen_ipv4` | `[127.0.0.1]` | IPv4 addresses to listen on. |
| `bind_listen_ipv6` | `[::1]` | IPv6 addresses to listen on. |
| `bind_allow_query` | `[localhost]` | Hosts allowed to query BIND. |
| `bind_recursion` | `false` | Enable recursion. |
| `bind_allow_recursion` | `[any]` | Hosts allowed to use recursion. |
| `bind_forward_only` | `false` | Enable forward-only mode. |
| `bind_forwarders` | `[]` | List of forwarders. |
| `bind_rrset_order` | `random` | RRset order. |
| `bind_statistics_channels` | `false` | Enable statistics channels. |
| `bind_statistics_port` | `8053` | Port for statistics. |
| `bind_statistics_host` | `127.0.0.1` | Host for statistics. |
| `bind_statistics_allow` | `[127.0.0.1]` | Hosts allowed to access statistics. |
| `bind_dnssec_enable` | `false` | Enable DNSSEC. |
| `bind_dnssec_validation` | `true` | Validate DNSSEC. |
| `bind_extra_include_files` | `[]` | Additional include files for BIND. |
| `bind_zone_ttl` | `1W` | Time-to-live for zones. |
| `bind_zone_time_to_refresh` | `1D` | Time to refresh zones. |
| `bind_zone_time_to_retry` | `1H` | Time to retry zones. |
| `bind_zone_time_to_expire` | `1W` | Time to expire zones. |
| `bind_zone_minimum_ttl` | `1D` | Minimum TTL for zones. |
| `bind_zone_dir` | `{{ bind_dir }}` | Directory for zone files. |
| `bind_zone_file_mode` | `0640` | File mode for zone files. |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: dns_servers
  roles:
    - role: bootstrap_bind
      vars:
        bind_zone_domains:
          - name: example.com
            view: default
            hostmaster_email: hostmaster
            networks:
              - 192.168.1.0/24
```

## Dependencies

This role does not have any dependencies.

## Best Practices

- Ensure that the `bind_zone_primary_server_ip` is correctly set and accessible.
- Use appropriate security settings for SELinux and rndc controls.
- Regularly backup BIND configuration files.
- Monitor BIND logs for any issues or errors.
- Ensure that the BIND service is properly configured and running.
- Test the BIND configuration before deploying it to production.
- Keep the BIND software up to date with the latest security patches.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_bind/defaults/main.yml)
- [tasks/common.yml](../../roles/bootstrap_bind/tasks/common.yml)
- [tasks/main.yml](../../roles/bootstrap_bind/tasks/main.yml)
- [tasks/master.yml](../../roles/bootstrap_bind/tasks/master.yml)
- [tasks/slave.yml](../../roles/bootstrap_bind/tasks/slave.yml)
- [meta/main.yml](../../roles/bootstrap_bind/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_bind/handlers/main.yml)

## License

This role is licensed under the MIT License.

## Author

The original author of this role is [Your Name].

## Version

The current version of this role is 1.0.0.

## Contributors

The following individuals have contributed to the development of this role:

- [Contributor 1]
- [Contributor 2]