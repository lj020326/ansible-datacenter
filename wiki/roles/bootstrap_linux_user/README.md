---
harvested_date: '2026-08-07T18:07:09.327337+00:00'
original_path: roles/bootstrap_linux_user/README.md
source_type: legacy_markdown
title: Ansible Role - Bootstrap Linux User
category: Ansible
tags:
  - Ansible
  - Linux
  - User Management
---

# Ansible Role - Bootstrap Linux User

A role for managing Linux users, including creating, modifying, and deleting users, setting up SSH keys, and managing sudo privileges.

## Requirements

- It is expected that if this role is to create the Ansible user, there is a platform OS specific seed user with sufficient admin permissions to manage user creation/modification (e.g., `administrator`, `packer`, `vagrant`, etc.) from a newly minted platform OS instance.
- Root privileges, e.g., `become: true`

## Role Variables

| Variable                     | Description                                                                                                                                                                                                                                                                                                                                             | Default value |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| bootstrap_linux_user_list    | List of users **(see user dict details in next section)**                                                                                                                                                                                                                                                                                               | `[]`          |
| bootstrap_linux_user_list__* | Variables with prefix `bootstrap_linux_user_list__` are dereferenced and merged to a single list of users to modify. Each list should contain a list of `dicts`. Each `dict` defines/specifies the user configuration to modify. `Dict` options include the user variables mentioned in the next section titled `bootstrap_linux_user_list` details. | []            |

### `bootstrap_linux_user_list` Details

`bootstrap_linux_user_list__*` vars are merged when running the role.

The user list allows you to define users. Each item in the list can have the following attributes:

| Variable         | Type               | Default | Required |
|------------------|--------------------|---------|----------|
| state            | C(present, absent) | present | no       |
| name             | str                |         | yes      |
| system           | boolean            |         | no       |
| shell            | str                |         | no       |
| append           | boolean            |         | no       |
| uid              | int                |         | no       |
| group            | str                |         | no       |
| groups           | list               |         | no       |
| password         | str                |         | no       |
| generate_ssh_key | boolean            |         | no       |
| ssh_key_bits     | int                |         | no       |
| ssh_key_file     | filepath           |         | no       |
| sudoer           | boolean            |         | no       |
| auth_key         | str                |         | no       |
| keyfiles         | str                |         | no       |

#### `bootstrap_linux_user_list` Example

Adding users:

```yaml
bootstrap_linux_user_list:
  - name: fulvio
    sudoer: yes
    auth_key: ssh-rsa blahblahblahsomekey this is actually the public key in cleartext
  - name: plone_buildout
    group: plone_group
    sudoer: no
    auth_key: ssh-rsa blahblahblah ansible-generated on default
    keyfiles: keyfiles/plone_buildout
```

## Dependencies

None.

## Example Playbook

```yaml
---
- hosts: linux_servers
  roles:
  - role: bootstrap_linux_user
    become: true
    bootstrap_linux_user_list:
      - name: fulvio
        sudoer: yes
        auth_key: ssh-rsa blahblahblahsomekey this is actually the public key in cleartext
      - name: plone_buildout
        group: plone_group
        sudoer: no
        auth_key: ssh-rsa blahblahblah ansible-generated on default
        keyfiles: keyfiles/plone_buildout
```

## Usage

### Adding a User with SSH Key

```yaml
bootstrap_linux_user_list:
  - name: john
    sudoer: yes
    auth_key: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAp... user@hostname
```

### Generating an SSH Key for a User

```yaml
bootstrap_linux_user_list:
  - name: jane
    generate_ssh_key: yes
    ssh_key_bits: 2048
    ssh_key_file: /home/jane/.ssh/id_rsa
```

### Removing a User

```yaml
bootstrap_linux_user_list:
  - name: obsolete_user
    state: absent
```

## Reference

For more information, see the [Ansible User Module documentation](https://docs.ansible.com/ansible/latest/modules/user_module.html).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.