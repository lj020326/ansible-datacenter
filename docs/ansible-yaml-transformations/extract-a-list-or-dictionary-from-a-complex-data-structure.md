
# Ansible: extracting a list or dictionary from a complex data structure

If you have a complex JSON data structure or perhaps an array of rich data structures as the result of module output, you may want to extract this into a workable list or dictionary you can take action on.

For this article, I will emulate the resulting output from the ‘[stat](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html)‘ module when it checks for file existence using ‘with\_fileglob’.   What is returned is an array of deeply nested values that simplified can be represented like below:

```
vars:
  my_json_structure:
    results:
      - item: /tmp/a.txt
        stat:
          exists: true
      - item: /tmp/b.txt
        stat:
          exists: false
      - item: /tmp/c.txt
        stat:
          exists: true
```

Use ‘map’ to extract just the paths as an array.

```
- set_fact:
    exist_list: "{{ ( my_json_structure.results | map(attribute='item') )  }}"
- debug: msg="{{ exist_list }}"

# output looks like
"msg": [
  "/tmp/a.txt",
  "/tmp/b.txt",
  "/tmp/c.txt"
]
```

Use  ‘dict’ and ‘zip’ to create a simple map where the key and value are the same.

```
- set_fact:
    exist_map_simple: "{{ dict( exist_list | zip(exist_list) ) }}"
- debug: msg="{{ exist_map_simple }}"

# output looks like
"msg": {
  "/tmp/a.txt": "/tmp/a.txt",
  "/tmp/b.txt": "/tmp/b.txt",
  "/tmp/c.txt": "/tmp/c.txt"
}
```

Use ‘json\_query’ and ‘combine’ to create a map where they key is the path and the value is whether the file existed.

```
- set_fact:
  exist_map: "{{ exist_map|default({}) | combine( {item.item : item.stat.exists} ) }}"
  with_items: "{{ my_json_structure | json_query('results[*]') }}"
- debug: msg="{{ exist_map }}"

# output looks like
"msg": {
  "/tmp/a.txt": true,
  "/tmp/b.txt": false,
  "/tmp/c.txt": true
}
```

The full playbook, [datastructure-to-dict.yml](./datastructure-to-dict.yml)

The use of json\_query requires the ‘jmespath’ python module and ‘community.general’ Ansible Galaxy module.

```
# required pip module
pip3 install jmespath

# 'community.general'
ansible-galaxy collection install community.general
```

Or via Ansible like below.

```
- name: ensure jmespath is installed to support json_query filter
  become: yes
  pip:
    name: jmespath

- name: install community.general collection from ansible galaxy
  command:
    cmd: ansible-galaxy collection install community.general
```

REFERENCES

[ansible, filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)

[middlewareinventory, json\_query combine and with\_items technique](https://www.middlewareinventory.com/blog/ansible_json_query/)

[tailored.cloud, ansible filter and map](https://www.tailored.cloud/devops/how-to-filter-and-map-lists-in-ansible/)

[toroid.org, using combine to merge hashes](https://toroid.org/ansible-combine)

NOTES

Here is the output that ‘my\_json\_structure’ emulates

```
- stat:
   path: "{{item}}"
 register: complex_results
 with_fileglob: "/tmp/*"
- debug: msg="{{complex_results}}"
```

## Reference

* https://fabianlee.org/2021/11/12/ansible-extracting-a-list-or-dictionary-from-a-complex-data-structure/
