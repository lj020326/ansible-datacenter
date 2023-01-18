
# Example 7: Using derived/dynamic groups to derive large "subset" groups

This example use case is related to whenever the need exists to set up a set and disjoint set of sub-group configurations required for any playbook and corresponding roles (e.g., client/server configurations).

Basically / put simply, whenever there is the following conditions: 

1) a large group A, and 
2) a very small/finite subset group B within A, and 
3) the need exists to have a 3rd group C which is the difference of A - B = C, and 
4) the need to maintain the configuration state for group C in group_vars/groupC.yml format

Many use cases require network-specific servers/fixtures/assets to be setup for to serve/enable clients for network groups within an enterprise.
Some examples with servers within networks serving clients machines in the respective networks fitting this use case:

- router gateways
- firewalls
- dns servers
- ntp servers
- ldap servers
- postfix servers
- nfs servers
- repo/archive

and the list goes on...

The following section addresses the network/client needs for this use case specifically with respect to ansible YAML based inventory.


#### Simple Example for a derived group

Currently, functionality exists in ansible playbook to sufficiently limit hosts to an implied "subset" set of machines using the [patterns supported by the limit feature](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html).  For example, to specify all hosts in webservers except those in atlanta:

```shell
ansible-playbook site.yml --limit 'webservers:!atlanta' 
```

Now consider the following inventory use case.
![Derived Groups](./img/iac-derived-groups.png)

In the aforementioned diagram/example, to limit the targeted hosts to only clients:
```shell
ansible-playbook site.yml --limit 'network_a:!network_a_servers' 
```

However, if there are any configurations that the client group requires, then this method is insufficient.

Ideally, the YAML-based inventory could support derived groupings with operators similar to the limit directive.

For example, if the YAML-based inventory supported the following feature then the solution mentioned in the next section would not be necessary:

```yaml
all:
  children:
    network_a_clients: 
      hosts: network_a:!network_a_servers
      vars:
        network_server_list: "{{ groups['network_a_servers'] }}"
      
    network_a:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}
        machine10: {}
        machine11: {}
        machine12: {}
        ...
        ...
        ...
        machine99: {}
    
    network_a_servers:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}


```

But alas, the YAML-based ansible inventory does not support this feature, at least not at present.

#### Generalized Case

In the prior [Example 6](../example6/README.md), we successfully derived the ntp client group.

In this example we introduce a role specific parent group, called 'ntp_network', and a subgroup called 'ntp_server' in each network to simplify deriving/setting the ntp client settings.

Maintaining such a group configuration can be problematic.

E.g., Say the following parameters are given:

* A 'ntp_network' (parent) group has 100, 1000, or lets say __N machines__ and 
* A subset 'ntp_server' group only has a far less _finite number_ of instances, say 2, 4, or __M machines__
* A derived 'ntp_client' derived by group_names | intersect(['ntp_network'])==1 and group_names | intersect(['ntp_server'])==0 
  * this results in __N machines__ minus the server group of __M machines__.

So given an inventory with a 'ntp_network' group of 1000 machines, and a 'ntp_server' group of 4 machines, then the 'ntp_client' group would have 996 machines. 

Maintaining a 'ntp_client' group for multiple use-cases would have to redefine the child group of __(N - M) machines__. 

This can present risks since then each 'ntp_client' group is almost the same size as the parent 'network_server' group and exposes risks of maintaining synchronization of the group.

Multiply this by the number of use cases having the same/similar pattern.

Ideally, we do not want to explicitly define and maintain a 'ntp_client' group since it can be simply derived from the obtaining the difference of the 'network' and 'network_server' groups.

The following example will look to resolve the challenge of deriving the 'ntp_client' child group.  More specifically, the following example will demonstrate for the case of the internal ntp client example to derive a 'ntp_client_internal' group.

## Overview

In this example there are 2 networks located at 2 sites resulting in 4 YAML inventory files, with hierarchy diagrammed as follows:

```mermaid
graph TD;
    A[all] --> B[dmz]
    A[all] --> C[internal]
    B --> D["site1<br>dmz/site1.yml"]
    B --> E["site2<br>dmz/site2.yml"]
    C --> F["site1<br>internal/site1.yml"]
    C --> G["site2<br>internal/site2.yml"]
```


For each of the 4 inventory files, the following group/host hierarchy will be implemented:

