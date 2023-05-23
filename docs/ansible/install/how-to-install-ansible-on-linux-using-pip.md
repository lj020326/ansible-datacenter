
# Ansible - Install Ansible on Linux using pip

___

This article describes how to install Ansible but not Ansible Tower. Refer to [Install Ansible Tower on Linux](http://www.freekb.net/Article?id=2231) if you also want Tower.

The system that Ansible is installed on is known as the _control node_. Windows is not supported for the control node. Instead, Ansible must be installed on a Linux distribution.

___

**Python**

The control node must have Python version 2.7 or higher or Python version 3.5 or higher installed. The [python --version command](http://www.freekb.net/Article?id=500) can be used to determine if Python is installed and the version that is installed. If Python is not installed, the installation of Ansible will also install Python.

```shell
$ python --version
Python 3.6.8
```

___

**EPEL (Extra Packages for Enterprise Linux)**

On a Red Hat distribution, PIP is in the [EPEL(Extra Packages for Enterprise Linux) repository](http://www.freekb.net/Article?id=3028), thus epel-release must be installed.

```shell
yum install epel-release
```

___

**Install**

On a Red Hat distribution, the [yum install ansible](http://www.freekb.net/Article?id=2411) command can be used to install Ansible. However, be aware that this will setup Ansible to use Python version 2.7.5. Python 2.7 reached it's end of life support in January of 2020. For this reason, it is preferrable to use PIP to install Ansible. The pip --version can be used to determine if PIP is installed. If PIP is installed, something like this should be displayed. If PIP is not installed, refer to [Installing PIP on Linux CentOS](http://www.freekb.net/Article?id=2233).

> **AVOID TROUBLE**
> 
> There are 3 versions of pip
> 
> -   pip is used for Python version 2.6 and below
> -   pip2 is used for Python version 2.7 and above
> -   pip3 is used for Python version 3
> 
> For example, the /usr/bin/pip command (or just pip) would be used for Python version 2.6 and below.

```shell
pip --version

pip 9.0.3 from /usr/lib/python3.6/site-packages (python 3.6)
```

The [hash command](http://www.freekb.net/Article?id=2587) caches the paths to commands, and if a command is relocated then bash will not pick it up unless that cache is cleared. Issue the following command to clear Ansible from the cache.

```shell
hash -d ansible
```

You may also want to [purge the pip cache](http://www.freekb.net/Article?id=2977) to avoid used cached files.

```shell
pip3 cache purge
```

Something like this should be returned.

```shell
Files removed: 2
```

If the wheel package is not installed, something like this will be returned. Ansible will still be installed.

```shell
Using legacy 'setup.py install' for ansible, since package 'wheel' is not installed.
```

However, so as to avoid using legacy setup.py, let's first install the wheel package.

```shell
pip3 install wheel
```

Use PIP to install the latest stable version of Ansible.

```shell
pip install ansible-base
pip install ansible
```

Or, a specific version of ansible can be installed.

```shell
pip install ansible==3.2.0
```

Also installed the packaging package, which is used by ansible base.

```shell
pip install packaging
```

This is required, because if the packaging package is not installed, something like this will probably get returned when using the [ansible-playbook command](http://www.freekb.net/Article?id=2239).

```
ERROR! Unexpected Exception, this is probably a bug: The 'packaging' distribution was not found and is required by ansible-base
```

The [pip show command](http://www.freekb.net/Article?id=2787) can be used to ensure that Ansible was installed.

```shell
pip3 show ansible-base
```

In this example, ansible-base version 2.10.6 is installed.

```
Name: ansible-base
Version: 2.10.6
Summary: Radically simple IT automation
Home-page: https://ansible.com/
Author: Ansible, Inc.
Author-email: info@ansible.com
License: GPLv3+
Location: /usr/local/lib/python3.6/site-packages
Requires: packaging, jinja2, PyYAML, cryptography
Required-by: ansible
```

And version 3.0.0 of ansible is installed.

```
Name: ansible
Version: 3.0.0
Summary: Radically simple IT automation
Home-page: https://ansible.com/
Author: Ansible, Inc.
Author-email: info@ansible.com
License: GPLv3+
Location: /usr/local/lib/python3.6/site-packages
Requires: jinja2, PyYAML, cryptography
```

Note that if you include the **--user** flag when installing Ansible (pip install --user ansible), then the location of Ansible will be something like this.

```
Location: /root/.local/lib/python3.6/site-packages
```

  
Note that Ansible does not create a daemon, thus the systemctl command will not be used. Instead, [Ansible uses SSH](http://www.freekb.net/Article?id=2272) to manage remote systems (or a different networking protocol could be used). When installing Ansible using pip (or from source), the config file should return **None**. In this scenario, refer to [Ansible - Configuration file](http://www.freekb.net/Article?id=2242).

```shell
ansible 2.9.12
  config file = None
  configured module search path = ['/home/jeremy.canfield/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.6/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.6.8 (default, Apr  2 2020, 13:34:55) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

Notice in this example that the python version is 3.6. Let's say the python --version command returns version 2 of Python. This can be problematic. In this scneario, you'll most probably want to [configure the python command to use version 3 of python](http://www.freekb.net/Article?id=2736).

```shell
python --version

Python 2.7.5
```

___

## Reference

- http://www.freekb.net/Article?id=214