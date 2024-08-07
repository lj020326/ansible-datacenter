# Ansible role `bootstrap-bind`

An Ansible role for setting up BIND ISC as an **authoritative-only** or **caching-forwarding** DNS server for multiple domains on EL7 or Ubuntu Server. Specifically, the responsibilities of this role are to:

- install BIND
- set up the main configuration file
    - master server
    - slave server
- set up forward and reverse lookup zone files
- set up forwarded zone files.

This role supports multiple forward and reverse zones, including for IPv6. Although enabling recursion is supported (albeit *strongly* discouraged).

Configuring the firewall is not a concern of this role, so you should do this using another role (e.g. [bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base/)).

## Requirements

- **The package `python-ipaddr` should be installed on the management node** (since v3.7.0)

## Role Variables

Variables are not required, unless specified.

| Variable                     | Default              | Comments (type)                                                                                                              |
| :---                         | :---                 | :---                                                                                                                         |
| `bind_acls`                  | `[]`                 | A list of ACL definitions, which are dicts with fields `name` and `match_list`. See below for an example.                    |
| `bind_allow_query`           | `['localhost']`      | A list of hosts that are allowed to query this DNS server. Set to ['any'] to allow all hosts                                 |
| `bind_allow_recursion`       | `['any']`            | Similar to bind_allow_query, this option applies to recursive queries.                                                       |
| `bind_allow_transfer`        | `[]`                 | A list of IPs or ACLs allowed to do zone transfers.                                                                          |
| `bind_check_names`           | `[]`                 | Check host names for compliance with RFC 952 and RFC 1123 and take the defined action (e.g. `warn`, `ignore`, `fail`).       |
| `bind_clear_slave_zones`     | `false`              | Determines if all zone files in the slaves directory should be cleared.                                                      |
| `bind_controls`              | `[]`                 | A list of access controls for rndc utility, which are dicts with fields.  See example below for fields and usage.            |
| `bind_dnssec_enable`         | `true`               | Is DNSSEC enabled                                                                                                            |
| `bind_dnssec_validation`     | `true`               | Is DNSSEC validation enabled                                                                                                 |
| `bind_disable_ipv6`          | `false`              | Determines if IPv6 support is enabled or disabled in BIND on startup.                                                        |
| `bind_enable_rndc_controls`  | `false`              | Determines if /etc/rndc.conf is created and /etc/rndc.key removed if it exists.                                              |
| `bind_enable_selinux`        | `false`              | Determines if selinux is enabled or disabled.                                                                                |
| `bind_enable_views`          | `false`              | Determines if views are enabled or disabled. When enabled, all zones must be assigned to a view.                             |
| `bind_extra_include_files`   | `[]`                 |                                                                                                                              |
| `bind_forward_only`          | `false`              | If `true`, BIND is set up as a caching name server                                                                           |
| `bind_forwarded_zone_domains`| n/a                  | A list of domains to configure as forward zones, with a separate dict for each domain, with relevant details                 |
| `- name`                     | `example.com`        | The domain name                                                                                                              |
| `- view`                     | -                    | The view this zone will exist in. View must be defined in `bind_views`. Same zone can be in multiple views. Examples below.  |
| `- forwarders`               | `[]`                 | A list of name servers to forward DNS requests for the zone to.                                                              |
| `- forward_only`             | `false`              | If `true`, BIND does not perform a recursive query if the forwarded query fails.                                             |
| `bind_forwarders`            | `[]`                 | A list of name servers to forward DNS requests to.                                                                           |
| `bind_listen_ipv4`           | `['127.0.0.1']`      | A list of the IPv4 address of the network interface(s) to listen on. Set to ['any'] to listen on all interfaces.             |
| `bind_listen_ipv6`           | `['::1']`            | A list of the IPv6 address of the network interface(s) to listen on                                                          |
| `bind_log`                   | `data/named.run`     | Path to the log file                                                                                                         |
| `bind_other_logs`            | -                    | A list of logging channels to configure, with a separate dict for each domain, with relevant details                         |
| `bind_controllers`               | `[]`                 | A list of master servers for zone transfers or slaves servers to be notified with `also-notify`. See example below.          |
| `bind_query_log`             | -                    | When defined (e.g. `data/query.log`), this will turn on the query log                                                        |
| `bind_recursion`             | `false`              | Determines whether requests for which the DNS server is not authoritative should be forwarded†.                              |
| `bind_rrset_order`           | `random`             | Defines order for DNS round robin (either `random` or `cyclic`)                                                              |
| `bind_servers`               | `[]`                 | BIND clause that defines behavior when interacting with defined remote servers.                                              |
| ` - ipaddr`                  | -                    | IP address of remote server.                                                                                                 |
| ` - key`                     | -                    | Name of TSIG key to send to remote server. TSIG key defined with bind_tsig_keys.                                             |
| ` - edns`                    | `true`               | Enable/disable support for EDNS (RFC 2671) with remote server.                                                               | 
| ` - bogus`                   | `false`              | Ignore requests from remote server.                                                                                          |
| `bind_statements`            | `[]`                 | Additional BIND statements to customize configuration. Leave off ";" at the end.                                             |
| ` - queries`                 | `[]`                 | A list of addtional statememnts controlling queries. (e.g., "filter-aaaa-on-v4 yes")                                         |
| ` - transfers`               | `[]`                 | A list of addtional statememnts controlling transfers. (e.g., "transfer-format many-answers")                                |
| ` - operations`              | `[]`                 | A list of addtional statememnts controlling operations. (e.g., "masterfile-format text")                                     | 
| ` - security`                | `[]`                 | A list of addtional statememnts controlling security. (e.g., "dnssec-lookaside auto")                                        |
| ` - statistics`              | `[]`                 | A list of addtional statememnts controlling statistics. (e.g., "zone-statistics yes")                                        |
| `bind_statistics_channels`   | `false`              | if `true`, BIND is configured with a statistics_channels clause (currently only supports a single inet)                      |
| `bind_tsig_keys`             | `[]`                 | A list of Transaction Signature (TSIG) keys, which are dicts with fields `name`, `algorithm`, & `secret`. See example below. |
| `bind_views`                 | n/a                  | A list of views to configure, with a seperate dict for each view, with relevant details.                                     |
| ` - allow_query`             | `[]`                 | A list of IPs or ACLs allowed to query the zones in the view.                                                                |
| ` - allow_transfer`          | `[]`                 | A list of IPs or ACLs allowed to do zone transfers from the zones in the view.                                               |
| ` - allow_notify`            | `[]`                 | A list of IPs or ACLs allowed to send NOTIFY messages to zones in the view.                                                  |
| ` - also_notify`             | `[]`                 | A list of IPs or controllers/slaves defined in `bind_controllers` that will receive NOTIFY messages from zones in the view.          |
| ` - include_files`           | `[]`                 | A list of files that will be included in the named.conf configuration for a specific view.                                   |
| ` - match_clients`           | `[]`                 | A list of IPs or ACLs of client source IP addresses that can send messages to the view.                                      |
| ` - match_destination`       | `[]`                 | A list of IPs or ACLs of server destination IP addresses that can receive messages for the view.                             |
| ` - match_recursive_only`    | -                    | Determines if only recursive queries can access view.                                                                        |
| ` - notify`                  | -                    | Determines notify behavior when a zone is changed.  Valid choices are `yes`, `no`, or `explicit`.                            |
| ` - name`                    | `default`            | The view name.                                                                                                               |
| ` - tsig_keys`               | `[]`                 | A list of Transaction Signature keys used exclusively by the view.  Can not match global keys defined by `bind_tsig_keys`.   |
| ` - recursion`               | -                    | Determines if recursion is enabled for the view.                                                                             |
| `bind_zone_dir`              | -                    | When defined, sets a custom absolute path to the server directory (for zone files, etc.) instead of the default.             |
| `bind_zone_domains`          | n/a                  | A list of domains to configure, with a separate dict for each domain, with relevant details                                  |
| `- allow_update`             | `['none']`           | A list of hosts that are allowed to dynamically update this DNS zone.                                                        |
| `- also_notify`              | -                    | A list of servers that will receive a notification when the master zone file is reloaded.                                    |
| `- delegate`                 | `[]`                 | Zone delegation. See below this table for examples.                                                                          |
| `- hostmaster_email`         | `hostmaster`         | The e-mail address of the system administrator for the zone                                                                  |
| `- hosts`                    | `[]`                 | Host definitions. See below this table for examples.                                                                         |
| `- ipv6_networks`            | `[]`                 | A list of the IPv6 networks that are part of the domain, in CIDR notation (e.g. 2001:db8::/48)                               |
| `- mail_servers`             | `[]`                 | A list of dicts (with fields `name` and `preference`) specifying the mail servers for this domain.                           |
| ` - controllers`                 | `[]`                 | A list of controllers to use for zone transfers. Must be defined in `bind_controllers`. Overrides `bind_zone_primary_server_ip`       |
| `- name_servers`             | `[ansible_hostname]` | A list of the DNS servers for this domain.                                                                                   |
| `- name`                     | `example.com`        | The domain name                                                                                                              |
| `- networks`                 | `['10.0.2']`         | A list of the networks that are part of the domain                                                                           |
| `- other_name_servers`       | `[]`                 | A list of the DNS servers outside of this domain.                                                                            |
| `- services`                 | `[]`                 | A list of services to be advertised by SRV records                                                                           |
| `- text`                     | `[]`                 | A list of dicts with fields `name` and `text`, specifying TXT records. `text` can be a list or string.                       |
| `- naptr`                    | `[]`                 | A list of dicts with fields `name`, `order`, `pref`, `flags`, `service`, `regex` and `replacement` specifying NAPTR records. |
| `- view`                     | -                    | The view this zone will exist in. View must be defined in `bind_views`. Same zone can be in multiple views. Examples below.  |
| `bind_zone_file_mode`        | 0640                 | The file permissions for the main config file (named.conf)                                                                   |
| `bind_zone_primary_server_ip` | -                    | **(Required)** The IP address of the master DNS server.                                                                      |
| `bind_zone_minimum_ttl`      | `1D`                 | Minimum TTL field in the SOA record.                                                                                         |
| `bind_zone_time_to_expire`   | `1W`                 | Time to expire field in the SOA record.                                                                                      |
| `bind_zone_time_to_refresh`  | `1D`                 | Time to refresh field in the SOA record.                                                                                     |
| `bind_zone_time_to_retry`    | `1H`                 | Time to retry field in the SOA record.                                                                                       |
| `bind_zone_ttl`              | `1W`                 | Time to Live field in the SOA record.                                                                                        |

