Linux Bootstrap
================

This role will bootstrap a linux (CentOS/Ubuntu) node.

It consists of two steps, the first step will copy an ssh key and disable root password login, the second step will configure the system.

Requirements
------------

A CentOS instance with root ssh access with password, an account with sudo priviledges will be created and the root user login disabled.

The role will set the hostname of the host using a DNS query, for this it is required that the inventory hostname resolves to a single ipv4 address.

Role Variables
--------------

Name of admin account:

- `bootstrap_linux_ansible_username` - The name of the user admin account, default to: `deploy`
- `bootstrap_linux_ansible_authorized_public_sshkey` - The path to the SSH key to be added for the admin user, default to: `~/.ssh/id_rsa.pub`
- `bootstrap_linux_default_path` - The path to be set as default: `/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin`
- `bootstrap_linux_ansible_ssh_allowed_ips` - An array of IPs allowed to connect via SSH, ensure this include your current IP or access to the server will be impossible after this role has run.


Dependencies
------------

none

Usage
-----

1) First pass


You must first execute the playbook with the root user and the bootstrap tag, like so:

Inventory:

    [bootstrap]
    somehost.somedomain.com ansible_ssh_pass=ched3bYg8Doiv6h


Playbook:

    - hosts: bootstrap
      remote_user: root
      gather_facts: false

      roles:
      - { role: bootstrap, bootstrap_operation: 'bootstrap' }


2) Second pass


Inventory:

    [somegroup]
    somehost.somedomain.com


Playbook:

    - hosts: somegroup
      remote_user: deploy
      sudo: true
      gather_facts: false

      roles:
      - { role: bootstrap, bootstrap_operation: 'configure' }

