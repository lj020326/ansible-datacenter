# bootstrap-linux-firewalld Ansible Role

Install and configure firewalld (<http://www.firewalld.org/>) on

* Archlinux
* Debian (Experimental)
* CentOS
* Fedora
* RHEL

See Examples how to use this role.

## Requirements

* Ansible 2.3+

## Configuration

### Global firewalld.conf

Change settings in `firewalld.conf`

```yaml
firewalld_configs: {}
```

### Easy method

This will use the ansible firewalld module (<http://docs.ansible.com/ansible/latest/firewalld_module.html>).

```yaml
firewalld:
  - immediate: true
    interface: ""
    masquerade: true
    permanent: false
    port: ""
    rich_rule: ""
    service: ""
    source: ""
    state: enabled
    zone: ""
```

### Advanced method

Define custom ipsets, services and zones in `/etc/firewalld`.

#### ipset Definitions

```yaml
firewalld_ipsets:
  - type: ""
    short: ""
    description: ""
    option:
      name: value
    entry: []
```

Use `firewall-cmd --get-ipset-types` to get a list of supported types.

Supported Options:

Name | Value
-----|------
family | "int", "inet6"
timeout | integer
hashsize | integer
maxelem: | integer

#### Service Definitions

```yaml
firewalld_services:
  - name: ""
    short: ""
    description: ""
    port: []
    protocol: []
    source_port: []
    module: []
    destination: {}
```

#### Zone Definitions

Variable | Examples
---------|---------
protocol | "tcp", "udp", "sctp", "dccp"
target   | "ACCEPT", "%%REJECT%%", "DROP"

```yaml
firewalld_zones:
  - name: ""
    short: ""
    description: ""
    target: ""
    interface:
      - name: ""
    source:
      - address: ""
      - mac: ""
      - ipset: ""
    service:
      - name: ""
    port:
      - { port: "", protocol: "" }
    protocol:
      - value:
    icmp-block:
      - name:
    icmp-block-inversion: true
    masquerade: true
    forward-port:
      - { port: "", protocol: "" }
    source-port:
      - { port: "", protocol: "" }
    rule:
      - source:
          address: ""
          mac: ""
          ipset: ""
        destination:
          ""
        service:
          name: ""
        port:
          port: ""
          protocol: ""
        protocol:
          value: ""
        icmp-block:
          name: ""
        icmp-type:
          name: ""
        masquerade: true
        forward-port:
          port: ""
          protocol: ""
          to-port: ""
          to-addr: ""
        source-port:
          port: ""
          protocol: ""
        log:
          prefix: ""
          level: ""
          limit: ""
        audit:
          limit: ""
        accept:
          limit: ""
        reject:
          rejecttype: ""
          limit: ""
        drop:
          limit: ""
        mark:
          set:
          limit: ""
```

## Examples

### Add a new service

```yaml
firewalld_services:
  - name: myservice
    short: "MYSERVICE"
    description: "My custom service"
    port:
      - port: 123
        protocol: tcp
```

### Change a common zone

Redefine public zone and allow myservice and http(s)

```yaml
firewalld_zones:
  - name: public
    short: "Public"
    description: "Public Zone"
    service:
      - name: "myservice"
      - name: http
      - name: https
```

### Add a new zone

Add a new zone "mgt" and trust some sources

```yaml
firewalld_zones:
  - name: mgt
    short: "MGT"
    description: "Trust my management hosts"
    target: "ACCEPT"
    source:
      - address: 1.2.3.4/32
      - address: 5.6.7.8/32
```

### Enable arbitrary firewalld rules

Enable a new rule 

```yaml
firewalld_rules:
  - zone: drop
    state: enabled
    permanent: yes
    icmp_block: echo-request
```

Allow a service temporary (until restart)

```yaml
firewalld_rules:
  - service: https
    state: enabled
```


### Change default zone

```yaml
firewalld_configs:
 DefaultZone: "myzone"
```

Or with more options:
```yaml
firewalld_configs: 
  DefaultZone: "{{ firewalld_default_zone }}"
  CleanupOnExit: "yes"
  Lockdown: "no"
  IPv6_rpfilter: "yes"
  IndividualCalls: "yes"
  LogDenied: "off"
  FirewallBackend: "nftables"
  FlushAllOnReload: "yes"
  RFC3964_IPv4: "yes"
  AllowZoneDrifting: "no"
```

## Idempotent role execution using Variable lookup method

This firewall role also supports [var lookup method discussed here](./../../docs/ansible-firewall/ansible-firewall-idempotent-execution.md)

If you decide to use this approach, rename the following variables the following way:

from|to
---|---
firewalld_services|firewalld_services__(role/group/purpose name)
firewalld_ports|firewalld_ports__(role/group/purpose name)
firewalld_rules|firewalld_rules__(role/group/purpose name)

Where the variable name will include the name of the respective role/group/purpose name. 
For examples, see the group_var files in this repo for the following groups/examples:

group var file|var names used
---|---
[os_linux.yml](./../../inventory/group_vars/os_linux.yml)|firewalld_services__linux
[postfix_server.yml](./../../inventory/group_vars/postfix_server.yml)|firewalld_ports__postfix
[nameserver.yml](./../../inventory/group_vars/nameserver.yml)|firewalld_ports__bind
[veeam_agent.yml](./../../inventory/group_vars/veeam_agent.yml)|firewalld_ports__veeam

## Firewall Role execution from another role

If there is the need to invoke the firewall role from another role, see the example nfs-service role invoking the firewall role below.

[roles/nfs-service/tasks/main.yml](./../../roles/nfs-service/tasks/main.yml):
```yaml
- name: Setup and run nfs
  include_role:
    name: geerlingguy.nfs
 
- name: Allow nfs traffic through the firewall
  when: firewalld_enabled | bool
  tags: [ firewall-config-nfs ]
  include_role:
    name: bootstrap-linux-firewalld
  vars:
    firewalld_action: configure
    firewalld_services: "{{ nfs_firewalld_services | d([]) }}"
    firewalld_ports: "{{ nfs_firewalld_ports | d([]) }}"
```


## TODO

* firewalld_helpers
* lockdown-whitelist.xml

## Reference

* https://github.com/ptrunk/ansible-firewalld
