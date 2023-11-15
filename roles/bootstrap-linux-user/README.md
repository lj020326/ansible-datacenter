
# Package

A role for managing linux users.

## Requirements

- It is expected that if this role is to create the ansible user, that there is a platform OS specific seed user with sufficent admin perms to managed user creation/modification (e.g, `administrator`, `packer`. `vagrant`, etc) from a newly minted platform OS instance created.
- Root privileges, eg `become: yes`

## Role Variables

| Variable                     | Description                                                                                                                                                                                                                                                                                                                                             | Default value |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| bootstrap_linux_user_list    | List of users **(see user dict details in next section)**                                                                                                                                                                                                                                                                                               | `[]`          |
| bootstrap_linux_user_list__* | Variables with prefix `bootstrap_linux_user_list__` are dereferenced and merged to a single list of users to modify.  Each list should contain a list of `dicts`.  Each `dict` defines/specifies the user configuration to modify.  `Dict` options include the user variables mentioned in the next section titled `bootstrap_linux_user_list` details. | []            |

#### `bootstrap_linux_user_list` details

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

##### `bootstrap_linux_user_list` example
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
  - role: bootstrap-linux-user
    become: yes
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

ref: https://gist.github.com/fulv/3928d098e8c35af1cc5363a4d2d4fcd0
