# bootstrap_linux_upgrade

An Ansible role for upgrading the base OS.

## Requirements ##

None.

## Role Variables ##

| Variable | Description            | Default | Required |
|----------|------------------------|---------|----------|
| reboot_default | Run reboot by default. | true    | No |

## Dependencies ##

None.

## Example Playbook ##

Here's how to use it in a playbook:

```yaml
- hosts: all
  become: true
  become_method: sudo
  tasks:
    - name: Include upgrade
      ansible.builtin.include_role:
        name: bootstrap_linux_upgrade
```

## References

- https://github.com/cisagov/ansible-role-upgrade
