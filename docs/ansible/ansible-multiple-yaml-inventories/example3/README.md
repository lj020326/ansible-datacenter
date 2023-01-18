
# Example 3: Playbook using multiple YAML inventories with group requirement sufficiency  

In the prior [Example 2](../example2/README.md), with running on the merged inventory, the expected results were that only the appropriate network group would be assigned for each host.
Instead, we found that all the hosts in both networks have both 'network' groups assigned.
This is not the intended or expected behavior.

The following example will look to solve this.

## Playbook used

The playbook as follows:

```yaml
- name: "Run trace var play"
  hosts: all
  gather_facts: false
  connection: local
  tasks:
    - debug:
        var: trace_var
    - debug:
        var: group_names
```

In this example there are 2 networks located at 2 sites resulting in 4 YAML inventory files, with hierarchy diagrammed as follows:

```mermaid
graph TD;
    A[all] --> B[network1]
    A[all] --> C[network2]
    B --> D["site1<br>network1/site1.yml"]
    B --> E["site2<br>network1/site2.yml"]
    C --> F["site1<br>network2/site1.yml"]
    C --> G["site2<br>network2/site2.yml"]
```


For each of the 4 inventory files, the following group/host hierarchy will be implemented:

```mermaid
graph TD;
    A[all] --> C[hosts]
    A[all] --> D[children]
    C --> I["web01.qa.net[1|2]site[1|2].example.int"]
    C --> J["web02.qa.net[1|2]site[1|2].example.int"]
    D --> E[rhel7]
    D --> F[environment_qa]
    D --> G["location_site[1|2]"]
    D --> H["network[1|2]"]
    E --> K[hosts]
    K --> L["web01.qa.net[1|2]site[1|2].example.int"]
    K --> M["web02.qa.net[1|2]site[1|2].example.int"]
    F --> N[hosts]
    N --> O["web01.qa.net[1|2]site[1|2].example.int"]
    N --> P["web02.qa.net[1|2]site[1|2].example.int"]
    G --> Q[hosts]
    Q --> R["web01.qa.net[1|2]site[1|2].example.int"]
    Q --> S["web02.qa.net[1|2]site[1|2].example.int"]
    H --> T[hosts]
    T --> U["web01.qa.net[1|2]site[1|2].example.int"]
    T --> W["web02.qa.net[1|2]site[1|2].example.int"]
```


Each site.yml inventory will be setup similar to the following with the "[1|2]" regex pattern evaluated for each of the 4 cases:

```yaml
all:
  hosts:
    web01.qa.net[1|2]site[1|2].example.int:
      trace_var: site[1|2]/web01.qa.net[1|2]site[1|2].example.int
    web02.qa.net[1|2]site[1|2].example.int:
      trace_var: site[1|2]/rhel7/web02.qa.net[1|2]site[1|2].example.int
  children:
    rhel7:
      vars:
        trace_var: site[1|2]/rhel7
      hosts:
        web01.qa.net[1|2]site[1|2].example.int: {}
        web02.qa.net[1|2]site[1|2].example.int: {}
    environment_qa:
      vars:
        trace_var: site[1|2]/environment_qa
      hosts:
        web01.qa.net[1|2]site[1|2].example.int: {}
        web02.qa.net[1|2]site[1|2].example.int: {}
    location_site[1|2]:
      vars:
        trace_var: site[1|2]/location_site[1|2]
      hosts:
        web01.qa.net[1|2]site[1|2].example.int: {}
        web02.qa.net[1|2]site[1|2].example.int: {}
    network[1|2]:
      vars:
        trace_var: site[1|2]/network[1|2]
      hosts:
        web01.qa.net[1|2]site[1|2].example.int: {}
        web02.qa.net[1|2]site[1|2].example.int: {}
    ungrouped: {}

```

Each of the respective inventory files:

* [network1/site1 inventory](./inventory/network1/site1.yml)
* [network1/site2 inventory](./inventory/network1/site2.yml)
* [network2/site1 inventory](./inventory/network2/site1.yml)
* [network2/site2 inventory](./inventory/network2/site2.yml)


With the 4 inventories mentioned, we now seek to confirm that the expected value appears for the 'group_names' special variable and the 'trace_var' variable for both hosts.

playbook run for inventory/network1/site1.yml:
```output
ansible-playbook -i ./inventory/network1/site1.yml playbook.yml

PLAY [Run trace var play] ************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site1.example.int] => {
    "trace_var": "network1/site1/web01.qa.net1site1.example.int"
}
ok: [web02.qa.net1site1.example.int] => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "rhel7"
    ]
}
ok: [web02.qa.net1site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "rhel7"
    ]
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
web01.qa.net1site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net1site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

This is as expected.

playbook run for inventory/network1/site2.yml:
```output
ansible-playbook -i ./inventory/network1/site2.yml playbook.yml

PLAY [Run trace var play] ************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site2.example.int] => {
    "trace_var": "network1/site2/web01.qa.net1site2.example.int"
}
ok: [web02.qa.net1site2.example.int] => {
    "trace_var": "network1/site2/web02.qa.net1site2.example.int"
}

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "rhel7"
    ]
}
ok: [web02.qa.net1site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "rhel7"
    ]
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
web01.qa.net1site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net1site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

This is as expected.


