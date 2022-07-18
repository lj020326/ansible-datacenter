
# How to Debug a Problematic Module

Typically, you don’t debug a particular task or module in the first place. Instead, you test your playbook but encounter issues. As you debug further into the playbook, you may need to debug into a task or a module.

## 1\. Scenario

Today, I encountered an issue that led me to debugging into the `stat` module. Here is how to reproduce the scenario (on Ubuntu 18.04 Desktop):

```
#!/bin/sh

set -x

# Create the real target file.
touch /tmp/hello.txt.real

# Create the link to it.
ln -s /tmp/hello.txt.real /tmp/hello.txt

# Create the link to the link.
# NOTE: `/var/cache/` is owned by `root`.
sudo ln -s /tmp/hello.txt /var/cache/hello.txt
```

So this will be: `/var/cache/hello.txt (symlink) -> /tmp/hello.txt (symlink) -> /tmp/hello.txt.real (file)`.

I had a playbook (snippet) that gets the status of the file:

```
# Inventory file (/tmp/localhost.yml):
all:
  hosts:
    localhost:
      ansible_connection: local

# Playbook (/tmp/stat_file.yml)
- name: Get status of the file.
  hosts: all
  tasks:
  - name: Get the status of .
    vars:
      ansible_become: yes
      target_file: /var/cache/hello.txt
    stat:
      path: ""
      follow: yes
    register: file_stat
```

When I ran the playbook `ansible-playbook -Kvvv -i /tmp/localhost.yml /tmp/stat_hello.yml`, I was surprised by the error of `Permission denied`:

```
TASK [Get the status of /var/cache/hello.txt.] *******
task path: /tmp/stat_hello.yml:4
<localhost> ESTABLISH LOCAL CONNECTION FOR USER: vagrant
<localhost> EXEC /bin/sh -c 'echo ~vagrant && sleep 0'
<localhost> EXEC /bin/sh -c '( umask 77 && mkdir -p "` echo /home/vagrant/.ansible/tmp `"&& mkdir "` echo /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003 `" && echo ansible-tmp-1611960114.27-23625-278355414153003="` echo /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003 `" ) && sleep 0'
Using module file /usr/lib/python2.7/dist-packages/ansible/modules/files/stat.py
<localhost> PUT /home/vagrant/.ansible/tmp/ansible-local-23496jyGGOC/tmpgSbfgI TO /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py
<localhost> EXEC /bin/sh -c 'chmod u+x /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/ /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py && sleep 0'
<localhost> EXEC /bin/sh -c 'sudo -H -S  -p "[sudo via ansible, key=zevpwzzrlphljnlsxijznwftwiylwrtx] password:" -u root /bin/sh -c '"'"'echo BECOME-SUCCESS-zevpwzzrlphljnlsxijznwftwiylwrtx ; /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py'"'"' && sleep 0'
The full traceback is:
WARNING: The below traceback may *not* be related to the actual failure.
  File "/tmp/ansible_stat_payload_mQVrkm/ansible_stat_payload.zip/ansible/modules/files/stat.py", line 462, in main
fatal: [localhost]: FAILED! => {
    "changed": false,
    "invocation": {
        "module_args": {
            "checksum_algorithm": "sha1",
            "follow": true,
            "get_attributes": true,
            "get_checksum": true,
            "get_md5": false,
            "get_mime": true,
            "path": "/var/cache/hello.txt"
        }
    },
    "msg": "Permission denied"
}
```

I couldn’t figure out why I got a “Permission denied”, so I thought I’d better debug into the Ansible `stat` module to see what was going on. That was my motive to learn how to debug a module.

## 2\. Debugging Modules

I used \[1\] as the primary reference to learning module debugging.

