
# Parse yaml files in Ansible

I have got multiple yaml files on remote machine. I would like to parse those files in order to get information about names for each kind (Deployment, Configmap, Secret) of object, For example:

```yaml
...
kind: Deployment
metadata:
  name: pr1-dep
...
```

```yaml
kind: Secret
metadata:
  name: pr1
...
```

```yaml
....
kind: ConfigMap
metadata:
  name: cm-pr1
....
```

Expected result: 3 variables:

-   deployments = [pr1-dep]
-   secrets = [pr1]
-   configmaps = [cm-pr1]

I started with:

```
- shell: cat "{{ item.desc }}"
with_items:
  - "{{ templating_register.results }}"
register: objs
```

Need idea how to correctly parse `item.stdout` from objs.

## Solution 1

Ansible has a `from_yaml` filter that takes YAML text as input and outputs an Ansible data structure. So for example you can write something like this:

```
- hosts: localhost
  gather_facts: false
  tasks:
    - name: Read objects
      command: "cat {{ item }}"
      register: objs
      loop:
        - deployment.yaml
        - configmap.yaml
        - secret.yaml

    - debug:
        msg:
          - "kind: {{ obj.kind }}"
          - "name: {{ obj.metadata.name }}"
      vars:
        obj: "{{ item.stdout | from_yaml }}"
      loop: "{{ objs.results }}"
      loop_control:
        label: "{{ item.item }}"
```

Given your example files, this playbook would output:

```
PLAY [localhost] ***************************************************************

TASK [Read objects] ************************************************************
changed: [localhost] => (item=deployment.yaml)
changed: [localhost] => (item=configmap.yaml)
changed: [localhost] => (item=secret.yaml)

TASK [debug] *******************************************************************
ok: [localhost] => (item=deployment.yaml) => {
    "msg": [
        "kind: Deployment",
        "name: pr1-dep"
    ]
}
ok: [localhost] => (item=configmap.yaml) => {
    "msg": [
        "kind: ConfigMap",
        "name: pr1-cm"
    ]
}
ok: [localhost] => (item=secret.yaml) => {
    "msg": [
        "kind: Secret",
        "name: pr1"
    ]
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

___

Creating the variables you've asked for is a little trickier. Here's one option:

```
- hosts: localhost
  gather_facts: false
  tasks:
    - name: Read objects
      command: "cat {{ item }}"
      register: objs
      loop:
        - deployment.yaml
        - configmap.yaml
        - secret.yaml

    - name: Create variables
      set_fact:
        names: >-
          {{
            names|combine({
              obj.kind.lower(): [obj.metadata.name]
            }, list_merge='append')
          }}
      vars:
        names: {}
        obj: "{{ item.stdout | from_yaml }}"
      loop: "{{ objs.results }}"
      loop_control:
        label: "{{ item.item }}"

    - debug:
        var: names
```

This creates a single variable named `names` that at the end of the playbook will contain:

```
{
    "configmap": [
        "pr1-cm"
    ],
    "deployment": [
        "pr1-dep"
    ],
    "secret": [
        "pr1"
    ]
}
```

The key to the above playbook is our use of the [`combine`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#combining-hashes-dictionaries) filter, which can be used to merge dictionaries and, when we add `list_merge='append'`, handles keys that resolve to lists by appending to the existing list, rather than replacing the existing key.

## Solution 2

Include the dictionaries from the files into the new variables, e.g.

```yaml
    - include_vars:
        file: "{{ item }}"
        name: "objs_{{ item|splitext|first }}"
      register: result
      loop:
        - deployment.yaml
        - configmap.yaml
        - secret.yaml
```

This will create dictionaries _objs\_deployment_, _objs\_configmap_, and _objs\_secret_. Next, you can either use the dictionaries

```yaml
    - set_fact:
        objs: "{{ objs|d({})|combine({_key: _val}) }}"
      loop: "{{ query('varnames', 'objs_') }}"
      vars:
        _obj: "{{ lookup('vars', item) }}"
        _key: "{{ _obj.kind }}"
        _val: "{{ _obj.metadata.name }}"
```

, or the registered data

```yaml
    - set_fact:
        objs: "{{ dict(_keys|zip(_vals)) }}"
      vars:
        _query1: '[].ansible_facts.*.kind'
        _keys: "{{ result.results|json_query(_query1)|flatten }}"
        _query2: '[].ansible_facts.*.metadata[].name'
        _vals: "{{ result.results|json_query(_query2)|flatten }}"
```

Both options give

```yaml
  objs:
    ConfigMap: cm-pr1
    Deployment: pr1-dep
    Secret: pr1
```

## References

* https://stackoverflow.com/questions/68217313/parse-yaml-files-in-ansible
* 
