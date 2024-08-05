# Ansible Role: Ansible

An Ansible Role that installs Ansible on Linux servers.

## Requirements

If using on a RedHat/CentOS/Rocky Linux-based host, make sure you've added the EPEL repository (it can easily be installed by including the `geerlingguy.repo-epel` role on Ansible Galaxy).

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    bootstrap_ansible__install_method: package

Whether to install Ansible via the system `package` manager (`apt`, `yum`, `dnf`, etc.), or via `pip`. If set to `pip`, you need to make sure Pip is installed prior to running this role. You can use the `bootstrap_pip` module to install Pip easily.

    bootstrap_ansible__install_version_pip: ''

If `bootstrap_ansible__install_method` is set to `pip`, the specific Ansible version to be installed via Pip. If not set, the latest version of Ansible will be installed.

    bootstrap_ansible__install_pip_extra_args: ''

If `bootstrap_ansible__install_method` is set to `pip`, the extra arguments to be given to `pip` are listed here. If not set, no extra arguments are given.

## Dependencies

None.

## Example Playbook

Install from the system package manager:

    - hosts: servers
      roles:
        - role: bootstrap_ansible

Install from pip:

    - hosts: servers
      vars:
        bootstrap_ansible__install_method: pip
        bootstrap_ansible__install_version_pip: "2.7.0"
        bootstrap_ansible__install_pip_extra_args: "--user"
      roles:
        - role: bootstrap_pip
        - role: bootstrap_ansible

## Reference

- https://github.com/geerlingguy/ansible-role-ansible
