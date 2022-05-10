
Variable merge precedence in group vars
===

Say you have 3 files in group_vars:

```
abc.yml
all.yml
xyz.yml
```

And the same variable is defined in each of them:

```
- my_var: abc
- my_var: all
- my_var: xyz
```

Ansible [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html) says:

> Within any section, redefining a var will overwrite the previous instance. If multiple groups have the same variable, the last one loaded wins. If you define a variable twice in a play’s vars: section, the 2nd one wins.

## Group Depth

Take the following example inventory hosts.ini:

```ini
[bots-a]
bot1

[bots-b]
bot2

[bots:children]
bots-a
bots-b

```

With group vars defined in:

```output
./group_vars/bots.yml
./group_vars/bots-a.yml
./group_vars/bots-b.yml
```

There is a concept of group depth in Ansible (at least in recent versions). In this example, group variables for host `bot2` will be populated in the following order:

depth 0: group `all`, `all.yml` (missing here, ignoring)  
depth 1: group `bots`, `bots.yml`  
depth 2: group `bots-b`, `bots-b.yml`

You can see details for the [host group vars processing order](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/plugins/vars/host_group_vars.py#L72) and the [combine_vars utility function it uses](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/utils/vars.py#L81) in the source code.

So if you define defaults in `bots.yml` and specific values in `bots-b.yml`, you should achieve what you expect.


## Special group variable 'ansible_group_priority'

Starting in Ansible version 2.4, users can use the group variable ansible_group_priority to change the merge order for groups of the same level (after the parent/child order is resolved).

When groups of the same parent/child level are merged, it is done alphabetically, and the last group loaded overwrites the previous groups. For example, an a_group will be merged with b_group and b_group vars that match will overwrite the ones in a_group.

Starting in Ansible version 2.4, users can use the group variable ansible_group_priority to change the merge order for groups of the same level (after the parent/child order is resolved). The larger the number, the later it will be merged, giving it higher priority. This variable defaults to 1 if not set. For example:

```yaml
a_group:
    testvar: a
    ansible_group_priority: 10
b_group
    testvar: b
```

In this example, if both groups have the same priority, the result would normally have been testvar == b, but since we are giving the a_group a higher priority the result will be testvar == a.

> Note:
> `ansible_group_priority` can only be set in the inventory source and not in 'group_vars/', as the variable is used in the loading of 'group_vars'.

## INI and YAML Inventory Examples

The remaining sections will explore the following common child group prioritization example use cases:

* [Example 1: Test with child groups having same depth](#Example-01)

* [Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs](#Example-02)

* [Example 3: Validate prioritization with child groups having different depths](#Example-03)

* [Example 4: Validate prioritization with child groups](#Example-04)

* [Example 5: playbook using inventory](#Example-05)

* [Example 6: Using group_by key groups with ansible_group_priority](#Example-06)

The purpose here is to fully understand how to leverage child group vars especially with respect to deriving the expected behavior for variable merging. 

The ansible environment used to perform the examples:

```output
$ git clone https://github.com/lj020326/ansible-inventory-file-examples.git
$ cd ansible-inventory-file-examples
$ git switch develop-lj
$ cd tests/ansible-group-priority
$ ansible --version
ansible [core 2.12.3]
  config file = None
  configured module search path = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/ljohnson/.pyenv/versions/3.10.2/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/ljohnson/.ansible/collections:/usr/share/ansible/collections
  executable location = /Users/ljohnson/.pyenv/versions/3.10.2/bin/ansible
  python version = 3.10.2 (main, Feb 21 2022, 15:35:10) [Clang 13.0.0 (clang-1300.0.29.30)]
  jinja version = 3.1.0
  libyaml = True
```


## <a id="Example-01"></a>Example 1: Test with child groups having same depth

One might observe what is believed to be unexpected results when `ansible_group_priority` is used in inventory inventory groups that have a parent/child relationship. 

For example, create an inventory structurally that looks like this:

```
  |--@top_group:
  |  |--@override:
  |  |  |--@cluster:
  |  |  |  |--host1
  |  |--@product:
  |  |  |--@product1:
  |  |  |  |--host1
  |  |  |--@product2:
  |  |  |  |--host2
  |--@ungrouped:
```

The inventory implementing the aforementioned hierarchy as an ini inventory [hosts.ex1.ini](./hosts.ex1.ini):

```ini
[top_group:vars]
test=top_group
ansible_connection=local
ansible_group_priority=1

[top_group:children]
product
override

[product:vars]
test="product"
ansible_group_priority=2

[product:children]
product1
product2

[product1]
host1

[product2]
host2

[product1:vars]
test="product1"
ansible_group_priority=3

[product2:vars]
test="product2"
ansible_group_priority=3

[override:vars]
test="override"
ansible_group_priority=9

[override:children]
cluster

[cluster]
host1

[cluster:vars]
test="cluster"
ansible_group_priority=10

```

Now run a simple query on the variable `test` for host1 and observe the results of the query:

```output
ansible -i hosts.ex1.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

So far so good, since the `cluster` group priority is '10'. 

The same results can be confirmed when you convert the same inventory to yaml as [hosts.ex1.yml](./hosts.ex1.yml):

```output
ansible -i hosts.ex1.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
```

## <a id="Example-02"></a>Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs

On the next test, unset `test` from `[cluster:vars]` in the ini inventory [hosts.ex2.ini](./hosts.ex2.ini):

```ini
;test="cluster"
ansible_group_priority=10
```

The expectation is that the variable set in the `override` group will win.
But it does not. Instead, `product1` wins:

```output
ansible -i hosts.ex2.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

It is not immediately intuitive why the `ansible_group_priority` does not result in the expected value.

The same results can be confirmed when you convert the same to a yaml inventory as [hosts.ex2.yml](./hosts.ex2.yml).

When querying variable `test` in [hosts.ex2.yml](./hosts.ex2.yml), the query results with the group 'product1' winning as the ini inventory example:

```output
ansible -i hosts.ex2.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```


### Groups and depth level

The group 'cluster' is below group 'override' which is directly below 'top_group' making it 3 levels below the 'all' group; in other terms, 'top_group' has a depth level of 3.

Similarly, the 'product1' group is below 'product' which is below 'top_group' making it 3 levels below the 'all' group; in other terms, 'product1' has a depth level of 3.

Viewing the parent/child hierarchy in a tree format visualizes this well:

```output
              [top_group]
                  |
        ----------------------
        |                    |
     [product]           [override]
         |                   |
    ------------       -------------
   |            |            |
[product1] [product2]    [cluster] 
   |                         |
 host1                     host1
```

## <a id="Example-03"></a>Example 3: Validate prioritization with child groups having different depths

In the next example, set the group 'override' such that it is not set at the same child 'depth' or 'level' as the 'product' group. 

Consider the following case.

Remove the parent/child relationship of '[override]' from '[top_group]' group, in the following way:

```output
    [top_group]          [override] ansible_group_prioirty=10
         |                    |
     [product]           [cluster] ansible_group_prioirty=10
         |                    |
    ------------            host1
   |            |            
[product1] [product2]  
   |
  host1 
```

As can be clearly seen above, the 'cluster' group has a depth of 2 while the 'product1' and 'product2' groups each have depths of 3.

The INI inventory implementing this hierarchy can be found in [hosts.ex3.ini](./hosts.ex2.ini) and the equivalent YAML inventory implementing this hierarchy can be found in [hosts.ex3.yml](./hosts.ex2.yml):

```yaml
all:
  children:
    override:
      vars:
        test: "override"
        ansible_group_priority: 10
      children:
        cluster1:
          vars:
            test: "cluster1"
            ansible_group_priority: 10
          hosts:
            host1: {}
    top_group:
      vars:
        test: top_group
        ansible_connection: local
      children:
        product:
          vars:
            ansible_group_priority: 1
            test: "product"
          children:
            product1:
              vars:
                test: "product1"
              hosts:
                host1:
                  host1: {}
            product2:
              vars:
                test: "product2"
              hosts:
                host2: {}
```

Now confirm that the results are as expected for the 2 equivalent inventory implementations:

```output
ansible -i hosts.ex3.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
...
...

ansible -i hosts.ex3.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "product1"
}
```

The results may not be what are expected, since the variable set in `product1` group always wins. 

Even if the priority of the 'override' group and all of its child groups were set to the highest, in this case, 10, the 'test' variable is set by the `product1` group.

The priority does not follow an intuitive merge path.  The deepest child group gets set and if multiple child group peers exist at the same depth, then the one with the greatest priority in that peer depth group will be set.  If the priority is the same among multiple groups at the greatest depth, then alphabetical sort order is used with the last in the sort group winning. 

To summarize in the case when using the ansible_group_priority variable, the child group having the greatest child depth and greatest priority within that depth will always win.

## <a id="Example-04"></a>Example 4: Validate prioritization with child groups

The next example validates the following rule observed in the prior example:

>
> the child group having the greatest child depth and greatest priority within that depth will always win.

With the inventory used in the prior example 3 as the starting point, make the groups 'override', 'product1', and 'product2' have the same depth. 

Add a group 'foo' between 'override' and 'top_group', such that 'override' is the same depth, 3 levels deep, as 'product1' and 'product2'.  
Note the 'cluster' child group now has a depth of 4, resulting in it have the greatest depth path.

The resulting yaml inventory with this hierarchy can be found in [hosts.ex4.yml](./hosts.ex4.yml):

```yaml
all:
  children:
    top_group:
      vars:
        test: top_group
        ansible_connection: local
        ansible_group_priority: 1
      children:
        foo:
          children:
            override:
              vars:
                test: "override"
                ansible_group_priority: 9
              children:
                cluster:
                  vars:
                    test: "cluster"
                    ansible_group_priority: 10
                  hosts:
                    host1: {}
        product:
          vars:
            test: "product"
            ansible_group_priority: 2
          children:
            product1:
              vars:
                test: "product1"
                ansible_group_priority: 3
              hosts:
                host1: {}
            product2:
              vars:
                test: "product2"
                ansible_group_priority: 3
              hosts:
                host2:
                  test: product2

```

The ini inventory implementing this hierarchy can be found in [hosts.ex4.ini](./hosts.ex4.ini):

```ini
[top_group:vars]
test=top_group
ansible_connection=local
ansible_group_priority=1

[top_group:children]
product
foo

[product:vars]
test="product"
ansible_group_priority=2

[product:children]
product1
product2

[product1]
host1

[product2]
host2

[product1:vars]
test="product1"
ansible_group_priority=3

[product2:vars]
test="product2"
ansible_group_priority=3

[override:vars]
test="override"
ansible_group_priority=9

[override:children]
cluster

[foo:children]
override

[cluster]
host1

[cluster:vars]
test="cluster"
ansible_group_priority=10
```

Since the 'cluster' group now has the greatest depth path, using the rule it would be expected that the 'test' variable value will be set to 'cluster'. 

In fact, the observed results are now consistent with the stated rule:

```output
ansible -i hosts.ex4.ini -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}
ansible -i hosts.ex4.yml -m debug -a var=test host1
host1 | SUCCESS => {
    "test": "cluster"
}

```

## <a id="Example-05"></a>Example 5: playbook using inventory

For the next example, use the inventory from example 4. 

Then setup the following [playbook](./example5/playbook.yml):

```yaml
- name: "Run play"
  hosts: all
  gather_facts: false
  connection: local
  tasks:
    - debug: var=test

```

Confirm that the results are as expected:

```output
ansible-playbook -i ./example5/hosts.ini ./example5/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Confirm that the results are as expected for the yaml inventory:

```output
ansible-playbook -i ./example5/hosts.yml ./example5/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Looks good since both results are as expected.

## <a id="Example-06"></a>Example 6: Using group_by key groups with ansible_group_priority

Copy the files used in the prior example for example 6.

Then modify the playbook to set the group_by key to 'cluster' for all hosts as follows:

```yaml
- name: "Run play"
  hosts: all
  gather_facts: false
  connection: local
  tasks:
    - name: Group hosts into 'cluster' group under 'override'
      group_by:
        key: "cluster"
        parents: "override"
    - debug: var=test
```

Confirm that the new value 'cluster' should now appear for the variable 'test' for both hosts.

```output
ansible-playbook -i ./example6/hosts.ini ./example6/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [Group hosts into 'cluster' group under 'override'] *****************************************************************************************************************************************************************************************************************
ok: [host1]
changed: [host2]

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "cluster"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Confirm that the results are as expected for the yaml inventory:

```output
ansible-playbook -i ./example6/hosts.yml ./example6/playbook.yml 

PLAY [Run play] **********************************************************************************************************************************************************************************************************************************************************

TASK [Group hosts into 'cluster' group under 'override'] *****************************************************************************************************************************************************************************************************************
ok: [host1]
changed: [host2]

TASK [debug] *************************************************************************************************************************************************************************************************************************************************************
ok: [host1] => {
    "test": "cluster"
}
ok: [host2] => {
    "test": "product2"
}

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
host1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
host2                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

While the INI inventory is as expected, the YAML inventory does not result as expected since the host2 did not appear with the 'test' variable set to 'cluster'.

### TODO 
Need to understand why group_by works for the INI but does not work for the YAML based inventory.

The variable set method [set_variable used in the group.py source](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/inventory/group.py#L244) uses the [util method combine_vars](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/utils/vars.py#L81). 

In turn, the combine_vars method uses the method [merge_hash](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/utils/vars.py#L96).

Best guess is that when using the YAML inventory, the [merge hash method used by group.py ](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/inventory/group.py#L116) cannot properly resolve the group based on the parent-child group ancestry.   Whereas in the case of the INI inventory, the merge_hash succeeds.

## Conclusions

In conclusion, from the testing done, the variable merge path behavior is consistent when using ansible_group_priority with child groups with 1 exception noted.

The exception occurs when using ansible group_by and key child groups with the YAML inventory noted in [Example 6](#Example-06).

If the use case involving ansible group_by and key child groups is desired and/or essential to your group variable method of use, then it is essential to use the INI inventory and avoid using the YAML inventory plugin for those specific cases until the inconsistent behavior is resolved by the ansible dev team. 


## References

* https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-variables-are-merged
* [combine_vars utility function](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/utils/vars.py#L81)
* https://github.com/ansible/ansible/blob/devel/lib/ansible/inventory/group.py
* https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/plugins/vars/host_group_vars.py
* https://stackoverflow.com/questions/38120793/ansible-group-vars-priority
* [Managing "nested" group in Ansible YAML inventory files](https://github.com/lj020326/ansible-datacenter/blob/main/docs/ansible-nested-groups-in-YAML-inventory-files.md)
* 

