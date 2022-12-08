
# Filter elements from list of dictionaries in ansible that match a condition

## Challenge

Below is a contrived example of my data. I want to extract the names of all customers when any of the dicts in the list `mylst.env` has a key with name `n1` I imagine this can be done with a nested loop, but cannot figure out how.

```yaml
- hosts: localhost
  gather_facts: no
  vars:
    - mylst:
        - apiVersion: v1
          name: customer1
          metaData:
              cycles: 10
              ships: 12
          env:
            - name: n1
              value: v1
            - name: n2
              value: v2
        - apiVersion: v1
          name: customer2
          metaData:
              cycles: 10
              ships: 12
          env:
            - name: n1
              value: v1
            - name: n3
              value: v3
        - apiVersion: v1
          name: customer3
          metaData:
              cycles: 10
              ships: 12
          env:
            - name: n3
              value: v1
            - name: n4
              value: v4
  tasks:
  - set_fact: 
       cust_lst: "{{ cust_lst|default([]) + [item.name] }}"
    with_items: "{{ mylst }}"
    # loop through item.env and look for elements where elem.name == n1
    when: item.env | length > 0

  - debug: var=cust_lst 
```


## Solutions

### Using json_query filter

The `json_query` filter is a great tool for these kinds of tasks. It takes a little while to wrap your head around, but give this a go:

```yaml
  - set_fact:
      cust_lst: "{{ mylst | json_query(query) }}"
    vars:
      query: "[?env[?name=='n1']].name"
```

You can find out more at the [official documentation](https://docs.ansible.com/ansible/latest/collections/community/general/docsite/filter_guide.html#selecting-json-data-json-queries) and this shamelessly plugged [blog post](https://parko.id.au/2018/08/16/complex-data-structures-and-the-ansible-json_query-filter/)


### Using map filter

you could use the `map` filter on the `item.env` list to get a list of names each element in the `mylst` contains. then if the keyword "n1" is in that list, add to the `final_var`. please see below

* PLAYBOOK:

```yaml
---
- hosts: localhost
  gather_facts: false
  vars:
    mylst:
    - apiVersion: v1
      name: customer1
      metaData:
          cycles: 10
          ships: 12
      env:
        - name: n1
          value: v1
        - name: n2
          value: v2
    - apiVersion: v1
      name: customer2
      metaData:
          cycles: 10
          ships: 12
      env:
        - name: n1
          value: v1
        - name: n3
          value: v3
    - apiVersion: v1
      name: customer3
      metaData:
          cycles: 10
          ships: 12
      env:
        - name: n3
          value: v1
        - name: n4
          value: v4
    - apiVersion: v1
      name: customer4
      metaData:
          cycles: 10
          ships: 12
      env:
        - name2: n3
          value: v1
        - name2: n4
          value: v4

  tasks:

  - name: prepare var
    set_fact:
      final_var: "{{ final_var | default([]) + [item.name] }}"
    when: '"n1" in {{ item.env | selectattr("name", "defined") | map(attribute="name") | list }}'
    with_items:
    - "{{ mylst }}"

  - name: print var
    debug:
      var: final_var
```

you will notice that i added a 4th element in the `mylst` that contains no attributes with key = "name". these will be filtered out by the `selectattr("name", "defined"` filter, before passed to the map filter.

* OUTPUT:

```shell
PLAY [localhost] *******************************************************************************************************************************************************************************************************

TASK [prepare var] *****************************************************************************************************************************************************************************************************
[WARNING]: conditional statements should not include jinja2 templating delimiters such as {{ }} or {% %}. Found: "n1" in {{ item.env | selectattr("name", "defined") | map(attribute="name") | list }}

ok: [localhost] => (item={'apiVersion': 'v1', 'name': 'customer1', 'metaData': {'cycles': 10, 'ships': 12}, 'env': [{'name': 'n1', 'value': 'v1'}, {'name': 'n2', 'value': 'v2'}]})
ok: [localhost] => (item={'apiVersion': 'v1', 'name': 'customer2', 'metaData': {'cycles': 10, 'ships': 12}, 'env': [{'name': 'n1', 'value': 'v1'}, {'name': 'n3', 'value': 'v3'}]})
skipping: [localhost] => (item={'apiVersion': 'v1', 'name': 'customer3', 'metaData': {'cycles': 10, 'ships': 12}, 'env': [{'name': 'n3', 'value': 'v1'}, {'name': 'n4', 'value': 'v4'}]}) 
skipping: [localhost] => (item={'apiVersion': 'v1', 'name': 'customer4', 'metaData': {'cycles': 10, 'ships': 12}, 'env': [{'name2': 'n3', 'value': 'v1'}, {'name2': 'n4', 'value': 'v4'}]}) 

TASK [print var] *******************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "final_var": [
        "customer1",
        "customer2"
    ]
}

PLAY RECAP *************************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

hope these help.

#### for ansible 2.7.5 error (as described in comments below)

this task was found to be circumventing the 2.7.5 error:

```yaml
  - name: prepare var
    set_fact:
      final_var: "{{ final_var | default([]) + [item.name] }}"
    when: "'n1' in item.env | selectattr('name', 'defined') | map(attribute='name') | list"
    with_items:
    - "{{ mylst }}"
```

## Reference

* https://stackoverflow.com/questions/59202186/filter-elements-from-list-of-dictionaries-in-ansible-that-match-a-condition
* 