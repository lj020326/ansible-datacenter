
# Ansible: Modules and Action Plugins

## The Problem

After some time spent writing Ansible playbooks, one often discovers repetitive patterns of actions that she would like to extract in a single function in order to stay DRY and increase readability.

For instance, my team has a frequent need to backup files and directories before applying any modifications to some machines. Those machines are legacy ones that have been setup a long time ago and cannot be treated as [phoenix servers](http://martinfowler.com/bliki/PhoenixServer.html). We decided nonetheless to code some operations for them with Ansible, but we take extra care to ensure that every error is detected as soon as it occurs and that the modification is immediately rolled back. And in any case, all sensitive bits of these machines are backed up before touching them.

That last part translates to the following sequence of actions (which translates into 6 Ansible actions):

-   feed a timestamp variable
-   if the path to backup is a folder, make a tarsal
-   copy the file to backup to `/.bckp.`
-   create or replace a symbolic link from the parent directory of the original file to the latest backup (to advertise the backup and make it easy to restore it)

After some playbooks had been written that way, my team got tired of those verbose sequences of actions, and we searched for a way to write them in a simpler and readable way. The natural solution seemed to write our own module.

Modules are single scripts that will be deployed on target hosts. Custom modules must be placed in some folder present in the `ANSIBLE_LIBRARY` path variable, or alongside playbook under `./library`. Module files must be executable and they must be given the name one want to use to call them (thus, without extension). They are then used in the same way as standard modules:

```
- name: do something with my module
  mymodule: foo=bar
```

Here is the structure of a simple backup module (`./library/backup`), using [Ansible Python API](http://docs.ansible.com/developing_modules.html):

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

# [..] various imports

# this line must be written exactly that way,
# as Ansible will replace it with the "imported" code
from ansible.module_utils.basic import *


# [..] implementation code omitted

# simplified, flat version of the actual code
if __name__ == '__main__':
    global module
    module = AnsibleModule(
        argument_spec={
            'backup_dir': { 'required': True, 'type': 'str' },
            'path': { 'required': True, 'type': 'str' }
        },
        supports_check_mode=False
    )

    args = module.params
    # [..] check for early return reasons

    orig_file = _normalize_dirpath(args['path'])        
    backup_dir = _normalize_dirpath(args['backup_dir'])
    timestamp = create_timestamp()
    backup_file = create_backup_filename(backup_dir, orig_file, timestamp)

    result = do_the_magic(orig_file, backup_file)
    module.exit_json(**result)
```

The previous module can be used as follows:

```yaml
- name: backup /etc/default
  backup: path=/etc/default backup_dir=/var/backups
  # results in the file /var/backups/etc/default.tar.gz.bckp.20150120082832
```

That’s already a big improvement:

-   We reduced 6 actions into one.
-   The result is far more readable.

But:

-   One still have to specify the backup directory for each execution of the module.
-   We would like to share the same timestamp for all executions of the module within the same playbook run.

A solution would be to define the backup directory as a variable, and to have the module read this variable. Similarly, the module could write the generated timestamp into a variable that it would read upon further executions.  
Unfortunately, modules can’t read or write variables. All they can access is the facts of the target machine they are executed on. That led us to action plugins.

## Action Plugins

As explained on [Ansible’s Google Group](https://groups.google.com/forum/#!searchin/ansible-project/action$20plugin$20vs$20module/ansible-project/wNSJ4g-f4F8/xlpijLcRNSUJ): “action\_plugins are a special type of module, or a compliment to existing modules. action\_plugins get run on the ‘master’ instead of on the target, for modules like file/copy/template, some of the work needs to be done on the master before it executes things on the target. The action plugin executes first and can then execute (or not) the normal module”.  
For instance, the [copy action plugin](https://github.com/ansible/ansible/blob/stable-1.9/lib/ansible/runner/action_plugins/copy.py) calls (`_execute_module`) the [copy module](https://github.com/ansible/ansible-modules-core/blob/stable-1.9/files/copy.py).

Custom action plugins must be placed under the [configured `action_plugins` path](http://docs.ansible.com/intro_configuration.html#action-plugins), or alongside playbooks under `./action_plugins`.

Then they can be called as follows:

```yaml
- name: do something with my action
  action: myaction foo=bar
```

Or, if a file with the same name — even an empty one — is placed in the module path (see previous section) they can be called as a module:

```yaml
- name: do something with my action
  myaction: foo=bar
```

As said above, action\_plugins are executed on the “master”, so they are part of the playbook run and can see existing variables or create new variables:

```python
from ansible.utils import template
from ansible.runner.return_data import ReturnData


# must be named ActionModule or it won't be seen by Ansible
class ActionModule(object):

    TRANSFERS_FILES = False

    def __init__(self, runner):
        self.runner = runner
        self.basedir = runner.basedir

    def run(self, conn, tmp, module_name, module_args, inject, complex_args=None, **kwargs):
        value = template.template(self.basedir, '{{ some_var }}', inject)

        return ReturnData(conn=conn, result=dict(
            changed=True,
            some_new_var=value
        ))
```

So now we have a way to work on the target machine but without seeing variables, and a way to see variables but on the orchestration machine only. To solve our problem, we will have to combine those two.

## A Solution Tying Them Together

Here is the trick: as quoted in the previous section, an action plugin and a module can have the same name, in which case the action plugin will be executed rather than the plugin, but since an action plugin can execute a module, we can write an action plugin that will call its module counterpart.

Here is a working example.

In the module (`./library/backup`), all parameters are required:

```python
# ... same as previous version

module = AnsibleModule(
    argument_spec={
        'backup_dir': { 'required': True, 'type': 'str' },
        'path': { 'required': True, 'type': 'str' },
        'timestamp': { 'required': True, 'type': 'str' }
    },
    supports_check_mode=False
)

# ... same as previous version
```

But the action plugin (`./action_plugins/backup.py`) will attempt to provide default values from variables:

```python
from ansible.utils import template
from ansible.runner.return_data import ReturnData


# [..] some code skipped


# must be named ActionModule or it won't be seen by Ansible
class ActionModule(object):

    # [..] some code skipped

    def _arg_or_fact(self, arg_name, fact_name, args, inject):
        res = args.get(arg_name)
        if res is not None:
            return res

        template_string = '{{ %s }}' % fact_name
        res = template.template(self.basedir, template_string, inject)
        return None if res == template_string else res

    # [..] some code skipped

    def run(self, conn, tmp, module_name, module_args, inject, complex_args=None, **kwargs):
        args = self._merge_args(module_args, complex_args)

        path = args.get('path')
        # retrieve backup_dir from args or variable
        backup_dir = self._arg_or_fact('backup_dir', 'deployment_backup_dir', args, inject)
        if not backup_dir:
            return ReturnData(conn=conn, result=dict(
                failed=True,
                msg="Please define either backup_dir parameter or deployment_backup_dir variable"
            ))

        # retrieve timestamp generated by a previous execution, or generate a new one
        timestamp_generated, timestamp = False, self._arg_or_fact('timestamp', 'deployment_backup_timestamp', args, inject)
        if not timestamp:
            timestamp_generated, timestamp = True, _generate_timestamp()

        # now that all parameters are known, we can call the module
        module_args_tmp = "path=%s backup_dir=%s timestamp=%s" % (args.get('path'), backup_dir, timestamp)
        module_return = self.runner._execute_module(conn, tmp, 'backup', module_args_tmp, inject=inject,
                                                complex_args=complex_args, persist_files=True)

        # register generated timestamp for next executions
        if timestamp_generated:
            facts = module_return.result.get('ansible_facts', {})
            if not facts:
                module_return.result['ansible_facts'] = facts
            facts['deployment_backup_timestamp'] = timestamp

        return module_return
```

This implementation allows for the following use cases:

```yaml
# assuming  has been set to /var/backups

- backup: path=/etc/default    # folder -> .tar.gz
  # results in the file /var/backups/etc/default.tar.gz.bckp.20150120082832

- backup: path=/etc/hosts    # simple file
  # results in the file /var/backups/etc/hosts.bckp.20150120082832 (same timestamp)

- backup: path=/etc/network/interfaces backup_dir=/tmp    # different backup_dir
  # results in the file /tmp/etc/network/interfaces.bckp.20150120082832 (same timestamp)

- backup: path=/etc/passwd timestamp=foobar    # timestamp is provided
  # results in the file /var/backups/etc/passwd.bckp.foobar
```

The complete implementation can be found on [Github](https://github.com/lj020326/ansible-backup-module).

## Reference

- [ansible-modules-and-action-plugins](http://ndemengel.github.io/2015/01/20/ansible-modules-and-action-plugins/)
- 