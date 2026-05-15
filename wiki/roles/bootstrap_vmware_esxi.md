---
title: "Bootstrap VMware ESXi Role"
role: bootstrap_vmware_esxi
category: Ansible Roles
type: Technical Documentation
tags: ansible, vmware, esxi, automation
---

## Summary

The `bootstrap_vmware_esxi` role is designed to automate the initial setup of VMware ESXi hosts. It primarily focuses on testing SSH connectivity for the root user and adding an SSH public key to the ESXi servers for passwordless authentication.

## Variables

| Variable Name                         | Default Value        | Description                                                                 |
|---------------------------------------|----------------------|-----------------------------------------------------------------------------|
| `bootstrap_vmware_esxi__esxi_password` | `foobar`             | The default password used for authenticating to the ESXi host. **Deprecated** and will be replaced with a more secure method. |

## Usage

To use this role, include it in your playbook and ensure that the necessary variables are set. Below is an example of how to include this role in a playbook:

```yaml
- name: Bootstrap VMware ESXi Hosts
  hosts: esxi_hosts
  gather_facts: false
  roles:
    - role: bootstrap_vmware_esxi
      vars:
        admin_ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

Ensure that the `admin_ssh_public_key` variable is set to your public SSH key.

## Dependencies

This role does not have any external dependencies. However, it requires:

- The `sshpass` utility to be installed on the control machine.
- Properly configured SSH access to the ESXi hosts with the specified user and domain.

## Best Practices

1. **Security**: Avoid using plain text passwords in your playbooks. Consider using Ansible Vault or environment variables for sensitive information.
2. **SSH Key Management**: Ensure that the `admin_ssh_public_key` is securely managed and distributed.
3. **Inventory Configuration**: Properly configure your inventory file with the correct hostnames, user details, and domain.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure the role functions as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_esxi/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_esxi/tasks/main.yml)