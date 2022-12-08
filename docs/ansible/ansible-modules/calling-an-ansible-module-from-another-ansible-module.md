
# Calling an Ansible Module from another Ansible Module

## Context

I have been working with Cisco UCS via Python (ucsmsdk) and Ansible to create a means of automating service profile templates (SPTs from now on). I have created [apis](https://github.com/de-crob/ucsm_apis) and [modules](https://github.com/de-crob/ucsm-ansible) conforming to the standards set in the respective Git repos.

While I am able to create these SPTs with an Ansible playbook, it requires a lot of reused properties to create each individual item and follow their long chains of parent/child relationships. I would like to remove all this reuse and simplify the creation of the items by feeding all the parameters I need to do this in one go with their structure in tact.

The example below shows the current system to what I would like.

### Current

```python
tasks:
- name: create ls server
  ls_server_module:
    name: ex
    other_args:
    creds: 
- name: create VNIC Ether
  vnic_ether_module:
    name: ex_child
    parent: ex
    other_args: 
    creds: 
- name: create VNIC Ether If (VLAN)
  vnic_ether_if_module:
    name: ex_child_child
    parent: ex_child
    creds: 
- name: create VNIC Ether
  vnic_ether_module:
    name: ex_child_2
    parent: ex
    other_args: 
    creds: 
```

### Desired

```python
tasks:
- name: create template
  spt_module:
    name: ex
    other_args:
    creds: 
    LAN:
      VNIC:
      - name: ex_child
        other_args:
        vlans:
        - ex_child_child
      - name: ex_child_2
        other_args:
```

Currently, my only barrier is inducing some code reuse by calling these modules that create the object in a dynamic and programmatic way.

## Solution

You can't execute a module from within other module, because modules in Ansible are self-contained entities, that are packaged on the controller and delivered to remote host for execution.

But there are action plugins for this situations. You can create action plugin `spt_module` (it will be executed locally on Ansible controller) that can in turn execute several different modules, based on `lan/vnic` parameters.

This is how your action (`spt_module.py`) plugin may look like (very simplified):

```
from ansible.plugins.action import ActionBase

class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):

        result = super(ActionModule, self).run(tmp, task_vars)

        vnic_list = self._task.args['LAN']['VNIC']
        common_args = {}
        common_args['name'] = self._task.args['name']

        res = {}
        res['create_server'] = self._execute_module(module_name='ls_server_module', module_args=common_args, task_vars=task_vars, tmp=tmp)
        for vnic in vnic_list:
          module_args = common_args.copy()
          module_args['other_args'] = vnic['other_args']
          res['vnic_'+vnic['name']] = self._execute_module(module_name='vnic_ether_module', module_args=module_args, task_vars=task_vars, tmp=tmp)
        return res
```

_Code is not tested (bugs, typos possible)._

## Reference

* [Stack Overflow - Calling an Ansible Module from another Ansible Module](https://stackoverflow.com/questions/46893066/calling-an-ansible-module-from-another-ansible-module)
* 