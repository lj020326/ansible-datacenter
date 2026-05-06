---
title: "Bootstrap Vmware Esxi Role"
role: roles/bootstrap_vmware_esxi
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_vmware_esxi]
---

# Role: `bootstrap_vmware_esxi`

## Overview

The `bootstrap_vmware_esxi` role is designed to automate the initial setup of VMware ESXi hosts by ensuring SSH connectivity and adding an SSH public key for secure access. This role is particularly useful in environments where manual configuration can be time-consuming and error-prone.

## Role Path
```
roles/bootstrap_vmware_esxi
```

## Default Variables

The following variables are defined in `defaults/main.yml`:

- **bootstrap_vmware_esxi__esxi_password**: The password for the ESXi root user. This variable is intended for internal use only and should be overridden with a secure value in your inventory or group_vars.

  ```yaml
  bootstrap_vmware_esxi__esxi_password: foobar
  ```

## Tasks

The tasks defined in `tasks/main.yml` are executed to ensure the ESXi host is properly configured:

1. **Run locally**
   - Delegates the task execution to the local machine where Ansible is running.
   - Ensures that the correct Python interpreter is used for executing commands.

2. **Test ESXi connectivity for root**
   - Attempts to SSH into the ESXi host using the specified user and domain.
   - Uses `sshpass` with the provided password to authenticate if necessary.
   - Ignores errors during this step to allow subsequent tasks to handle any issues.

3. **Display login_enabled**
   - Outputs the result of the previous SSH connectivity test for debugging purposes.

4. **Add ssh auth key to ESXi servers**
   - Executes only if the initial SSH connection was successful (`not login_enabled.failed`).
   - Appends the specified public SSH key to the authorized keys file on the ESXi host, allowing passwordless SSH access.
   - Uses `sshpass` with the provided password for authentication.

## Important Notes

- **Double-underscore variables**: Variables prefixed with double underscores (e.g., `bootstrap_vmware_esxi__esxi_password`) are intended for internal use within this role. They should not be modified directly in playbooks or inventory files unless absolutely necessary.
  
- **Security Considerations**:
  - Ensure that the `bootstrap_vmware_esxi__esxi_password` variable is overridden with a secure password in your inventory or group_vars to avoid exposing sensitive information.
  - It is recommended to use SSH key-based authentication instead of passwords for better security.

## Example Playbook

Here is an example playbook that demonstrates how to use the `bootstrap_vmware_esxi` role:

```yaml
---
- name: Bootstrap VMware ESXi hosts
  hosts: esxi_hosts
  become: yes
  vars:
    ansible_user: root
    ca_domain: example.com
    admin_ssh_public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    bootstrap_vmware_esxi__esxi_password: "{{ vault_esxi_password }}"
  roles:
    - role: bootstrap_vmware_esxi
```

In this example, the `bootstrap_vmware_esxi` role is applied to all hosts in the `esxi_hosts` group. The `ansible_user`, `ca_domain`, and `admin_ssh_public_key` variables are specified directly in the playbook, while the ESXi password is retrieved from an Ansible Vault variable (`vault_esxi_password`) for security.

## Conclusion

The `bootstrap_vmware_esxi` role simplifies the initial setup of VMware ESXi hosts by automating SSH connectivity testing and authorized key management. By following the guidelines provided in this documentation, you can ensure a secure and efficient deployment process for your ESXi environments.