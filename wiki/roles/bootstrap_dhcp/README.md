---
title: Ansible Role: bootstrap_dhcp
harvested_date: '2026-08-07T18:07:09.178439+00:00'
original_path: roles/bootstrap_dhcp/README.md
source_type: legacy_markdown
category: Ansible
tags: [Ansible, DHCP, ISC DHCPD, Networking]
---

# Ansible Role: bootstrap_dhcp

Ansible role for setting up ISC DHCPD. This role is responsible for installing packages and managing the configuration ([dhcpd.conf(5)](http://linux.die.net/man/5/dhcpd.conf)). Managing the firewall configuration is NOT a concern of this role. You can handle this in your local playbook or use another role (e.g., [bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base)).

## Requirements

No specific requirements.

## Role Variables

This role is capable of setting global options and specifying subnet declarations.

See the [test playbook](./molecule/default/converge.yml) for a working example of a DHCP server in a test environment based on Vagrant and VirtualBox. This section is a reference of all supported options.

### Global Options

The following variables, when set, will be added to the global section of the DHCP configuration file. If there is no default value specified, the corresponding setting will be left out of `dhcpd.conf(5)`.

See the [dhcp-options(5)](http://linux.die.net/man/5/dhcp-options) man page for more information about these options.

| Variable                          | Comments                                                               |
| :-------------------------------- | :-------------------------------------------------------------------- |
| `dhcp_global_authoritative`       | Global authoritative statement (`authoritative`, `not authoritative`)  |
| `dhcp_global_booting`             | Global booting (`allow`, `deny`, `ignore`)                             |
| `dhcp_global_bootp`               | Global bootp (`allow`, `deny`, `ignore`)                               |
| `dhcp_global_broadcast_address`   | Global broadcast address                                               |
| `dhcp_global_classes`             | Class definitions with a match statement(1)                            |
| `dhcp_global_default_lease_time`  | Default lease time in seconds                                          |
| `dhcp_global_domain_name_servers` | A list of IP addresses of DNS servers(2)                               |
| `dhcp_global_domain_name`         | The domain name the client should use when resolving host names        |
| `dhcp_global_domain_search`       | A list of domain names to be used by the client to locate non-FQDNs(1) |
| `dhcp_global_failover`            | Failover peer settings (3)                                             |
| `dhcp_global_failover_peer`       | Name for the failover peer (e.g., `foo`)                               |
| `dhcp_global_filename`            | Filename to request for boot                                           |
| `dhcp_global_includes_missing`    | Boolean. Continue if `includes` file(s) missing from role's files/     |
| `dhcp_global_includes`            | List of config files to be included (from `dhcp_config_dir`)           |
| `dhcp_global_log_facility`        | Global log facility (e.g., `daemon`, `syslog`, `user`, ...)            |
| `dhcp_global_max_lease_time`      | Maximum lease time in seconds                                          |
| `dhcp_global_next_server`         | IP for PXEboot server                                                  |
| `dhcp_global_ntp_servers`         | List of IP addresses of NTP servers                                    |
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

1. This role supports the definition of classes with a match statement, e.g.:

    ```yaml
    # Class for VirtualBox VMs
    dhcp_global_classes:
      - name: vbox
        match: 'match if binary-to-ascii(16,8,":",substring(hardware, 1, 3)) = "8:0:27"'
    ```

    Class names can be used in the definition of address pools (see below).

2. The role variable `dhcp_global_domain_name_servers` may be written either as a list (when you have more than one item) or as a string (when you have only one). The following snippet shows an example of both:

    ```yaml
    # A single DNS server
    dhcp_global_domain_name_servers: 8.8.8.8

    # A list of DNS servers
    dhcp_global_domain_name_servers:
      - 8.8.8.8
      - 8.8.4.4
    ```

3. This role also supports the definition of a failover peer, e.g.:

    ```yaml
    # Failover peer definition
    dhcp_global_failover_peer: failover-group
    dhcp_global_failover:
      role: primary # | secondary
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

    The variable `dhcp_global_failover_peer` contains a name for the configured peer, to be used on a per pool basis. The failover declaration options are specified with the variable `dhcp_global_failover`, a dictionary that may contain the following options:

    | Option                     | Required | Comment                                                               |
    | :------------------------- | :------: | :------------------------------------------------------------------ |
    | `role`                     | Yes      | Role of the server (`primary` or `secondary`)                        |
    | `address`                  | Yes      | IP address of the local server                                       |
    | `port`                     | Yes      | Port number for the failover protocol                                |
    | `peer_address`             | Yes      | IP address of the peer server                                        |
    | `peer_port`                | Yes      | Port number for the failover protocol on the peer server             |
    | `max_response_delay`       | No       | Maximum response delay in seconds                                    |
    | `max_unacked_updates`      | No       | Maximum number of unacknowledged updates                              |
    | `load_balance_max_seconds` | No       | Maximum time in seconds for load balancing                           |
    | `split`                    | No       | Percentage of the address pool allocated to this server              |
    | `mclt`                     | No       | Maximum client lead time in seconds                                  |

## Backlinks

- [Test Playbook](./molecule/default/converge.yml) - Example of a DHCP server configuration in a test environment.