
# Windows firewall ansible role

Ansible role to setup host firewall on windows system.

## Requirements & Dependencies

### Ansible
It was tested on the following versions:
 * 2.3
 * 2.4 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
 * 2.5b2 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
 * 4.10.0
 * 5.3.0


## Example Playbook

Just include this role in your list.
For example

```
- host: all
  roles:
    - ansible-win-firewall
```

Run
```
$ ansible -i inventory -m win_ping win --ask-pass
$ ansible-playbook -i inventory --limit win site.yml
```

## Variables

See defaults/main.yml for full scope

## Continuous integration

This role has a travis basic test (for github, syntax check only), Appveyor test and a Vagrantfile (test/vagrant).

```
$ cd /path/to/roles/ansible-win-firewall/test/vagrant
$ vagrant up
$ vagrant provision
$ vagrant destroy
$ ansible -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -m win_ping -e ansible_winrm_server_cert_validation=ignore -e ansible_ssh_port=55986 all
```

## Troubleshooting & Known issues

## FAQ

## References

* [Demystifying the Windows Firewall  Learn how to irritate attackers without crippling your network, Oct 2016](https://channel9.msdn.com/Events/Ignite/New-Zealand-2016/M377)
* [Endpoint Isolation with the Windows Firewall, Apr 2018](https://medium.com/@cryps1s/endpoint-isolation-with-the-windows-firewall-462a795f4cfb)

