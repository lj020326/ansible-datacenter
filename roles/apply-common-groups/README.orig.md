
# Role apply-common-groups

The role will place derive common groups used throughout ansible plays.

Example usage:
```shell
- name: "Gather facts for all hosts to apply OS specific group vars for them"
  tags: always
  hosts: all,!local,!node_offline
  ignore_unreachable: yes
  gather_facts: yes
  vars_files:
    - vars/vault.yml
  roles:
    - role: apply-common-groups

```

