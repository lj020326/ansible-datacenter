
# Variable Merge Precedence in Group Vars

## Motivation

### Simple Merge Example

Suppose you have three files in `group_vars`:

```
abc.yml
all.yml
xyz.yml
```

And the same variable is defined in each of them:

```yaml file=group_vars/abc.yml
my_var: abc
```

```yaml file=group_vars/all.yml
my_var: all
```

```yaml file=group_vars/xyz.yml
my_var: xyz
```

According to the [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html):

> Within any section, redefining a var will overwrite the previous instance. If multiple groups have the same variable, the last one loaded wins. If you define a variable twice in a play’s vars: section, the 2nd one wins.

### Group Depth

Consider the following example inventory file `hosts.ini`:

```ini
[bots-a]
bot1

[bots-b]
bot2

[bots:children]
bots-a
bots-b
```

With group variables defined in:

- `./group_vars/bots.yml`
- `./group_vars/bots-a.yml`
- `./group_vars/bots-b.yml`

Ansible has a concept of group depth. For host `bot2`, the group variables will be populated in this order:

1. Depth 0: Group `all`, `all.yml` (missing here, ignoring)
2. Depth 1: Group `bots`, `bots.yml`
3. Depth 2: Group `bots-b`, `bots-b.yml`

For details on host group vars processing order and the combine_vars utility function, refer to the [Ansible source code](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/plugins/vars/host_group_vars.py#L72) and the [combine_vars utility function](https://github.com/ansible/ansible/blob/stable-2.13/lib/ansible/utils/vars.py#L81).

If you define defaults in `bots.yml` and specific values in `bots-b.yml`, you should achieve the expected behavior.

### Special Group Variable: `ansible_group_priority`

Starting with Ansible version 2.4, users can use the group variable `ansible_group_priority` to change the merge order for groups of the same level after resolving parent/child relationships.

When groups of the same parent/child level are merged, it is done alphabetically, and the last group loaded overwrites previous ones. For example, variables in `a_group` will be overwritten by those in `b_group`.

Starting with Ansible version 2.4, users can use `ansible_group_priority` to change this order. The larger the number, the later it is merged, giving higher priority. This variable defaults to 1 if not set.

**Example:**

```yaml
a_group:
    testvar: a
    ansible_group_priority: 10

b_group:
    testvar: b
```

In this example, `testvar` would normally be `b`, but with the higher priority for `a_group`, it will be `a`.

> **Note:**  
> `ansible_group_priority` can only be set in the inventory source and not in `group_vars/`, as it is used during the loading of `group_vars`.

## Example Use Cases Covered

The following examples demonstrate how to leverage child group variables, especially with respect to variable merging behavior:

- [Example 1: Test with child groups having same depth](./example1/README.md)
- [Example 2: Unset variable 'test' from the initial 'cluster' group to validate if expected result occurs](./example2/README.md)
- [Example 3: Validate prioritization with child groups having different depths](./example3/README.md)
- [Example 4: Validate prioritization with child groups](./example4/README.md)
- [Example 5: Playbook using inventory](./example5/README.md)
- [Example 6: Using group_by key groups with ansible_group_priority](./example6/README.md)

The Ansible environment used for these examples:

```bash
$ git clone https://github.com/lj020326/ansible-inventory-file-examples.git
$ cd ansible-inventory-file-examples
$ git switch develop-lj
$ cd tests/ansible-group-priority
$ ansible --version
```

**Output:**

```
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

## Backlinks

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Group Vars](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables)
