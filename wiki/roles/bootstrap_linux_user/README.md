```markdown
---
title: Bootstrap Linux User Role Documentation
original_path: roles/bootstrap_linux_user/README.md
category: Ansible Roles
tags: [linux-user-management, ansible-role]
---

# Bootstrap Linux User Role

A role for managing Linux users.

## Requirements

- It is expected that if this role is to create the `ansible` user, there is a platform OS-specific seed user with sufficient admin permissions to manage user creation/modification (e.g., `administrator`, `packer`, `vagrant`, etc.) from a newly minted platform OS instance.
- Root privileges, e.g., `become: true`

## Role Variables

| Variable                     | Description                                                                                                                                                                                                                                                                                | Default Value |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `bootstrap_linux_user_list`  | List of users **(see user dict details in the next section)**.                                                                                                                                                                | `[]`          |
| `bootstrap_linux_user_list__*` | Variables with the prefix `bootstrap_linux_user_list__` are dereferenced and merged into a single list of users to modify. Each list should contain a list of `dicts`. Each `dict` defines/specifies the user configuration to modify. Options include the user variables mentioned in the next section titled `bootstrap_linux_user_list` details. | `[]`          |

### `bootstrap_linux_user_list` Details

The user list allows you to define users. Each item in the list can have the following attributes:

| Variable         | Type               | Default | Required |
|------------------|--------------------|---------|----------|
| `state`          | `present`, `absent`| `present` | No       |
| `name`           | `str`              | -       | Yes      |
| `system`         | `boolean`          | -       | No       |
| `shell`          | `str`              | -       | No       |
| `append`         | `boolean`          | -       | No       |
| `uid`            | `int`              | -       | No       |
| `group`          | `str`              | -       | No       |
| `groups`         | `list`             | -       | No       |
| `password`       | `str`              | -       | No       |
| `generate_ssh_key` | `boolean`        | -       | No       |
| `ssh_key_bits`   | `int`              | -       | No       |
| `ssh_key_file`   | `filepath`         | -       | No       |

#### Example of `bootstrap_linux_user_list`

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

## Reference

- [Gist Reference](https://gist.github.com/fulv/3928d098e8c35af1cc5363a4d2d4fcd0)

## Backlinks

- [Ansible Roles Documentation](../ansible_roles.md)
```

This Markdown document is now clean, professional, and formatted for GitHub rendering while maintaining all original information and meaning.