
# Implicit localhost and python discovery with Ansible 2.12

I recently upgraded to Ansible 2.12 and a couple of my playbooks stopped working. This seems to be down to a change in python discovery and if you have made the same mistakes as me, you’ll hit a similar issue. I thought I would write up my findings in case it helps anyone else.

**HINT** you’ve probably got an entry for localhost in your inventory!!

## Everything was working in Ansible 2.11

I was using Ansible 2.11 in an [execution environment](https://docs.ansible.com/automation-controller/latest/html/userguide/execution_environments.html) and my playbook was happily working. Here is one of the tasks in my playbook which gives us a nice simple example to reproduce the problem.

```yaml
---

- hosts: localhost
  connection: local
  gather_facts: false
  tasks:
  - name: print ansible version
    debug:
      var: ansible_version.full

  - name: find vmware datastore name
    community.vmware.vmware_datastore_info:
      cluster: rhatnode1
      hostname: vcenter7.demolab.local
      username: administrator@vsphere.local
      password: Redhat123
      validate_certs: no
    register: datastore
```

In my case I had an inventory that contained a **localhost** entry. Why did my inventory have a localhost entry? Who knows, but i’ve been managing this infrastructure for about 4 years now and at some point it got added in there. For simple testing this is all we need to reproduce the error:

```shell
$ cat inventory
localhost
```

If we run the playbook with the Ansible 2.11 execution environment then it should work fine. Note that I am including the inventory file in my command.

```shell
$ ansible-navigator run find_vmware_datastore.yml --eei registry.redhat.io/ansible-automation-platform-20-early-access/ee-supported-rhel8:latest  -m stdout -i inventory

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.11.6"
}

TASK [find vmware datastore name] *******************************************************************************************************************************************
[DEPRECATION WARNING]: Distribution rhel 8.5 on host localhost should use /usr/libexec/platform-python, but is using /usr/bin/python for backward compatibility with prior 
Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-
core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by 
setting deprecation_warnings=False in ansible.cfg.
ok: [localhost]

PLAY RECAP ******************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Something changed in Ansible 2.12

I know! It was warning me all along - if only I took notice of it. Anyway, I decided to switch up to Ansible 2.12 and started hitting some issues with the same task:

**Note the change of EE container image in the below command. This newer container image contains ansible-core 2.12.**

```shell
ansible-navigator run find_vmware_datastore.yml --eei registry.redhat.io/ansible-automation-platform-21/ee-supported-rhel8:latest -m stdout -i inventory

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.12.1"
}

TASK [find vmware datastore name] *******************************************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: ModuleNotFoundError: No module named 'requests'
fatal: [localhost]: FAILED! => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"}, "changed": false, "msg": "Failed to import the required Python library (requests) on 6f19163abcf6's Python /usr/libexec/platform-python. Please read the module documentation and install it in the appropriate location. If the required library is installed, but Ansible is using the wrong Python interpreter, please consult the documentation on ansible_python_interpreter"}

PLAY RECAP ******************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

The playbook stopped working!

## What changed?

As per the warning in Ansible 2.11 and the [docs](https://docs.ansible.com/ansible/latest/reference_appendices/interpreter_discovery.html), Ansible 2.12 changed the default python discovery to **auto**:

“Detects the target OS platform, distribution, and version, then consults a table listing the correct Python interpreter and path for each platform/distribution/version. If an entry is found, uses the discovered interpreter.”

So something has messed up the way that I am discovering python within my execution environment and this is causing me to locate the wrong python interpreter. In this instance it is finding **/usr/libexec/platform-python** and then fails to import the necessary python libraries to execute the VMware modules - **Failed to import the required Python library (requests) on 6f19163abcf6’s Python /usr/libexec/platform-python**.

The previous discovery method used **auto\_legacy** - let’s see if that works with Ansible 2.12:

```shell
ansible-navigator run find_vmware_datastore.yml --eei registry.redhat.io/ansible-automation-platform-21/ee-supported-rhel8:latest -m stdout -i inventory -e "ansible_python_interpreter=auto_legacy"

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.12.1"
}

TASK [find vmware datastore name] *******************************************************************************************************************************************
[WARNING]: Distribution rhel 8.5 on host localhost should use /usr/libexec/platform-python, but is using /usr/bin/python for backward compatibility with prior Ansible
releases. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information
ok: [localhost]

PLAY RECAP ******************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

It does. But why do I need to make these changes?

I next stumbled upon the implicit localhost documentation. I’ve been using Ansible for a number of years now and this has completely bypassed me. From the [docs](https://docs.ansible.com/ansible/latest/inventory/implicit_localhost.html) - “When you try to reference a localhost and you don’t have it defined in inventory, Ansible will create an implicit one for you”.

Again from the docs, it will create a host entry which is equivalent to this:

```yaml
...

hosts:
  localhost:
   vars:
     ansible_connection: local
     ansible_python_interpreter: "{{ansible_playbook_python}}"
```

Importantly, this is setting the correct ansible\_python\_interpreter for us.

Back to they key point for me (again from the docs) - “You can override the built-in implicit version by creating a localhost host entry in your inventory. At that point, all implicit behaviors are ignored”.

Once again, why did I have a localhost entry in my inventory? Absolutely no idea! But, this was what was causing my issues.

## Running the playbook without localhost in the inventory

Now re-running the playbook without specifying the inventory gives the correct behaviour. Ansible is now creating the correct implicit localhost entry and the playbook completes as expected.

```shell
ansible-navigator run find_vmware_datastore.yml --eei registry.redhat.io/ansible-automation-platform-21/ee-supported-rhel8:latest -m stdout
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.12.1"
}