```mermaid
graph TD;
    A[all] --> C[hosts]
    A[all] --> D[children]
    C --> I["web01.qa.site[1|2].example.[dmz|int]"]
    C --> J["web02.qa.site[1|2].example.[dmz|int]"]
    D --> E[rhel7]
    D --> F[environment_qa]
    D --> G["location_site[1|2]"]
    D --> H["network_[dmz|internal]"]
    E --> K[hosts]
    K --> L["web01.qa.site[1|2].example.[dmz|int]"]
    K --> M["web02.qa.site[1|2].example.[dmz|int]"]
    F --> N[hosts]
    N --> O["web01.qa.site[1|2].example.[dmz|int]"]
    N --> P["web02.qa.site[1|2].example.[dmz|int]"]
    G --> Q[hosts]
    Q --> R["web01.qa.site[1|2].example.[dmz|int]"]
    Q --> S["web02.qa.site[1|2].example.[dmz|int]"]
    H --> T[hosts]
    T --> U["web01.qa.site[1|2].example.[dmz|int]"]
    T --> W["web02.qa.site[1|2].example.[dmz|int]"]
```


Each site.yml inventory will be setup similar to the following with the "[dmz|internal]" and "[1|2]" regex patterns evaluated for each of the 4 cases:

```yaml
all:
  hosts:
    admin01.qa.site[1|2].example.[dmz|int]: 
      trace_var: site[1|2]/admin01.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
    admin02.qa.site[1|2].example.[dmz|int]: 
      trace_var: site[1|2]/admin01.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
    app01.qa.site[1|2].example.[dmz|int]: 
      trace_var: site[1|2]/app01.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
    app02.qa.site[1|2].example.[dmz|int]: 
      trace_var: site[1|2]/app01.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
    web01.qa.site[1|2].example.[dmz|int]:
      trace_var: site[1|2]/web01.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
    web02.qa.site[1|2].example.[dmz|int]:
      trace_var: site[1|2]/rhel7/web02.qa.site[1|2].example.[dmz|int]
      foreman: <94 keys>
  children:
    rhel6:
      vars:
        trace_var: dmz/site1/rhel6
      hosts:
        admin01.qa.site[1|2].example.[dmz|int]: {}
    rhel7:
      vars:
        trace_var: site[1|2]/rhel7
      hosts:
        admin02.qa.site[1|2].example.[dmz|int]: {}
        app01.qa.site[1|2].example.[dmz|int]: {}
        app02.qa.site[1|2].example.[dmz|int]: {}
        web01.qa.site[1|2].example.[dmz|int]: {}
        web02.qa.site[1|2].example.[dmz|int]: {}
    environment_qa:
      vars:
        trace_var: site[1|2]/environment_qa
      hosts:
        admin01.qa.site[1|2].example.[dmz|int]: {}
        admin01.qa.site[1|2].example.[dmz|int]: {}
        app01.qa.site[1|2].example.[dmz|int]: {}
        app02.qa.site[1|2].example.[dmz|int]: {}
        web01.qa.site[1|2].example.[dmz|int]: {}
        web02.qa.site[1|2].example.[dmz|int]: {}
    location_site[1|2]:
      vars:
        trace_var: site[1|2]/location_site[1|2]
      hosts:
        admin01.qa.site[1|2].example.[dmz|int]: {}
        admin01.qa.site[1|2].example.[dmz|int]: {}
        app01.qa.site[1|2].example.[dmz|int]: {}
        app02.qa.site[1|2].example.[dmz|int]: {}
        web01.qa.site[1|2].example.[dmz|int]: {}
        web02.qa.site[1|2].example.[dmz|int]: {}
    network_[dmz|internal]:
      vars:
        trace_var: site[1|2]/network_[dmz|internal]
      hosts:
        admin01.qa.site[1|2].example.[dmz|int]: {}
        admin01.qa.site[1|2].example.[dmz|int]: {}
        app01.qa.site[1|2].example.[dmz|int]: {}
        app02.qa.site[1|2].example.[dmz|int]: {}
        web01.qa.site[1|2].example.[dmz|int]: {}
        web02.qa.site[1|2].example.[dmz|int]: {}
    ungrouped: {}

```

Each of the respective inventory files:

* [dmz/site1 inventory](./inventory/dmz/site1.yml)
* [dmz/site2 inventory](./inventory/dmz/site2.yml)
* [internal/site1 inventory](./inventory/internal/site1.yml)
* [internal/site2 inventory](./inventory/internal/site2.yml)



## Define NTP inventory groups

For the ntp playbook/role to work on both servers and clients, we will define the 'ntp_server' and 'ntp_client' groups to correctly scope the machines to be applied.

All machines in the 'network_dmz' group will have the __ntp_servers__ variable set to the externally defined ntp servers.

