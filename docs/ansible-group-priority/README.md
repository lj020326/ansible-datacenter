
# Variable merge precedence in group vars

## Motivation

### Simple Merge Example

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

### Group Depth

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


### Special group variable 'ansible_group_priority'

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


## Example Use Cases Covered

The purpose of the following examples is to understand how to leverage child group vars especially with respect to deriving the expected behavior for variable merging. 
The examples will explore common group prioritization use cases:

* [Example 1: Test with child groups having same depth](./example1/README.md)

* [Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs](./example2/README.md)

* [Example 3: Validate prioritization with child groups having different depths](./example3/README.md)

* [Example 4: Validate prioritization with child groups](./example4/README.md)

* [Example 5: playbook using inventory](./example5/README.md)

* [Example 6: Using group_by key groups with ansible_group_priority](./example6/README.md)

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