TASK [find vmware datastore name] *******************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ******************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## One more example to highlight the issue

Just a final point to try to highlight what was happening here. This playbook will just print the hostvars for my localhost.

```yaml
---

- hosts: localhost
  gather_facts: false
  tasks:
  - name: print ansible version
    debug:
      var: ansible_version.full
     
  - name: print localhost hostvars
    debug:
      msg: "{{ hostvars['localhost'] }}"
```

With an inventory file containing a **localhost** entry:

```shell
ansible-navigator run show_localhost_vars.yml --eei registry.redhat.io/ansible-automation-platform-21/ee-supported-rhel8:latest -m stdout -i inventory

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.12.1"
}

TASK [print localhost hostvars] *********************************************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "ansible_check_mode": false,
        "ansible_config_file": "/etc/ansible/ansible.cfg",
        "ansible_diff_mode": false,
        "ansible_facts": {},
        "ansible_forks": 5,
        "ansible_inventory_sources": [
            "/tmp/inventory"
        ],
        "ansible_playbook_python": "/usr/bin/python3.8",

   < Output Truncated>
```

Note that we don’t have a variable set for **ansible\_python\_interpreter**.

Running it again without an inventory containing localhost allows Ansible to create the entry for us:

```shell
ansible-navigator run show_localhost_vars.yml --eei registry.redhat.io/ansible-automation-platform-21/ee-supported-rhel8:latest -m stdout 

PLAY [localhost] ************************************************************************************************************************************************************

TASK [print ansible version] ************************************************************************************************************************************************
ok: [localhost] => {
    "ansible_version.full": "2.12.1"
}

TASK [print localhost hostvars] *********************************************************************************************************************************************
ok: [localhost] => {
    "msg": {
        "ansible_check_mode": false,
        "ansible_config_file": "/etc/ansible/ansible.cfg",
        "ansible_connection": "local",
        "ansible_diff_mode": false,
        "ansible_facts": {},
        "ansible_forks": 5,
        "ansible_inventory_sources": [
            "/etc/ansible/hosts"
        ],
        "ansible_playbook_python": "/usr/bin/python3.8",
        "ansible_python_interpreter": "/usr/bin/python3.8",
```

Now we have the correct **ansible\_python\_interpreter** set.

## Summary

A combination of things caused a change in behaviour in my ansible playbook:

-   Ansible 2.12 now uses auto as the default discovery method for python interpreter.
-   I had a localhost entry in my inventory.

In my case, I just removed localhost from my inventory file. In [Automation Controller](https://www.ansible.com/products/controller) I removed it from the inventory there. If for some reason you need a localhost entry in your inventory, be prepared to set some additional variables to mimic the behaviour of implicit localhost.

#### See also

- https://cloudautomation.pharriso.co.uk/post/implicit_localhost/  
- [Using the ServiceNow Ansible Spoke](https://cloudautomation.pharriso.co.uk/post/aap_snow_spoke/)
- [ansible-builder in a disconnected environment](https://cloudautomation.pharriso.co.uk/post/ansible-builder-disconnected/)
- [Using Molecule for VM provisioning roles](https://cloudautomation.pharriso.co.uk/post/molecule-vm-create/)
- [Testing Ansible roles with Molecule and VMware](https://cloudautomation.pharriso.co.uk/post/vmware-molecule/)
- [Filtering hosts with the Satellite inventory plugin for Ansible](https://cloudautomation.pharriso.co.uk/post/foreman_filtering/)