For each site in the 'network_internal' group, there will be 2 machines defined in the 'ntp_servers' group.
All ntp clients in the 'network_internal' group will have the __ntp_servers__ variable set to the 2 ntp_server machines in the respective site.

### Internal Network NTP Client Configuration

For the internal network inventory, the 'ntp_client_internal' group is defined with the parent group of 'ntp_client' without any children groups or hosts defined.  The group is a _placeholder_ group used by the dynamic group_by strategy/pattern later in this example.

[inventory/internal/ntp.yml](./inventory/internal/ntp.yml):
```yaml
all:
  children:
    ntp_client:
      vars:
        group_trace_var: internal/ntp.yml[ntp_client]
      children:
        ntp_client_internal: {}
    ntp_client_internal:
      vars:
        group_trace_var: internal/ntp.yml[ntp_client_internal]
      children:
        ntp_client: {}
    ntp_server:
      vars:
        group_trace_var: internal/ntp.yml[ntp_server]
      hosts:
        admin01.qa.site1.example.int: {}
        admin02.qa.site1.example.int: {}
        admin01.qa.site2.example.int: {}
        admin02.qa.site2.example.int: {}
```

The 'ntp_client_internal' _placeholder_ group also allows the binding to the respective group_vars found in [ntp_client_internal.yml](./internal/group_vars/ntp_client_internal.yml) needed for hosts that get applied to this group.

The expected results from the __ntp_servers__ variable evaluation in the ['ntp_client_internal'](./inventory/internal/group_vars/ntp_client_internal.yml) group would be as follows for each site.

site1:
```output
"ntp_servers": [
    "admin01.qa.site1.example.int",
    "admin02.qa.site1.example.int"
]

```

site2:
```output
ntp_servers: [
    "admin01.qa.site2.example.int",
    "admin02.qa.site2.example.int"
]
```


### DMZ Network NTP Client Configuration

The 'ntp-client' group will include all linux machines for the respective environment.
In this case, the environment will be defined with the existing test environment group named 'environment_test'.

Now we can define the YAML groups to be used by the 'ntp' playbook/role as follows:

[inventory/dmz/ntp.yml](./inventory/dmz/ntp.yml):
```yaml
all:
  children:
    ntp_client:
      children:
        environment_test: {}
    ntp:
      children:
        ntp_client: {}
```

Note that for the DMZ network, that there are no internal ntp servers and that all machines are ntp clients with the __ntp_server__ variable set to external/public ntp server machines.

This can be seen in the __ntp_servers__ variable in the ['ntp_client'](./inventory/dmz/group_vars/ntp_client.yml) group variable configuration:

```yaml
ntp_servers:
  - 0.rhel.pool.ntp.org
  - 1.rhel.pool.ntp.org
  - 2.rhel.pool.ntp.org
  - 3.rhel.pool.ntp.org

```

## NTP parent group
A ntp parent group is defined such that it contains all the related groups useful for targeting plays to run against for the entire NTP configuration playbook.

[inventory/internal/ntp.yml](./inventory/internal/ntp.yml):
```yaml
all:
  children:
    ntp_network:
      children:
        some_network: {}
        ntp_client:
          vars:
            group_trace_var: internal/ntp.yml[ntp_client]
        ntp_client_internal:
          vars:
            group_trace_var: internal/ntp.yml[ntp_client_internal]
        ntp_server:
          vars:
            group_trace_var: internal/ntp.yml[ntp_server]
          hosts:
            admin01.qa.site1.example.int: {}
            admin02.qa.site1.example.int: {}
            admin01.qa.site2.example.int: {}
            admin02.qa.site2.example.int: {}
```

## Setup play to derive the ntp_client_internal group

Next we define a play to derive the ntp_client_internal group

[display-ntp-servers.yml](display-ntp-servers.yml):
```yaml
---

- name: "Apply ntp_server"
  hosts: ntp_server
  gather_facts: false
  connection: local
  tasks:

    - debug:
        var: group_names
        verbosity: 1
    - debug:
        var: ntp_servers

- name: "Apply ntp_client group setting"
  hosts: ntp_network,!ntp_server
  gather_facts: false
  connection: local
  tasks:

    - name: Derive ntp_client_internal child group of hosts based on difference of network_internal and ntp_server
      when: inventory_hostname in __ntp_client_internal
      group_by:
        key: "ntp_client"
    - debug:
        var: ntp_servers

- name: "Run trace var play for machines in the newly defined ntp_client_internal group"
#  hosts: ntp_client_internal
  hosts: ntp
  gather_facts: false
  connection: local
  tasks:

    - debug:
        var: trace_var
        verbosity: 1
    - debug:
        var: group_trace_var
        verbosity: 1
    - debug:
        var: group_names
        verbosity: 1
    - debug:
        var: ansible_default_ipv4.address
        verbosity: 1
    - debug:
        var: ntp_servers
```

