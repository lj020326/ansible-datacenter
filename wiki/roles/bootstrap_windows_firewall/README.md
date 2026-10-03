---
harvested_date: '2026-08-07T18:07:09.498083+00:00'
original_path: roles/bootstrap_windows_firewall/README.md
source_type: legacy_markdown
title: "Windows Firewall Ansible Role"
category: "Ansible Roles"
tags: ["Windows", "Firewall", "Ansible", "Security"]
---

# Windows Firewall Ansible Role

Ansible role to configure the host firewall on a Windows system.

## Requirements & Dependencies

### Ansible

This role has been tested on the following versions:
- 2.3
- 2.4 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
- 2.5b2 (Not working! [ansible#31576](https://github.com/ansible/ansible/issues/31576))
- 4.10.0
- 5.3.0

### Python

Python 3.x is required for running Ansible.

### Windows

Windows Server 2012 R2 or later is required.

## Example Playbook

To use this role, simply include it in your playbook. For example:

```yaml
- hosts: all
  roles:
    - ansible-win-firewall
```

### Running the Playbook

1. Verify connectivity to the Windows hosts:

   ```sh
   $ ansible -i inventory -m win_ping win --ask-pass
   ```

   Make sure to replace `inventory` with the path to your inventory file and `win` with the appropriate host group.

2. Run the playbook:

   ```sh
   $ ansible-playbook -i inventory --limit win site.yml
   ```

## Variables

Refer to `defaults/main.yml` for a complete list of variables and their default values.

## Continuous Integration

This role includes the following CI configurations:
- Travis CI for basic GitHub syntax checks
- Appveyor for Windows testing
- Vagrant for local testing (`test/vagrant` directory)

### Running Vagrant Tests

1. Navigate to the Vagrant test directory:

   ```sh
   $ cd test/vagrant
   ```

2. Start the Vagrant environment:

   ```sh
   $ vagrant up
   ```

3. Provision the environment:

   ```sh
   $ vagrant provision
   ```

4. Destroy the environment:

   ```sh
   $ vagrant destroy
   ```

5. Verify connectivity to the Vagrant environment:

   ```sh
   $ ansible -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -m win_ping -e ansible_winrm_server_cert_validation=ignore -e ansible_ssh_port=55986 all
   ```

## Troubleshooting & Known Issues

- Some Ansible versions (2.4 and 2.5b2) have issues with this role due to [ansible#31576](https://github.com/ansible/ansible/issues/31576). Consider using a different version or applying the fix mentioned in the issue.
- Make sure that WinRM is properly configured on the Windows hosts.
- Ensure that the Ansible user has the necessary permissions to modify firewall settings.

## FAQ

**Q: Can I use this role with older versions of Windows Server?**
A: This role is designed for Windows Server 2012 R2 or later. While it might work with older versions, it's not officially supported.

**Q: Why are some Ansible versions not working?**
A: Some versions have issues with the Windows firewall modules due to bugs in Ansible. See the "Requirements & Dependencies" section for more details.

## References

- [Demystifying the Windows Firewall: Learn how to irritate attackers without crippling your network, Oct 2016](https://channel9.msdn.com/Events/Ignite/New-Zealand-2016/M377)
- [Endpoint Isolation with the Windows Firewall, Apr 2018](https://medium.com/@cryps1s/endpoint-isolation-with-the-windows-firewall-462a795f4cfb)
- [Ansible Windows Firewall Module Documentation](https://docs.ansible.com/ansible/latest/modules/win_firewall_rule.html)