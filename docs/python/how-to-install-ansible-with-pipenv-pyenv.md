
# How to Install Ansible with pipenv and pyenv

Ansible is a powerful IT automation engine, perfect for the IT professional or DevOps engineer. There are many ways to install Ansible, often packages are used to install a single version of Ansible across your entire system. This post will cover how to install Ansible 2.12 with pipenv and pyenv. In my environment I use “Virtual Environments”, a python feature that allows you to separate your Python projects into folders and limit the libraries and packages for that folder. This means you can have multiple Ansible projects that each run a different version of Ansible. To do this we will use a few tools to manage these virtual environments, namely “pipenv”. In the past I used [plain virtual environments to install ansible](https://www.buildahomelab.com/2018/10/06/setup-ansible-with-virtualenv/), however lately I’ve found that pipenv is much easier to manage.

## Install pipx and pyenv Tools

Pyenv allows you to run multiple versions of Python on your system, without needing to change your system python. In the past I found myself getting frustrated with different versions of python, running on different operating systems. Usually it wouldn’t make a different, but every so often Ansible might have a bug with whatever version of python I had available. This article assumes that you are using Ubuntu or Debian Linux. To install pyenv install the dependencies (note that pyenv will compile python in some cases). To see the latest dependencies check out [this page](https://github.com/pyenv/pyenv/wiki#suggested-build-environment).

```shell
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev
```

After that we can install pyenv, I find that the install script is easiest to work with at home.

```shell
curl https://pyenv.run | bash
```

Update bash to use pyenv from the command line. In your user folder (`cd ~/`), edit the .bashrc file (`vim .bashrc`) and add the following to the bottom if it does not exist.

```shell
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
 eval "$(pyenv init -)"
fi
```

Run `exec $SHELL` to apply the changes. With pyenv installed we can install any version of python we want and reference it later on. Go ahead and install a new version of Python.

```shell
pyenv install --list

pyenv install 3.10.4
```

This could take a minute, when the install is done you can use `pyenv versions` to show all the versions available to use. For more information on using pyenv check out the [project page on Github](https://github.com/pyenv/pyenv).

## Install pipenv to Manage Python Libraries

pipenv is normally used to managed libraries used in a python program. For our case we’ll use pipenv to lock our project to a specific version of Python and install ansible. We can use it to install Ansible extras like ansible-lint or molecule. We’ll start by installing the [pipx](https://pypa.github.io/pipx/). We could technically install pipenv without pipx, but it makes the process much easier and allows for easy updates in the future. Install the dependencies for pipx.

```shell
sudo apt install python3-venv python3-pip
```

Now install pipx, the below will install pipx for your user profile and also add pipx to your path so you can run it from the command line easily:

```shell
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

With pipx installed we can install pipenv. Pipenv gives you a lot of control over python projects (Ansible is written in Python).

After that, we can finally install ansible. Create a new directory with `mkdir ansible_test` and install ansible. The following command tells pipenv to install Ansible and use Python version 3.10.4 that we installed earlier.

```shell
mkdir ansible_test
cd ansible_test
pipenv install ansible --python 3.10.4
```

Now if you try to run Ansible it wont work. To enter the virtual environment we just created enter the following.

See the `(ansible_test)` at the start of your prompt? That’s telling you that you’re in the virtual environment for this folder. Run `ansible --version` to verify that ansible is installed.

```shell
(ansible_test) ljohnson@servername:~/ansible_test$ ansible --version
ansible [core 2.12.5]
  config file = None
  configured module search path = ['/home/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ljohnson/.local/share/virtualenvs/ansible_test-Q7cE2M5k/lib/python3.10/site-packages/ansible
  ansible collection location = /home/ljohnson/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/ljohnson/.local/share/virtualenvs/ansible_test-Q7cE2M5k/bin/ansible
  python version = 3.10.4 (main, Apr 17 2022, 15:32:04) [GCC 10.2.1 20210110]
  jinja version = 3.1.1
  libyaml = True
```

You can install more python applications with pipenv now:

```shell
pipenv install ansible-lint
```

One thing to note is that pipenv creates a “Pipfile”. This file stores information about what you have installed in this folder or virtual environment. If you need to update Ansible in the future you can modify the line `ansible = "*"` with whatever version you want installed. Another option is to run `pipenv update` to update all your python libraries and applications. To view your current environment open the Pipfile.

## Running Ansible Playbooks in pipenv

To test out Ansible we can create a new playbook in the `ansible_test` directory. Copy and paste the following into a file called playbook.yml (`vim playbook.yml`).

```yaml
---
- name: "collect facts about the computer"
  hosts: localhost
  connection: local
  gather_facts: no
  tasks:
    - name: gather facts
      ansible.builtin.setup:
        gather_subset: "min"
      register: "minimalfacts"

    - debug: var=minimalfacts
```

With our playbook in place, run the playbook with Ansible (be sure you ran `pipenv shell` before trying to use ansible).

```shell
ansible-playbook playbook.yml
```

The ansible-playbook commands returns information about your system.

```shell
(ansible_test) ljohnson@servername:~/ansible_test$ ansible-playbook playbook.yml
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [collect facts about the computer] ****************************************************************************************************
TASK [gather facts] ************************************************************************************************************************
ok: [localhost]

TASK [debug] *******************************************************************************************************************************
ok: [localhost] => {
    "minimalfacts": {
        "ansible_facts": <redacted>

PLAY RECAP *********************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

That’s it! You can run `exit` at any time to leave this virtual environment. Just note that you will need to be in the `ansible_test` directory to run `pipenv shell` and get back in. You can use the pipenv install command from earlier in a new directory to create a separate Ansible project.

I’ll admit that Installing Ansible this way is way more complicated than using yum or apt. But it allows you to lock in versions of Ansible and Python so you can have a consistent experience across your devices and teams. Now you can take your entire ansible_test folder anywhere and run `pipenv install` and you’ll know that everyone using the project is on the same version of Ansible and Python. This will save you a ton of headaches troubleshooting. Just be sure you’ve installed pyenv and pipenv wherever you want to use the project. 