playbook run for inventory/network2/site1.yml:
```output
ansible-playbook -i ./inventory/network2/site1.yml playbook.yml

PLAY [Run trace var play] ************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net2site1.example.int] => {
    "trace_var": "network2/site1/web01.qa.net2site1.example.int"
}
ok: [web02.qa.net2site1.example.int] => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net2site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "rhel7"
    ]
}
ok: [web02.qa.net2site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "rhel7"
    ]
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
web01.qa.net2site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net2site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

This is as expected.

playbook run for inventory/network2/site2.yml:
```output
ansible-playbook -i ./inventory/network2/site2.yml playbook.yml

PLAY [Run trace var play] ************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net2site2.example.int] => {
    "trace_var": "network2/site2/web01.qa.net2site2.example.int"
}
ok: [web02.qa.net2site2.example.int] => {
    "trace_var": "network2/site2/web02.qa.net2site2.example.int"
}

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net2site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "rhel7"
    ]
}
ok: [web02.qa.net2site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "rhel7"
    ]
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
web01.qa.net2site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net2site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

This is as expected.


## Combined inventory run.


playbook run for combined inventory:
```output
ansible-playbook -i ./inventory/ playbook.yml

PLAY [Run trace var play] ************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site1.example.int] => {
    "trace_var": "network1/site1/web01.qa.net1site1.example.int"
}
ok: [web02.qa.net1site1.example.int] => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}
ok: [web01.qa.net1site2.example.int] => {
    "trace_var": "network1/site2/web01.qa.net1site2.example.int"
}
ok: [web02.qa.net1site2.example.int] => {
    "trace_var": "network1/site2/web02.qa.net1site2.example.int"
}
ok: [web01.qa.net2site1.example.int] => {
    "trace_var": "network2/site1/web01.qa.net2site1.example.int"
}
ok: [web02.qa.net2site1.example.int] => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}
ok: [web01.qa.net2site2.example.int] => {
    "trace_var": "network2/site2/web01.qa.net2site2.example.int"
}
ok: [web02.qa.net2site2.example.int] => {
    "trace_var": "network2/site2/web02.qa.net2site2.example.int"
}

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [web01.qa.net1site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "network1",
        "rhel7"
    ]
}
ok: [web02.qa.net1site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "network1",
        "rhel7"
    ]
}
ok: [web01.qa.net1site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "network1",
        "rhel7"
    ]
}
ok: [web02.qa.net1site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "network1",
        "rhel7"
    ]
}
ok: [web01.qa.net2site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "network2",
        "rhel7"
    ]
}
ok: [web02.qa.net2site1.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site1",
        "network2",
        "rhel7"
    ]
}
ok: [web01.qa.net2site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "network2",
        "rhel7"
    ]
}
ok: [web02.qa.net2site2.example.int] => {
    "group_names": [
        "environment_qa",
        "location_site2",
        "network2",
        "rhel7"
    ]
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
web01.qa.net1site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web01.qa.net1site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web01.qa.net2site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web01.qa.net2site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net1site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net1site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net2site1.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
web02.qa.net2site2.example.int : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

## Debug host vars using groups to target sets of hosts

Run debug using a group defined set of hosts.

Run for group 'network2'
```shell
ansible -i ./inventory/ network2 -m debug -a var=trace_var 
web01.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web01.qa.net2site1.example.int"
}
web02.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}
web01.qa.net2site2.example.int | SUCCESS => {
    "trace_var": "network2/site2/web01.qa.net2site2.example.int"
}
web02.qa.net2site2.example.int | SUCCESS => {
    "trace_var": "network2/site2/web02.qa.net2site2.example.int"
}

```

Run for group 'location_site1'
```shell
ansible -i ./inventory/ -m debug -a var=trace_var location_site1
web01.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web01.qa.net1site1.example.int"
}
web02.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}
web01.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web01.qa.net2site1.example.int"
}
web02.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}

```

Run for group(s) matching expression '*site1'
```shell
ansible -i ./inventory/ -m debug -a var=trace_var *site1
web01.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web01.qa.net1site1.example.int"
}
web02.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}
web01.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web01.qa.net2site1.example.int"
}
web02.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}

```

Run for group(s) matching multiple groups 'location_site1,&network1'
```shell
ansible -i ./inventory/ -m debug -a var=trace_var location_site1,\&network1
web01.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web01.qa.net1site1.example.int"
}
web02.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}

```


## Limit hosts in a group

Run for group 'site1' with a specified limit
```shell
ansible -i ./inventory/ -m debug -a var=trace_var location_site1 -l web-q2*
web02.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "network1/site1/web02.qa.net1site1.example.int"
}
web02.qa.net2site1.example.int | SUCCESS => {
    "trace_var": "network2/site1/web02.qa.net2site1.example.int"
}

```

```shell
ansible -i ./inventory/ network1  -m debug -a var=trace_var
web01.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "('network1/site1/web01.qa.net1site1.example.int', 'QA', 'SITE1')"
}
web02.qa.net1site1.example.int | SUCCESS => {
    "trace_var": "('network1/site1/web02.qa.net1site1.example.int', 'QA', 'SITE1')"
}
web01.qa.net1site2.example.int | SUCCESS => {
    "trace_var": "('network1/site2/web01.qa.net1site2.example.int', 'QA', 'SITE2')"
}
web02.qa.net1site2.example.int | SUCCESS => {
    "trace_var": "('network1/site2/web02.qa.net1site2.example.int', 'QA', 'SITE2')"
}

```