Set the environment [`ANSIBLE_KEEP_REMOTE_FILES`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#envvar-ANSIBLE_KEEP_REMOTE_FILES) to `1` on the **control host** to keep the remote module files: `export ANSIBLE_KEEP_REMOTE_FILES=1`.

In my case, the saved module file (`AnsiballZ_stat.py`) is shown in the following log message:

```
<localhost> PUT /home/vagrant/.ansible/tmp/ansible-local-23496jyGGOC/tmpgSbfgI TO /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py
```

Then I could `cd /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/` to find the bundled `stat` module.

In order to debug the module, **firstly, I needed to extract the content of the bundled `stat` module by running `./AnsiballZ_stat.py explode`**:

```
Module expanded into:
/home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/debug_dir
```

The directory `debug_dir` has the following hierarchy:

```
├── AnsiballZ_stat.py
└── debug_dir
    ├── ansible
    │   ├── __init__.py
    │   ├── modules
    │   │   ├── files
    │   │   │   ├── __init__.py
    │   │   │   └── stat.py
    │   │   └── __init__.py
    │   └── module_utils
    │       ├── basic.py
    │       ├── common
    │       │   ├── _collections_compat.py
    │       │   ├── collections.py
    │       │   ├── file.py
    │       │   ├── __init__.py
    │       │   ├── _json_compat.py
    │       │   ├── parameters.py
    │       │   ├── process.py
    │       │   ├── sys_info.py
    │       │   ├── text
    │       │   │   ├── converters.py
    │       │   │   ├── formatters.py
    │       │   │   └── __init__.py
    │       │   ├── _utils.py
    │       │   └── validation.py
    │       ├── compat
    │       │   ├── __init__.py
    │       │   ├── _selectors2.py
    │       │   └── selectors.py
    │       ├── distro
    │       │   ├── _distro.py
    │       │   └── __init__.py
    │       ├── __init__.py
    │       ├── parsing
    │       │   ├── convert_bool.py
    │       │   └── __init__.py
    │       ├── pycompat24.py
    │       ├── six
    │       │   └── __init__.py
    │       └── _text.py
    └── args
```

The important files are:

-   `./debug_dir/ansible/modules/files/stat.py`: The `stat` module that was executed. I could modify its content for debugging.
-   `./debug_dir/ansible/module_utils`: The supportive Ansible modules, usually built-in ones.
-   `./debug_dir/args`: The `stat` module’s input arguments. I could modify this file to change the input arguments.

**Then I could run `./AnsiballZ_stat.py execute | jq`** to run the `stat` module with the arguments in `args`. I could modify the contents of the files to change the behaviors or print more details for debugging purpose.

However, when running `./AnsiballZ_stat.py execute | jq` directly, I ran it in the non-privileged user mode under which the `Permission denied` issue didn’t exist.

So I looked closely at the detailed output of the playbook. The log message below shows how to run the module in privileged mode (`ansible_become: yes`):

```
<localhost> EXEC /bin/sh -c 'sudo -H -S  -p "[sudo via ansible, key=zevpwzzrlphljnlsxijznwftwiylwrtx] password:" -u root /bin/sh -c '"'"'echo BECOME-SUCCESS-zevpwzzrlphljnlsxijznwftwiylwrtx ; /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py'"'"' && sleep 0'
```

The actual command starts with `sudo -H -S` and ends with `AnsiballZ_stat.py'"'"'`. Many levels of single- and double-quotation marks. But if you run the command directly:

```
sudo -H -S  -p "[sudo via ansible, key=zevpwzzrlphljnlsxijznwftwiylwrtx] password:" -u root /bin/sh -c '"'"'echo BECOME-SUCCESS-zevpwzzrlphljnlsxijznwftwiylwrtx ; /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py'"'"'
```

You will get the error:

```
/bin/sh: 1: 'echo BECOME-SUCCESS-zevpwzzrlphljnlsxijznwftwiylwrtx ; /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py': not found
```

This is because those levels of quotation marks make the entire string `echo BECOME-SUCCESS-zevpwzzrlphljnlsxijznwftwiylwrtx ; /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py` be treated as a single command, which surely could not be found. You need to strip off the quotations to leave only the outermost level to quote the actual command in order to run it:

```
sudo -H -S  -p "[sudo via ansible, key=zevpwzzrlphljnlsxijznwftwiylwrtx] password:" -u root /bin/sh -c '/usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1611960114.27-23625-278355414153003/AnsiballZ_stat.py' | jq
```

And the output would be the following, with the “Permission denied” error message:

```
{
  "msg": "Permission denied",
  "failed": true,
  "exception": "WARNING: The below traceback may *not* be related to the actual failure.\n  File \"/tmp/ansible_stat_payload_dm1iQD/ansible_stat_payload.zip/ansible/modules/files/stat.py\", line 462, in main\n",
  "invocation": {
    "module_args": {
      "checksum_algorithm": "sha1",
      "get_checksum": true,
      "follow": true,
      "path": "/var/cache/hello.txt",
      "get_md5": false,
      "get_mime": true,
      "get_attributes": true
    }
  }
}
```

## 3\. Use `ansible` to Reproduce

Running `ansible -vvv -e "ansible_become=yes" -m stat -a "path=/var/cache/hello.txt follow=yes" localhost` coudl also reproduce the error with a lot of details:

```
ansible 2.9.17
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/vagrant/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Sep 30 2020, 13:38:04) [GCC 7.5.0]
Using /etc/ansible/ansible.cfg as config file
setting up inventory plugins
host_list declined parsing /etc/ansible/hosts as it did not pass its verify_file() method
script declined parsing /etc/ansible/hosts as it did not pass its verify_file() method
auto declined parsing /etc/ansible/hosts as it did not pass its verify_file() method
Parsed /etc/ansible/hosts inventory source with ini plugin
Loading callback plugin minimal of type stdout, v2.0 from /usr/lib/python2.7/dist-packages/ansible/plugins/callback/minimal.pyc
Skipping callback 'actionable', as we already have a stdout callback.
Skipping callback 'counter_enabled', as we already have a stdout callback.
Skipping callback 'debug', as we already have a stdout callback.
Skipping callback 'dense', as we already have a stdout callback.
Skipping callback 'dense', as we already have a stdout callback.
Skipping callback 'full_skip', as we already have a stdout callback.
Skipping callback 'json', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'null', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.
Skipping callback 'selective', as we already have a stdout callback.
Skipping callback 'skippy', as we already have a stdout callback.
Skipping callback 'stderr', as we already have a stdout callback.
Skipping callback 'unixy', as we already have a stdout callback.
Skipping callback 'yaml', as we already have a stdout callback.
META: ran handlers
<127.0.0.1> ESTABLISH LOCAL CONNECTION FOR USER: vagrant
<127.0.0.1> EXEC /bin/sh -c 'echo ~vagrant && sleep 0'
<127.0.0.1> EXEC /bin/sh -c '( umask 77 && mkdir -p "` echo /home/vagrant/.ansible/tmp `"&& mkdir "` echo /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879 `" && echo ansible-tmp-1611961367.42-25454-98190200578879="` echo /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879 `" ) && sleep 0'
Using module file /usr/lib/python2.7/dist-packages/ansible/modules/files/stat.py
<127.0.0.1> PUT /home/vagrant/.ansible/tmp/ansible-local-25448pKu3rF/tmpaN60pR TO /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879/AnsiballZ_stat.py
<127.0.0.1> EXEC /bin/sh -c 'chmod u+x /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879/ /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879/AnsiballZ_stat.py && sleep 0'
<127.0.0.1> EXEC /bin/sh -c 'sudo -H -S -n  -u root /bin/sh -c '"'"'echo BECOME-SUCCESS-spmluzzyupymhfomwsclhzzsehawfrnh ; /usr/bin/python2 /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879/AnsiballZ_stat.py'"'"' && sleep 0'
<127.0.0.1> EXEC /bin/sh -c 'rm -f -r /home/vagrant/.ansible/tmp/ansible-tmp-1611961367.42-25454-98190200578879/ > /dev/null 2>&1 && sleep 0'
The full traceback is:
WARNING: The below traceback may *not* be related to the actual failure.
  File "/tmp/ansible_stat_payload_FyfdaU/ansible_stat_payload.zip/ansible/modules/files/stat.py", line 462, in main
localhost | FAILED! => {
    "changed": false,
    "invocation": {
        "module_args": {
            "checksum_algorithm": "sha1",
            "follow": true,
            "get_attributes": true,
            "get_checksum": true,
            "get_md5": false,
            "get_mime": true,
            "path": "/var/cache/hello.txt"
        }
    },
    "msg": "Permission denied"
}
```

## 4\. Other Methods

### 4.1 Environment Variable `ANSIBLE_DEBUG`

The `debug` option in the `[default]` section \[2\] can configure if Ansible should print the debug output. Note the “debug output” does not refer to the output by [the `debug` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html) but the log messages that are printed out by `display.debug(...)` in Ansible’s source code, such as the following one:

```
    @classmethod
    def cli_executor(cls, args=None):
        # ...

        try:
            display.debug("starting run")
```

The quick way to enable this on the command line is to run `export ANSIBLE_DEBUG=1` followed by the Ansible command. Note that \[2\] warns “Debug output can also **include secret information despite no\_log settings being enabled**, which means debug mode should not be used in production.”

Note that the color of the debug output can be configured by [`COLOR_DEBUG`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#color-debug).

### 4.2 CLI Options `--start-at-task` And `--step`

Refer to \[3\].

### 4.3 Using the Task Debugger

Refer to \[4\].

## References

* https://yaobinwen.github.io/2021/01/29/Ansible-how-to-debug-a-problematic-module.html

-   \[1\] [Ansible: Debugging modules](https://docs.ansible.com/ansible/latest/dev_guide/debugging.html) as part of the Developer Guide.
-   \[2\] [Ansible Configuration Settings: DEFAULT\_DEBUG](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-debug)
-   \[3\] [Executing playbooks for troubleshooting](https://docs.ansible.com/ansible/latest/user_guide/playbooks_startnstep.html)
-   \[4\] [Debugging tasks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html)

tags: _Tech_

