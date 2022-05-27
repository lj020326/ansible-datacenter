
# How to use json_query to query a list of dictionaries

I want to search a list of dictionaries resulting in a subset of the list of dictionaries with a subset of the keys in the original dictionaries.

The below has the list of dictionaries from which I want to create two separate lists.

List 1 should contain the name key from each dictionary for entries whose members list contains the subPath key AND whose value contains a specific value.

List 2 should contain the name key from each dictionary for entries whose members list does NOT contain the subPath key and whose name contains a specific value.

Using the below data structure:

```
    "gtm_a_pools": [
        {
            "alternate_mode": "global-availability",
            "dynamic_ratio": "no",
            "enabled": "yes",
            "fallback_mode": "return-to-dns",
            "full_path": "/Common/a2-test_pool",
            "load_balancing_mode": "global-availability",
            "manual_resume": "no",
            "max_answers_returned": 1,
            "members": [
                {
                    "disabled": "no",
                    "enabled": "yes",
                    "limitMaxBps": 0,
                    "limitMaxBpsStatus": "disabled",
                    "limitMaxConnections": 0,
                    "limitMaxConnectionsStatus": "disabled",
                    "limitMaxPps": 0,
                    "limitMaxPpsStatus": "disabled",
                    "member_order": 0,
                    "monitor": "default",
                    "name": "a2-test_443_vs",
                    "partition": "Common",
                    "ratio": 1,
                    "subPath": "test-dmz-dc1-pair:/Common"
                },
                {
                    "disabled": "no",
                    "enabled": "yes",
                    "limitMaxBps": 0,
                    "limitMaxBpsStatus": "disabled",
                    "limitMaxConnections": 0,
                    "limitMaxConnectionsStatus": "disabled",
                    "limitMaxPps": 0,
                    "limitMaxPpsStatus": "disabled",
                    "member_order": 1,
                    "monitor": "default",
                    "name": "dc2-a2-test_443_vs",
                    "partition": "Common",
                    "ratio": 1,
                    "subPath": "test-dmz-dc2-pair:/Common"
                }
            ],
            "name": "a2-test_pool",
            "partition": "Common",
            "qos_hit_ratio": 5,
            "qos_hops": 0,
            "qos_kilobytes_second": 3,
            "qos_lcs": 30,
            "qos_packet_rate": 1,
            "qos_rtt": 50,
            "qos_topology": 0,
            "qos_vs_capacity": 0,
            "qos_vs_score": 0,
            "ttl": 30,
            "verify_member_availability": "yes"
        },
        {
            "alternate_mode": "round-robin",
            "dynamic_ratio": "no",
            "enabled": "yes",
            "fallback_mode": "return-to-dns",
            "full_path": "/Common/aci_pool",
            "load_balancing_mode": "round-robin",
            "manual_resume": "no",
            "max_answers_returned": 1,
            "members": [
                {
                    "disabled": "no",
                    "enabled": "yes",
                    "limitMaxBps": 0,
                    "limitMaxBpsStatus": "disabled",
                    "limitMaxConnections": 0,
                    "limitMaxConnectionsStatus": "disabled",
                    "limitMaxPps": 0,
                    "limitMaxPpsStatus": "disabled",
                    "member_order": 0,
                    "monitor": "default",
                    "name": "prod_dc1_servers:aci",
                    "partition": "Common",
                    "ratio": 1
                },
                {
                    "disabled": "no",
                    "enabled": "yes",
                    "limitMaxBps": 0,
                    "limitMaxBpsStatus": "disabled",
                    "limitMaxConnections": 0,
                    "limitMaxConnectionsStatus": "disabled",
                    "limitMaxPps": 0,
                    "limitMaxPpsStatus": "disabled",
                    "member_order": 1,
                    "monitor": "default",
                    "name": "prod_dc1_servers:aci",
                    "partition": "Common",
                    "ratio": 1
                }
            ],
            "name": "aci_pool",
            "partition": "Common",
            "qos_hit_ratio": 5,
            "qos_hops": 0,
            "qos_kilobytes_second": 3,
            "qos_lcs": 30,
            "qos_packet_rate": 1,
            "qos_rtt": 50,
            "qos_topology": 0,
            "qos_vs_capacity": 0,
            "qos_vs_score": 0,
            "ttl": 30,
            "verify_member_availability": "yes"
        }
    ]
```


## Using subPath key

First iteration is finding those dictionaries whose members dictionary has the `subPath` key:

```
- name: debug
  debug:
    msg: "{{ device_facts.gtm_a_pools | json_query(query) }}"
  vars:
    query: "[].members[?!subPath][].name"
```

or doesn't have the subPath key:

```
- name: debug
  debug:
    msg: "{{ device_facts.gtm_a_pools | json_query(query) }}"
  vars:
    query: "[].members[?subPath][].name"
```

But this is returning the name key from within the members dictionary, when what I want is the name key from each gtm_a_pools dictionary based on the two above criterion (one list that has the subPath and one list for those without).

## Using intersection map filter

Instead of _json_query_, iterate the list and compare the number of _members_ e.g.

```yaml
    - set_fact:
        list1: "{{ list1|default([]) + [item.name] }}"
      loop: "{{ gtm_a_pools }}"
      when: item_length == subPath_length
      vars:
        subPath_length: "{{ item.members|map('intersect', ['subPath'])|flatten|length }}"
        item_length: "{{ item.members|length }}"
```

gives

```yaml
  list1:
  - a2-test_pool
```

If _"without subPath"_ means _"any member without subPath"_

```yaml
    - set_fact:
        list2: "{{ list2|default([]) + [item.name] }}"
      loop: "{{ gtm_a_pools }}"
      when: item_length != subPath_length
      vars:
        subPath_length: "{{ item.members|map('intersect', ['subPath'])|flatten|length }}"
        item_length: "{{ item.members|length }}"
```

gives

```yaml
  list2:
  - aci_pool
```

If _"without subPath"_ means _"all members without subPath"_ the task below gives the same result

```yaml
    - set_fact:
        list2: "{{ list2|default([]) + [item.name] }}"
      loop: "{{ gtm_a_pools }}"
      when: subPath_length|int == 0
      vars:
        subPath_length: "{{ item.members|map('intersect', ['subPath'])|flatten|length }}"
```

## Reference

* https://stackoverflow.com/a/66219344