## Expected Play Results

### Internal Network NTP Server Expected Results
Upon running the [display-ntp-servers.yml play](display-ntp-servers.yml), the expected results should be as follows for all machines defined in the ['ntp_server'](./inventory/internal/group_vars/ntp_server.yml) group:
```output
"ntp_servers": [
    "0.us.pool.ntp.org",
    "1.us.pool.ntp.org",
    "2.us.pool.ntp.org",
    "3.us.pool.ntp.org"
]

```

### Internal Network NTP Client Expected Results
Upon running the [display-ntp-servers.yml play](display-ntp-servers.yml), the expected results should be as follows for all machines defined in the ['ntp_client_internal'](./inventory/internal/group_vars/ntp_client_internal.yml) group:

site1:
```output
"ntp_servers": [
    "admin01.qa.site1.example.int",
    "admin02.qa.site1.example.int"
]

```

site2:
```output
ntp_servers: [
    "admin01.qa.site2.example.int",
    "admin02.qa.site2.example.int"
]
```


## Verify Play Run Results
Now we run the play for the internal network to determine if the correct ntp_server configuration is made for the server and client groups.

```shell
ansible-playbook -i ./inventory/internal display-ntp-servers.yml

PLAY [Define derived ntp_client_internal] *******************************************************************************************************************************************************************************************************************************

TASK [Derive __ntp_client_internal list of hosts based on difference of network_internal and ntp_server groups] *********************************************************************************************************************************************************
ok: [localhost]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [localhost]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [localhost]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [localhost]

TASK [Copy __ntp_client_internal fact to other servers] *****************************************************************************************************************************************************************************************************************
ok: [localhost -> admin01.qa.site1.example.int] => (item=admin01.qa.site1.example.int)
ok: [localhost -> admin02.qa.site1.example.int] => (item=admin02.qa.site1.example.int)
ok: [localhost -> app01.qa.site1.example.int] => (item=app01.qa.site1.example.int)
ok: [localhost -> app02.qa.site1.example.int] => (item=app02.qa.site1.example.int)
ok: [localhost -> web01.qa.site1.example.int] => (item=web01.qa.site1.example.int)
ok: [localhost -> web02.qa.site1.example.int] => (item=web02.qa.site1.example.int)
ok: [localhost -> admin01.qa.site2.example.int] => (item=admin01.qa.site2.example.int)
ok: [localhost -> admin02.qa.site2.example.int] => (item=admin02.qa.site2.example.int)
ok: [localhost -> app01.qa.site2.example.int] => (item=app01.qa.site2.example.int)
ok: [localhost -> app02.qa.site2.example.int] => (item=app02.qa.site2.example.int)
ok: [localhost -> web01.qa.site2.example.int] => (item=web01.qa.site2.example.int)
ok: [localhost -> web02.qa.site2.example.int] => (item=web02.qa.site2.example.int)

PLAY [Apply ntp_client_internal group setting to machines in the derived list] ******************************************************************************************************************************************************************************************

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
skipping: [app01.qa.site1.example.int]
skipping: [app02.qa.site1.example.int]
skipping: [web01.qa.site1.example.int]
skipping: [web02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
skipping: [app01.qa.site2.example.int]
skipping: [app02.qa.site2.example.int]
skipping: [web01.qa.site2.example.int]
skipping: [web02.qa.site2.example.int]

TASK [Derive ntp_client_internal child group of hosts based on difference of network_internal and ntp_server] ***********************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
changed: [app01.qa.site1.example.int]
changed: [app02.qa.site1.example.int]
changed: [web01.qa.site1.example.int]
changed: [web02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
changed: [app01.qa.site2.example.int]
changed: [app02.qa.site2.example.int]
changed: [web01.qa.site2.example.int]
changed: [web02.qa.site2.example.int]

PLAY [Run trace var play for machines in the newly defined ntp_client_internal group] ***********************************************************************************************************************************************************************************

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
skipping: [app01.qa.site1.example.int]
skipping: [app02.qa.site1.example.int]
skipping: [web01.qa.site1.example.int]
skipping: [web02.qa.site1.example.int]
skipping: [app01.qa.site2.example.int]
skipping: [app02.qa.site2.example.int]
skipping: [web01.qa.site2.example.int]
skipping: [web02.qa.site2.example.int]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
skipping: [app01.qa.site1.example.int]
skipping: [app02.qa.site1.example.int]
skipping: [web01.qa.site1.example.int]
skipping: [web02.qa.site1.example.int]
skipping: [app01.qa.site2.example.int]
skipping: [app02.qa.site2.example.int]
skipping: [web01.qa.site2.example.int]
skipping: [web02.qa.site2.example.int]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
skipping: [app01.qa.site1.example.int]
skipping: [app02.qa.site1.example.int]
skipping: [web01.qa.site1.example.int]
skipping: [web02.qa.site1.example.int]
skipping: [app01.qa.site2.example.int]
skipping: [app02.qa.site2.example.int]
skipping: [web01.qa.site2.example.int]
skipping: [web02.qa.site2.example.int]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
skipping: [admin01.qa.site1.example.int]
skipping: [admin02.qa.site1.example.int]
skipping: [admin01.qa.site2.example.int]
skipping: [admin02.qa.site2.example.int]
skipping: [app01.qa.site1.example.int]
skipping: [app02.qa.site1.example.int]
skipping: [web01.qa.site1.example.int]
skipping: [web02.qa.site1.example.int]
skipping: [app01.qa.site2.example.int]
skipping: [app02.qa.site2.example.int]
skipping: [web01.qa.site2.example.int]
skipping: [web02.qa.site2.example.int]

TASK [debug] ************************************************************************************************************************************************************************************************************************************************************
ok: [admin01.qa.site1.example.int] => {
    "ntp_servers": [
        "0.us.pool.ntp.org",
        "1.us.pool.ntp.org",
        "2.us.pool.ntp.org",
        "3.us.pool.ntp.org"
    ]
}
ok: [admin02.qa.site1.example.int] => {
    "ntp_servers": [
        "0.us.pool.ntp.org",
        "1.us.pool.ntp.org",
        "2.us.pool.ntp.org",
        "3.us.pool.ntp.org"
    ]
}
ok: [admin01.qa.site2.example.int] => {
    "ntp_servers": [
        "0.us.pool.ntp.org",
        "1.us.pool.ntp.org",
        "2.us.pool.ntp.org",
        "3.us.pool.ntp.org"
    ]
}
ok: [admin02.qa.site2.example.int] => {
    "ntp_servers": [
        "0.us.pool.ntp.org",
        "1.us.pool.ntp.org",
        "2.us.pool.ntp.org",
        "3.us.pool.ntp.org"
    ]
}
ok: [app01.qa.site1.example.int] => {
    "ntp_servers": [
        "admin01.qa.site1.example.int",
        "admin02.qa.site1.example.int"
    ]
}
ok: [app02.qa.site1.example.int] => {
    "ntp_servers": [
        "admin01.qa.site1.example.int",
        "admin02.qa.site1.example.int"
    ]
}
ok: [web01.qa.site1.example.int] => {
    "ntp_servers": [
        "admin01.qa.site1.example.int",
        "admin02.qa.site1.example.int"
    ]
}
ok: [web02.qa.site1.example.int] => {
    "ntp_servers": [
        "admin01.qa.site1.example.int",
        "admin02.qa.site1.example.int"
    ]
}
ok: [app01.qa.site2.example.int] => {
    "ntp_servers": [
        "admin01.qa.site2.example.int",
        "admin02.qa.site2.example.int"
    ]
}
ok: [app02.qa.site2.example.int] => {
    "ntp_servers": [
        "admin01.qa.site2.example.int",
        "admin02.qa.site2.example.int"
    ]
}
ok: [web01.qa.site2.example.int] => {
    "ntp_servers": [
        "admin01.qa.site2.example.int",
        "admin02.qa.site2.example.int"
    ]
}
ok: [web02.qa.site2.example.int] => {
    "ntp_servers": [
        "admin01.qa.site2.example.int",
        "admin02.qa.site2.example.int"
    ]
}

PLAY RECAP **************************************************************************************************************************************************************************************************************************************************************
admin01.qa.site1.example.int : ok=1    changed=0    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0   
admin01.qa.site2.example.int : ok=1    changed=0    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0   
admin02.qa.site1.example.int : ok=1    changed=0    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0   
admin02.qa.site2.example.int : ok=1    changed=0    unreachable=0    failed=0    skipped=6    rescued=0    ignored=0   
app01.qa.site1.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
app01.qa.site2.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
app02.qa.site1.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
app02.qa.site2.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
web01.qa.site1.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
web01.qa.site2.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
web02.qa.site1.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
web02.qa.site2.example.int : ok=2    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   


```


