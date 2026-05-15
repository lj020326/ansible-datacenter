```markdown
---
title: bootstrap_linux_firewalld Ansible Role Documentation
original_path: roles/bootstrap_linux_firewalld/README.md
category: Ansible Roles
tags: [firewalld, ansible, configuration]
---

# bootstrap_linux_firewalld Ansible Role

## Overview

This role installs and configures `firewalld` (<http://www.firewalld.org/>) on the following operating systems:

- Archlinux
- Debian (Experimental)
- CentOS
- Fedora
- RHEL

Refer to the [Examples](#examples) section for usage instructions.

## Requirements

- Ansible 2.3+

## Configuration

### Global `firewalld.conf`

Modify settings in `firewalld.conf` using the following variable:

```yaml
firewalld_configs: {}
```

### Easy Method

This method utilizes the Ansible `firewalld` module (<http://docs.ansible.com/ansible/latest/collections/community/general/firewalld_module.html>).

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

### Advanced Method

Define custom ipsets, services, and zones in `/etc/firewalld`.

#### IPSet Definitions

```yaml
firewalld_ipsets:
  - type: ""
    short: ""
    description: ""
    option:
      name: value
    entry: []
```

Use `firewall-cmd --get-ipset-types` to list supported types.

**Supported Options:**

| Name       | Value                  |
|------------|------------------------|
| family     | "int", "inet6"         |
| timeout    | integer                |
| hashsize   | integer                |
| maxelem    | integer                |

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

**Variables and Examples:**

| Variable              | Examples                       |
|-----------------------|--------------------------------|
| protocol              | "tcp", "udp", "sctp", "dccp"   |
| target                | "ACCEPT", "%%REJECT%%", "DROP" |

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

### Add a New Service

```yaml
firewalld_services:
  - name: myservice
    short: "MYSERVICE"
    description: "My custom service"
    port:
      - port: 123
        protocol: tcp
```

### Change a Common Zone

Redefine the public zone to allow `myservice` and HTTP(S):

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

### Add a New Zone

Add a new zone named `mgt` and trust specific sources:

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

### Enable Arbitrary Firewall Rules

Enable a new rule:

```yaml
firewalld_rules:
  - zone: drop
    state: enabled
    permanent: yes
    icmp_block: echo-request
```

Allow a service temporarily (until restart):

```yaml
firewalld_rules:
  - service: https
    state: enabled
```

### Change Default Zone

Set the default zone:

```yaml
firewalld_configs:
  DefaultZone: "myzone"
```

Or with additional options:

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

## Idempotent Role Execution Using Variable Lookup Method

This role supports the [variable lookup method discussed here](./../../docs/ansible-firewall/ansible-firewall-idempotent-execution.md).

If using this approach, rename variables as follows:

| From                         | To                                      |
|------------------------------|-----------------------------------------|
| `firewalld_services`         | `firewalld_services__(role/group/purpose name)` |
| `firewalld_ports`            | `firewalld_ports__(role/group/purpose name)`    |
| `firewalld_rules`            | `firewalld_rules__(role/group/purpose name)`    |

For example:

- **Group Var File:** [os_linux.yml](./../../inventory/group_vars/os_linux.yml)
  - **Var Names Used:** `firewalld_services__linux`
- **Group Var File:** [postfix_server.yml](./../../inventory/group_vars/postfix_server.yml)
  - **Var Names Used:** `firewalld_ports__postfix`
- **Group Var File:** [nameserver.yml](./../../inventory/group_vars/nameserver.yml)
  - **Var Names Used:** `firewalld_ports__bind`
- **Group Var File:** [veeam_agent.yml](./../../inventory/group_vars/veeam_agent.yml)
  - **Var Names Used:** `firewalld_ports__veeam`

## Firewall Role Execution from Another Role

To invoke the firewall role from another role, see the example below:

**Example: nfs-service role invoking the firewall role**

[roles/nfs-service/tasks/main.yml](./../../roles/nfs-service/tasks/main.yml):

```yaml
- name: Setup and run nfs
  ansible.builtin.include_role:
    name: geerlingguy.nfs
 
- name: Allow nfs traffic through the firewall
  when: firewalld_enabled | bool
  tags: [ firewall-config-nfs ]
  ansible.builtin.include_role:
    name: bootstrap_linux_firewalld
  vars:
    firewalld_action: configure
    firewalld_services: "{{ nfs_firewalld_services | d([]) }}"
    firewalld_ports: "{{ nfs_firewalld_ports | d([]) }}"
```

## TODO

- Implement `firewalld_helpers`
- Add support for `lockdown-whitelist.xml`

## Reference

- [ptrunk/ansible-firewalld](https://github.com/ptrunk/ansible-firewalld)

## Backlinks

- [Ansible Roles Documentation](./../../docs/ansible-roles.md)
```

This improved version maintains all original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.