† Best practice for an authoritative name server is to leave recursion turned off. However, [for some cases](http://www.zytrax.com/books/dns/ch7/queries.html#allow-query-cache) it may be necessary to have recursion turned on.

### Minimal variables for a working zone

Even though only variable `bind_zone_primary_server_ip` is required for the role to run without errors, this is not sufficient to get a working zone. In order to set up an authoritative name server that is available to clients, you should also at least define the following variables:

| Variable                     | Master | Slave |
| :---                         | :---:  | :---: |
| `bind_zone_domains`          | V      | V     |
| `  - name`                   | V      | V     |
| `  - networks`               | V      | --    |
| `  - name_servers`           | V      | --    |
| `  - hosts`                  | V      | --    |
| `bind_listen_ipv4`           | V      | V     |
| `bind_allow_query`           | V      | V     |

### Domain definitions

```Yaml
bind_zone_domains:
  - name: mydomain.com
    hosts:
      - name: pub01
        ip: 192.0.2.1
        ipv6: 2001:db8::1
        aliases:
          - ns
      - name: '@'
        ip:
          - 192.0.2.2
          - 192.0.2.3
        sshfp:
          - "3 1 1262006f9a45bb36b1aa14f45f354b694b77d7c3"
          - "3 2 e5921564252fe10d2dbafeb243733ed8b1d165b8fa6d5a0e29198e5793f0623b"
        ipv6:
          - 2001:db8::2
          - 2001:db8::3
        aliases:
          - www
      - name: priv01
        ip: 10.0.0.1
      - name: mydomain.net.
        aliases:
          - name: sub01
            type: DNAME
    networks:
      - '192.0.2'
      - '10'
      - '172.16'
    delegate:
      - zone: foo
        dns: 192.0.2.1
    services:
      - name: _ldap._tcp
        weight: 100
        port: 88
        target: dc001
    naptr:
      - name: "sip"
        order: 100
        pref: 10
        flags: "S"
        service: "SIP+D2T"
        regex: "!^.*$!sip:customer-service@example.com!"
        replacement: "_sip._tcp.example.com."
```

### Minimal slave configuration

```Yaml
    bind_listen_ipv4: ['any']
    bind_allow_query: ['any']
    bind_zone_primary_server_ip: 192.168.111.222
    bind_zone_domains:
      - name: example.com
```

### Hosts

Host names that this DNS server should resolve can be specified in `hosts` as a list of dicts with fields `name`, `ip`,  `aliases` and `sshfp`. Aliases can be CNAME (default) or DNAME records.

To allow to surf to http://example.com/, set the host name of your web server to `'@'` (must be quoted!). In BIND syntax, `@` indicates the domain name itself.

If you want to specify multiple IP addresses for a host, add entries to `bind_zone_hosts` with the same name (e.g. `priv01` in the code snippet). This results in multiple A/AAAA records for that host and allows [DNS round robin](http://www.zytrax.com/books/dns/ch9/rr.html), a simple load balancing technique. The order in which the IP addresses are returned can be configured with role variable `bind_rrset_order`.

### Networks

As you can see, not all hosts are in the same network. This is perfectly acceptable, and supported by this role. All networks should be specified in `networks` (part of bind_zone_domains.name dict), though, or the host will not get a PTR record for reverse lookup:

Remark that only the network part should be specified here! When specifying a class B IP address (e.g. "172.16") in a variable file, it must be quoted. Otherwise, the Yaml parser will interpret it as a float.

Based on the idea and examples detailed at <https://linuxmonk.ch/wordpress/index.php/2016/managing-dns-zones-with-ansible/> for the gdnsd package, the zonefiles are fully idempotent, and thus only get updated if "real" content changes.

### Zone delgation

To delegate a zone to a DNS, it is enough to create a `NS` record (under delegate) which is the equivalent of:

```
foo IN NS 192.0.2.1
```

### Service records

Service (SRV) records can be added with the services. This should be a list of dicts with mandatory fields `name` (service name), `target` (host providing the service), `port` (TCP/UDP port of the service) and optional fields `priority` (default = 0) and `weight` (default = 0).

### ACLs

ACLs can be defined like this:

```Yaml
bind_acls:
  - name: acl1
    match_list:
      - 192.0.2.0/24
      - 10.0.0.0/8
```

The names of the ACLs will be added to the `allow-transfer` clause in global options if bind_views is not defined.

ACLs can also be paired with TSIG keys as a way to control access to views:

```Yaml
bind_acls:
  - name: external_key
    match_list:
      - "!key internal.example.com"
      - "key external.example.com"
  - name: internal_key
    match_list:
      - "!key external.example.com"
      - "key internal.example.com"
```

### Transaction Signature (TSIG) keys

```Yaml
bind_tsig_keys:
  - name: rndc-key
    algorithm: hmac-md5
    secret: "+CsdasdfEsdfasdfsQRZ3Q=="
  - name: external.example.com 
    algorithm: hmac-md5
    secret: "+Cdjlkef9ZTSeixERZ433r=="
  - name: internal.example.com 
    algorithm: hmac-md5
    secret: "+qwfasdf9ZTSeixwawwERW=="
```

The key secret is a security credential and should be protected as a variable encrypted with ansible-vault.

```Yaml
bind_tsig_keys:
  - name: rndc-key
    algorithm: hmac-md5
    secret: "{{ vault_rndc_key_secret }}"
```

`bind_tsig_keys` defines global TSIG keys only. TSIG keys used by views must be defined within `bind_views`.

TSIG keys are used to secure queries, DDNS updates, and zone transfers between BIND servers.  See [Securing zone transfers with TSIG](http://ddiguru.com/blog/45-dns/42-securing-zone-transfers-with-tsig) for more information.

[NIST recommends using HMAC-SHA256 instead of HMAC-MD5 for the TSIG algorithm](https://csrc.nist.gov/publications/detail/sp/800-81/2/final).

### Server list

```Yaml
bind_servers:
  - name: 192.168.8.64
    key: external.example.com 
  - name: 192.168.28.63
    key: internal.example.com
    edns: false
  - name: 172.16.1.6
    key: badserver.example.com
    bogus: true
```

The `server` statement defines characteristics to be associated with a remote name server. To send TSIG keys to remote BIND servers, define the key to be used for each remote BIND server in bind_servers.  Only one key is supported per server.  hmac-md5 TSIG keys are not supported by Microsoft Active Directory DNS servers.

`edns` enable|disable Extension mechanisms for DNS (EDNS) [RFC 6891](https://tools.ietf.org/html/rfc6891).
`bogus` is used to prevent queries being sent to remote servers with bad data.


### Controllers list

A controllers list can be used in two different ways.  First, it can be used with the masters statement in a slave zone to define a list of master servers and the TSIG keys needed to transfer a zone file. Second, it can be used with the also-notify statement to define a list of slave servers with the TSIG keys needed to notify after an update.  Controllers lists are defined like this:

```Yaml
bind_controllers:
  - name: EXTERNAL_CONTROLLERS
    master_list:
      - address: 200.100.230.160
        tsig_key: external.example.com

  - name: INTERNAL_CONTROLLERS
    master_list:
      - address: 192.168.8230.160

  - name: AKAMAI_ZTAS
    master_list:
      - address: 23.73.133.141
        tsig_key: external.example.com
      - address: 23.73.133.237
        tsig_key: external.example.com
      - address: 23.73.134.141
        tsig_key: external.example.com
      - address: 23.73.134.237
        tsig_key: external.example.com
```

In the example above, the first two controllers lists ensure the slave servers will get zone transfers from along with a TSIG key, if needed.  The third master is a list of slaves for a cloud DNS service that will be notified after an update.

### View definitions

```Yaml
bind_views:
  - name: EXTERNAL
    allow_query:
      - external_key
    allow_transfer:
      - external_key
    allow_notify:
      - external_key
    also_notify:
      - AKAMAI_ZTAS
    match_clients:
      - external_key
    match_destinations:
      - any
    match_recursive_only: false
    notify: explicit
    tsig_keys:
      - name: external.example.com
        algorithm: HMAC-SHA256
        secret: "{{ vault_external_secret }}"
    recursion: false

  - name: INTERNAL
    allow_query:
      - "!key external.example.com"
      - "key internal.example.com"
      - 192.168.20.20
      - 127.0.0.1
    allow_transfer:
      - "!key external.example.com"
      - "key internal.example.com"
    allow_notify:
      - "!key external.example.com"
      - "key internal.example.com"
    also_notify:
      - 192.168.12.12 
    match_clients:
      - "!key external.example.com"
      - "key internal.example.com"
      - 192.168.20.20
      - 127.0.0.1
    match_destinations:
      - any
    match_recursive_only: false
    notify: explicit
    include_files:
      - /etc/named.extra.zones
    tsig_keys:
      - name: internal.example.com
        algorithm: HMAC-SHA256
        secret: "{{ vault_internal_secret }}"
    recursion: false
```

Above are two common views, internal and external.  The external view controls access with TSIG keys defined previously as ACLs.  It also notifies the Akamai cloud DNS servers by its controllers name after any zone changes.  The internal view controls access using TSIG keys and IP addresses and sends notifies by IP.  Each view has its own TSIG key.  [NIST recommends using HMAC-SHA256 as the TSIG algorithm](https://csrc.nist.gov/publications/detail/sp/800-81/2/final)

For more information on configuring views, read: [Understanding views in BIND 9, by example](https://kb.isc.org/docs/aa-00851) 

For more information on configuring DNS securely, read NIST Special Publication 800-81-2: [Secure Domain Name System (DNS) Deployment Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-81-2.pdf) 

### Minimal variables for a working zone with views

Even though only variable `bind_zone_primary_server_ip` is required for the role to run without errors, this is not sufficient to get a working zone. In order to set up an authoritative name server that is available to clients, you should also at least define the following variables:

| Variable                     | Master | Slave |
| :---                         | :---:  | :---: |
| `bind_zone_domains`          | V      | V     |
| `  - name`                   | V      | V     |
| `  - view`                   | V      | V     |
| `  - networks`               | V      | --    |
| `  - name_servers`           | V      | --    |
| `  - hosts`                  | V      | --    |
| `bind_listen_ipv4`           | V      | V     |
| `bind_allow_query`           | V      | V     |

### Domain definitions for master with view and controllers list defined.

```Yaml
bind_zone_domains:
  - name: example.com
    view: EXTERNAL
    controllers: EXTERNAL_MASTER
    hosts:
      - name: pub01
        ip: 192.0.2.1
        ipv6: 2001:db8::1
        aliases:
          - ns
      - name: '@'
        ip:
          - 192.0.2.2
          - 192.0.2.3
        ipv6:
          - 2001:db8::2
          - 2001:db8::3
        aliases:
          - www
      - name: priv01
        ip: 10.0.0.1
    networks:
      - '192.0.2'
      - '10'
      - '172.16'
    delegate:
      - zone: foo
        dns: 192.0.2.1
    services:
      - name: _ldap._tcp
        weight: 100
        port: 88
        target: dc001
```

This domain is configured for the EXTERNAL view.  It will use the controllers configuration named EXTERNAL_CONTROLLERS instead of the bind_zone_primary_server_ip value.

### Domain definition for slave with view and controllers defined. 

```Yaml
bind_zone_domains: [
  { name: example.com, view: EXTERNAL, controllers: EXTERNAL_CONTROLLERS },
  { name: test.com, view: EXTERNAL, controllers: EXTERNAL_CONTROLLERS },
  { name: example.com, view: INTERNAL },
  { name: test.com, view: INTERNAL }
]
```

### Scaling slave zones

If you have very large numbers of forward and reverse slave zones in multiple views, you can easily manage them as multiple dicts stored in separate YAML files:

group_vars/all/external_forward_zones.yaml:

```Yaml
---
external_forward_zones: [
  { name: example.com, view: External, controllers: EXTERNAL_CONTROLLERS },
  { name: example.net, view: External, controllers: EXTERNAL_CONTROLLERS },
  { name: example.org, view: External, controllers: EXTERNAL_CONTROLLERS }
]
```

group_vars/all/external_reverse_zones.yaml:

```Yaml
---
external_reverse_zones: [
  { name: 16.24.85.in-addr.arpa, view: External, controllers: EXTERNAL_CONTROLLERS },
  { name: 17.24.85.in-addr.arpa, view: External, controllers: EXTERNAL_CONTROLLERS },
  { name: 18.24.85.in-addr.arpa, view: External, controllers: EXTERNAL_CONTROLLERS }
]
```

group_vars/all/internal_forward_zones.yaml:

```Yaml
---
internal_forward_zones: [
  { name: internal.com, view: Internal, controllers: INTERNAL_CONTROLLERS },
  { name: internal.net, view: Internal, controllers: INTERNAL_CONTROLLERS },
  { name: intenral.org, view: Internal, controllers: INTERNAL_CONTROLLERS }
]
```

group_vars/all/internal_reverse_zones.yaml:

```Yaml
---
internal_reverse_zones: [
  { name: 8.24.10.in-addr.arpa, view: Internal, controllers: INTERNAL_CONTROLLERS },
  { name: 9.24.10.in-addr.arpa, view: Internal, controllers: INTERNAL_CONTROLLERS },
  { name: 10.24.10.in-addr.arpa, view: Internal, controllers: INTERNAL_CONTROLLERS }
]
```

You can then merge one or more dicts into bind_zone_domains in your playbook:

```Yaml
---
- hosts: my_slave_zones
  become: yes
  roles:
    - bootstrap_bind

  pre_tasks:
  - name: Merge zones dicts
    ansible.builtin.set_fact:
      bind_zone_domains: "{{ external_forward_zones }} + {{ external_reverse_zones }} +
                          {{ internal_forward_zones }} + {{ internal_reverse_zones }}"

```

## Forward zones

You can include forward zones in your configuration by using bind_forwarded_zone_domains.

```Yaml
bind_forwarded_zone_domains: [
  { name: example.com, view: EXTERNAL, forwarders: [ 100.100.1.1, 100.100.2.1 ], forward_only: true },
  { name: test.com, view: EXTERNAL, forwarders: [ 100.100.1.1, 100.100.2.1 ], forward_only: true },
  { name: example.com, view: INTERNAL, forwarders: [ 192.168.1.1, 192.168.2.1 ], forward_only: false },
  { name: test.com, view: INTERNAL, forwarders: [ 10.168.1.1, 10.168.2.1 ] }
]
```

## Dependencies

No dependencies. If you want to configure the firewall, do this through another role (e.g. [bertvv.rh-base](https://galaxy.ansible.com/bertvv/rh-base)).

## Example Playbook

See the test playbook [test.yml](https://github.com/bertvv/ansible-role-bind/blob/docker-tests/test.yml) for an elaborate example that showcases most features.

## Testing

There are two test environments for this role, one based on Vagrant, the other on Docker. The latter powers the Travis-CI tests. The tests are kept in a separate (orphan) branch so as not to clutter the actual code of the role. [git-worktree(1)](https://git-scm.com/docs/git-worktree) is used to include the test code into the working directory. Remark that this requires at least Git v2.5.0.

### Running Docker tests

1. Fetch the test branch: `git fetch origin docker-tests`
2. Create a Git worktree for the test code: `git worktree add docker-tests docker-tests`. This will create a directory `docker-tests/`

The script `docker-tests.sh` will create a Docker container, and apply this role from a playbook `test.yml`. The Docker images are configured for testing Ansible roles and are published at <https://hub.docker.com/r/bertvv/ansible-testing/>. There are images available for several distributions and versions. The distribution and version should be specified outside the script using environment variables:

```
DISTRIBUTION=centos VERSION=7 ./docker-tests/docker-tests.sh
```

The specific combinations of distributions and versions that are supported by this role are specified in `.travis.yml`.

The first time the test script is run, a container will be created that is assigned the IP address 172.17.0.2. This will be the master DNS-server. The server is still running after the script finishes and can be queried from the command line, e.g.:

```
$ dig @172.17.0.2 www.acme-inc.com +short
srv001.acme-inc.com.
172.17.1.1
```

If you run the script again, a new container is launched with IP address 172.17.0.3 that will be set up as a slave DNS-server. After a few seconds, it will have received updates from the master server and can be queried as well.

```
$ dig @172.17.0.3 www.acme-inc.com +short
srv001.acme-inc.com.
172.17.1.1
```

The script `docker-tests/functional-tests.sh` will run a [BATS](https://github.com/sstephenson/bats) test suite, `dns.bats` that performs a number of different queries. Specify the server IP address as the environment variable `${SUT_IP}` (short for System Under Test).

```
$ SUT_IP=172.17.0.2 ./docker-tests/functional-tests.sh
### Using BATS executable at: /usr/local/bin/bats
### Running test /home/bert/CfgMgmt/roles/bind/tests/dns.bats
 ✓ Forward lookups public servers
 ✓ Reverse lookups
 ✓ Alias lookups public servers
 ✓ IPv6 forward lookups
 ✓ NS record lookup
 ✓ Mail server lookup
 ✓ Service record lookup
 ✓ TXT record lookup

8 tests, 0 failures
$ SUT_IP=172.17.0.3 ./docker-tests/functional-tests.sh
[...]
```

### Running Vagrant tests

1. Fetch the tests branch: `git fetch origin vagrant-tests`
2. Create a Git worktree for the test code: `git worktree add vagrant-tests vagrant-tests`. This will create a directory `vagrant-tests/`.
3. `cd vagrant-tests/`
4. `vagrant up` will then create two VMs and apply a test playbook (`test.yml`).

The command `vagrant up` results in a setup with *two* DNS servers, a master and a slave, set up according to playbook `test.yml`.

| **Hostname**     | **ip**        |
| :---             | :---          |
| `testbindmaster` | 192.168.56.53 |
| `testbindslave`  | 192.168.56.54 |

IP addresses are in the subnet of the default VirtualBox Host Only network interface (192.168.56.0/24). You should be able to query the servers from your host system. For example, to verify if the slave is updated correctly, you can do the following:

```ShellSession
$ dig @192.168.56.54 ns1.example.com +short
testbindmaster.example.com.
192.168.56.53
$ dig @192.168.56.54 example.com www.example.com +short
web.example.com.
192.168.56.20
192.168.56.21
$ dig @192.168.56.54 MX example.com +short
10 mail.example.com.

```

An automated acceptance test written in [BATS](https://github.com/sstephenson/bats.git) is provided that checks most settings specified in `vagrant-tests/test.yml`. You can run it by executing the shell script `vagrant-tests/runtests.sh`. The script can be run on either your host system (assuming you have a Bash shell), or one of the VMs. The script will download BATS if needed and run the test script `vagrant-tests/dns.bats` on both the master and the slave DNS server.

```ShellSession
$ cd vagrant-tests
$ vagrant up
[...]
$ ./runtests.sh
Testing 192.168.56.53
✓ The `dig` command should be installed
✓ It should return the NS record(s)
✓ It should be able to resolve host names
✓ It should be able to resolve IPv6 addresses
✓ It should be able to do reverse lookups
✓ It should be able to resolve aliases
✓ It should return the MX record(s)

6 tests, 0 failures
Testing 192.168.56.54
✓ The `dig` command should be installed
✓ It should return the NS record(s)
✓ It should be able to resolve host names
✓ It should be able to resolve IPv6 addresses
✓ It should be able to do reverse lookups
✓ It should be able to resolve aliases
✓ It should return the MX record(s)

6 tests, 0 failures
```

Running from the VM:

```ShellSession
$ vagrant ssh testbindmaster
Last login: Sun Jun 14 18:52:35 2015 from 10.0.2.2
Welcome to your Packer-built virtual machine.
[vagrant@testbindmaster ~]$ /vagrant/runtests.sh
Testing 192.168.56.53
 ✓ The `dig` command should be installed
[...]
```

## References

* https://github.com/WRJFontenot/ansible-role-bind-pro
