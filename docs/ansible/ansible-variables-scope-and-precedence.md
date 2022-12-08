
# Ansible: Variables scope and precedence

## Introduction

Variable scoping can be quite complicated on Ansible and it’s important to know what variable your playbook is going to be using. But sometimes it’s not as easy as it may appear. The documentation on [Ansible’s website](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable "https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable") explains this but I’d like to run you through a scenario we found where this is not what you would expect it to be.

Recently while working on a deployment where we had the same role applied to a group of servers twice with different configurations we found it wasn’t working for us. We did a bit of investigation and we found that some of the variable precedence was not behaving as we were expecting it to be.

[https://docs.ansible.com/ansible/latest/user\_guide/playbooks\_variables.html#ansible-variable-precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#ansible-variable-precedence "https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#ansible-variable-precedence")

The scenarios below demonstrate the problem on tests 4 and 5.

## Test framework

I’m going to use a simple playbook with a single role which prints a variable content to the screen.

```
.
├── main.yml
└── roles
    └── my-role
        ├── defaults
        │   └── main.yml
        └── tasks
            └── main.yml

4 directories, 3 files
```

The contents of main.yml for the role is

```
---
- debug:
    var: day_of_the_week
```

and defaults/main.yml has

```
---
day_of_the_week: Thursday
```

### Test 1: Load the role

#### Playbook

```
- hosts: all
  roles:
    - name: my-role
```

**Result**: Thursday  
**Explanation**: It simply takes the default value from the role

### Test 2: Override the default with a new value

```
- hosts: all
  vars:
    day_of_the_week: Monday
  roles:
    - name: my-role
```

**Result**: Monday  
**Explanation**: New value displayed as expected

### Test 3: Override variable from within the role

```
- hosts: all
  roles:
    - name: my-role
      vars:
        day_of_the_week: Monday
```

**Result**: Monday  
**Explanation**: New value displayed as expected

### Test 4: Load the role twice and change the default value for one of them

```
- hosts: all
  roles:
    - name: my-role
      vars:
        day_of_the_week: Monday
    - name: my-role
```

**Result**: Monday is displayed twice, one for each role  
**Explanation**: This is an unexpected result. You would have thought it the result would be Thursday for the first time the role loads and Monday for the second attempt but Ansible seems to override the value.

### Test 5: Change the order of loading from Test 4

```
- hosts: all
  roles:
    - name: my-role
    - name: my-role
      vars:
        day_of_the_week: Monday
```

**Result**: Monday is displayed twice, one for each role  
**Explanation**: This is another unexpected result. Logic would dictate that the first one should be Thursday and Monday for the second attempt. The order in which the roles are defined does not affect the result.

### Test 6: Override value for both roles

```
- hosts: all
  roles:
    - name: my-role
      vars:
        day_of_the_week: Monday
    - name: my-role
      vars:
        day_of_the_week: Tuesday
```

**Result**: Monday and Tuesday  
**Explanation**: This is exactly what you would expect as you’re changing the default value.

### Test 7: Set global variable and override on role

```
- hosts: all
  vars:
    day_of_the_week: Friday
  roles:
    - name: my-role
    - name: my-role
      vars:
        day_of_the_week: Tuesday
```

**Result**: Tuesday on both output  
**Explanation**: This is yet another unexpected result similar to tests 4 and 5. The local variable set for a single role seems to override the whole playbook.

### Test 8: Override variable from command line

```
- hosts: all
  vars:
    day_of_the_week: Friday
  roles:
    - name: my-role
    - name: my-role
      vars:
        day_of_the_week: Tuesday
```

and we’re running the playbook using

```
ansible-playbook -i localhost, 
  --connection=local 
  -v main.yml 
  -e day_of_the_week=Yesterday
```

**Result**: Yesterday  
**Explanation**: Ansible documentation states that the command line has the highest precedence and it stands to reason that all the other variables are ignored.

### Test 9: Change variable with set\_fact

```
- hosts: all
  vars:
    day_of_the_week: Friday
  pre_tasks:
    - set_fact:
        day_of_the_week: Wednesday
  roles:
    - name: my-role
      vars:
        day_of_the_week: Monday
    - name: my-role
      vars:
        day_of_the_week: Tuesday
```

**Result**: Wednesday for both roles  
**Explanation**: This is expected as set\_fact has precedence over roles.

### Test 10: Import variable from files

The day\_of\_the\_week variable is move into two files, one defines Wednesday and loaded first and the other one sets the value of Friday and it’s loaded last

```
- hosts: all
  vars_files:
    - wed.yml
    - fri.yml
  roles:
    - name: my-role
```

**Result**: Friday  
**Explanation**: This is expected. The last value overrides the first one.

## Reference

- https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html
- https://digitalis.io/blog/ansible/ansible-variables-scope-and-precedence/
