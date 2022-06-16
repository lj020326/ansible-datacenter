
# Location to keep Ansible custom modules

In the following directory structure I have to create a zip of "anisble" directory. The idea is to put everything inside the ansible directory like playbook, roles, inventory details and custom modules into a zip package and its contents should not have any dependency on anything outside "ansible" directory.

```
<home>
   |<user>
       |__ansible
        |_____playbook.yml
            |_____inventory/
            |           |____myHosts
            |
            |_____library/
            |       |___my_Custom_module.py
            |_roles
            |   |____role1
            |____role2
```

I cannot use: "`/home/$USER/.ansible/plugins/modules/`" as this will make solution user specific and "`/usr/share/ansible/plugins/modules/`" is outside of the ansible directory and does need privileges(which user does not have)

**Question:**

1.  Is there any possible place were my\_custom\_module.py can be placed so it will automatically get picked by ansible while running? This must be somewhere inside "ansible" directory.
    
2.  If I do this before running the ansible playbook, it works but is there anyway to programmatically do it from ansible playbook before using the custom module ?
    
    export ANSIBLE\_LIBRARY=library/my\_custom\_module.py
    
3.  Is there anyway I can provide the path of the custom module relative to "ansible" directory ? either in any conf file or env variable ? Note that I cannot use `/etc ,/usr/ etc` . Everything had to be inside ansible directory,
    
4.  Is it even possible ?
    

asked Dec 12, 2018 at 19:27

[

![user avatar](https://i.stack.imgur.com/RNsPk.png?s=64&g=1)

](https://stackoverflow.com/users/6309601/p)

You can create a file `ansible.cfg` inside of your `ansible` directory and then set the `DEFAULT_MODULE_PATH` variable (`library`) in that file:

```
[defaults]
library = ./library
```

More info can be found in the [Ansible documentation](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings) for the Ansible configuration.

Here's what the documentation says about this setting:

> Description: Colon separated paths in which Ansible will search for Modules.
> 
> Type: pathspec
> 
> Default: ~/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
> 
> Ini Section: defaults
> 
> Ini Key: library
> 
> Environment: ANSIBLE\_LIBRARY


Before adding custom path to ansible.cfg:

```shell
ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(default) = ['/Users/foobar/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']

```

Add the following to ansible.cfg:
```ini
## custom library paths
#library = ./library
library = ~/.ansible/plugins/modules:/usr/share/ansible/plugins/modules:./library

```

After adding custom path to ansible.cfg:

```shell
ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/foobar/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/foobar/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/foobar/repos/ansible/ansible-datacenter/library']
```


## Reference

* https://stackoverflow.com/questions/53750049/location-to-keep-ansible-custom-modules
* 

