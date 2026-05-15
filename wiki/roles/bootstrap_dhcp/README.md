```markdown
---
title: Ansible Role `bootstrap_dhcp`
original_path: roles/bootstrap_dhcp/README.md
category: Ansible Roles
tags: dhcp, isc-dhcpd, ansible, configuration
---

# Ansible Role `bootstrap_dhcp`

This Ansible role is designed to set up ISC DHCPD. It handles the installation of necessary packages and manages the DHCP server configuration file (`dhcpd.conf`). Note that firewall configuration is not within the scope of this role; you can manage it in your local playbook or use another role, such as [bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base).

## Requirements

- No specific requirements.

## Role Variables

This role allows you to set global options and specify subnet declarations. For a practical example of configuring a DHCP server in a test environment using Vagrant and VirtualBox, refer to the [test playbook](./molecule/default/converge.yml). Below is a reference of all supported variables.

### Global Options

The following variables, when defined, will be included in the global section of the `dhcpd.conf` file. If no default value is specified, the corresponding setting will be omitted from the configuration.

For more information on these options, refer to the [dhcp-options(5)](http://linux.die.net/man/5/dhcp-options) man page.

| Variable                          | Comments                                                               |
| :---                              | :---                                                                   |
| `dhcp_global_authoritative`       | Global authoritative statement (`authoritative`, `not authoritative`)  |
| `dhcp_global_booting`             | Global booting (`allow`, `deny`, `ignore`)                             |
| `dhcp_global_bootp`               | Global bootp (`allow`, `deny`, `ignore`)                               |
| `dhcp_global_broadcast_address`   | Global broadcast address                                               |
| `dhcp_global_classes`             | Class definitions with a match statement (1)                           |
| `dhcp_global_default_lease_time`  | Default lease time in seconds                                          |
| `dhcp_global_domain_name_servers` | A list of IP addresses for DNS servers (2)                             |
| `dhcp_global_domain_name`         | Domain name for client host name resolution                            |
| `dhcp_global_domain_search`       | List of domain names for non-FQDN resolution (1)                       |
| `dhcp_global_failover`            | Failover peer settings (3)                                             |
| `dhcp_global_failover_peer`       | Name for the failover peer (e.g., `foo`)                               |
| `dhcp_global_filename`            | Filename to request for boot                                           |
| `dhcp_global_includes_missing`    | Boolean. Continue if `includes` file(s) missing from role's files/     |
| `dhcp_global_includes`            | List of config files to be included (from `dhcp_config_dir`)           |
| `dhcp_global_log_facility`        | Global log facility (e.g., `daemon`, `syslog`, `user`, ...)            |
| `dhcp_global_max_lease_time`      | Maximum lease time in seconds                                          |
| `dhcp_global_next_server`         | IP for PXEboot server                                                  |
| `dhcp_global_ntp_servers`         | List of IP addresses for NTP servers                                   |
| `dhcp_global_omapi_port`          | OMAPI port                                                             |
| `dhcp_global_omapi_secret`        | OMAPI secret                                                           |
| `dhcp_global_other_options`       | Array of arbitrary additional global options                           |
| `dhcp_global_routers`             | IP address of the router                                               |
| `dhcp_global_server_name`         | Server name sent to the client                                         |
| `dhcp_global_server_state`        | Service state (started, stopped)                                       |
| `dhcp_global_subnet_mask`         | Global subnet mask                                                     |
| `dhcp_custom_includes`            | List of Jinja config files to be included (from `dhcp_config_dir`)     |
| `dhcp_custom_includes_modes`      | List of modes for the destination custom config file                   |

**Remarks**

1. **Class Definitions**: This role supports defining classes with a match statement, e.g.,

    ```yaml
    # Class for VirtualBox VMs
    dhcp_global_classes:
      - name: vbox
        match: 'match if binary-to-ascii(16,8,":",substring(hardware, 1, 3)) = "8:0:27"'
    ```

    Class names can be used in address pool definitions.

2. **DNS Servers**: The `dhcp_global_domain_name_servers` variable can be a list or a single string:

    ```yaml
    # Single DNS server
    dhcp_global_domain_name_servers: 8.8.8.8

    # List of DNS servers
    dhcp_global_domain_name_servers:
      - 8.8.8.8
      - 8.8.4.4
    ```

3. **Failover Configuration**: This role supports defining a failover peer:

    ```yaml
    # Failover peer definition
    dhcp_global_failover_peer: failover-group
    dhcp_global_failover:
      role: primary # or secondary
      address: 192.168.222.2
      port: 647
      peer_address: 192.168.222.3
      peer_port: 647
      max_response_delay: 15
      max_unacked_updates: 10
      load_balance_max_seconds: 5
      split: 255
      mclt: 3600
    ```

    The `dhcp_global_failover_peer` variable specifies a name for the configured peer, used in pool definitions. The failover declaration options are specified with the `dhcp_global_failover` dictionary.

## Backlinks

- [Ansible Roles Documentation](../ansible_roles.md)
```

This improved version includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation and context within a documentation set.