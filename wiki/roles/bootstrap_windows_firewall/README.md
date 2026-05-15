```markdown
---
title: Windows Firewall Ansible Role Documentation
original_path: roles/bootstrap_windows_firewall/README.md
category: Ansible Roles
tags: [windows, firewall, ansible]
---

# Windows Firewall Ansible Role

An Ansible role to set up host firewall on Windows systems.

## Requirements & Dependencies

### Ansible
This role has been tested with the following versions:
- 2.3
- 2.4 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
- 2.5b2 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
- 4.10.0
- 5.3.0

## Example Playbook

To include this role in your playbook, simply add it to the roles list:

```yaml
- hosts: all
  roles:
    - ansible-win-firewall
```

Run the following commands:

```bash
$ ansible -i inventory -m win_ping win --ask-pass
$ ansible-playbook -i inventory --limit win site.yml
```

## Variables

For a comprehensive list of variables, refer to `defaults/main.yml`.

## Continuous Integration

This role includes basic tests using Travis CI (syntax check only), AppVeyor, and a Vagrantfile located in `test/vagrant`. To run the tests:

```bash
$ cd /path/to/roles/ansible-win-firewall/test/vagrant
$ vagrant up
$ vagrant provision
$ vagrant destroy
$ ansible -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -m win_ping -e ansible_winrm_server_cert_validation=ignore -e ansible_ssh_port=55986 all
```

## Troubleshooting & Known Issues

- **Ansible 2.4 and 2.5b2**: These versions do not work due to a known issue ([ansible#31576](https://github.com/ansible/ansible/issues/31576)).

## FAQ

*No frequently asked questions available at this time.*

## References

- [Demystifying the Windows Firewall: Learn how to irritate attackers without crippling your network, Oct 2016](https://channel9.msdn.com/Events/Ignite/New-Zealand-2016/M377)
- [Endpoint Isolation with the Windows Firewall, Apr 2018](https://medium.com/@cryps1s/endpoint-isolation-with-the-windows-firewall-462a795f4cfb)

## Backlinks

*No backlinks available at this time.*
```