
# Example 6: Using group_by key groups with ansible_group_priority

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


### AWX Testing - same results

Running this test case example in AWX for both hosts.ini and hosts.yml yields the same results.  

* [AWX Example 6 Playbook using hosts.ini test results](./example6/awx_job_results.hosts-ini.txt)
* [AWX Example 6 Playbook using hosts.yml test results](./example6/awx_job_results.hosts-yml.txt)


### TODO 
Need to understand why group_by works for the INI but does not work for the YAML based inventory.

The variable set method [set_variable used in the group.py source](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/inventory/group.py#L244) uses the [util method combine_vars](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/utils/vars.py#L81). 

In turn, the combine_vars method uses the method [merge_hash](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/utils/vars.py#L96).

Best guess is that when using the YAML inventory, the [merge hash method used by group.py ](https://github.com/ansible/ansible/blob/97e574fe6ea7a73ef8e42140e8be32c8cdbcaece/lib/ansible/inventory/group.py#L116) cannot properly resolve the group based on the parent-child group ancestry.   Whereas in the case of the INI inventory, the merge_hash succeeds.

## Conclusions

In conclusion, from the testing done, the variable merge path behavior is consistent when using ansible_group_priority with child groups with 1 exception noted.

The exception occurs when using ansible group_by and key child groups with the YAML inventory noted in [Example 6](#Example-06).

If the use case involving ansible group_by and key child groups is desired and/or essential to your group variable method of use, then it is essential to use the INI inventory and avoid using the YAML inventory plugin for those specific cases until the inconsistent behavior is resolved by the ansible dev team. 

