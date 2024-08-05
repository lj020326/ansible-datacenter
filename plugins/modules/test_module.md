
## ref: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html
## ref: https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html
## ref: https://www.techbeatly.com/how-to-add-custom-modules-in-ansible/
## ref: https://stackoverflow.com/questions/53750049/location-to-keep-ansible-custom-modules

```shell
$ ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/foobar/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/foobar/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/foobar/repos/ansible/ansible-datacenter/library']

$ 
```

Local test custom module using python:
```shell
python -m library.test_module tests/modules/test_module.test1.args.json

{"changed": true, "original_message": "hello", "message": "goodbye", "invocation": {"module_args": {"name": "hello", "new": true}}}

```

Test using ansible:
```shell
$ ansible localhost -m test_module -a name=foo

PLAY [Ansible Ad-Hoc] *********************************************************************************************************************************************************************************************************************************************************

TASK [test_module] ************************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```


```shell
$ ansible-doc -t module test_module

> TEST_MODULE    (/Users/foobar/repos/ansible/ansible-datacenter/library/test_module.py)

        This is my longer description explaining my test module.

ADDED IN: version 1.0.0

OPTIONS (= is mandatory):

= name
        This is the message to send to the test module.

        type: str

- new
        Control to demo if the result of this module is changed or not.
        Parameter description can be a list as well.
        [Default: (null)]
        type: bool


AUTHOR: Your Name (@yourGitHubHandle)

EXAMPLES:

# Pass in a message
- name: Test with a message
  test_module:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  test_module:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  test_module:
    name: fail me


RETURN VALUES:
- message
        The output message that the test module generates.

        returned: always
        sample: goodbye
        type: str

- original_message
        The original name param that was passed in.

        returned: always
        sample: hello world
        type: str
$ 

```