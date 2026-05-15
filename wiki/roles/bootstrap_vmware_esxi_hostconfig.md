---
title: Bootstrap VMware ESXi Host Configuration Role
role: bootstrap_vmware_esxi_hostconfig
category: VMware ESXi Configuration
type: Ansible Role
tags: vmware, esxi, configuration, automation
---

## Summary

The `bootstrap_vmware_esxi_hostconfig` role is designed to automate the initial configuration of a VMware ESXi host. This includes setting DNS and NTP configurations, optionally changing the hostname, configuring advanced settings, and managing services on the ESXi node.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_vmware_esxi_hostconfig__esxi_username`  | `{{ vault_esxi_username }}`                                                       | The username used to authenticate with the ESXi host. This should be a vault-encrypted variable.                                          |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_password`  | `{{ vault_esxi_password }}`                                                       | The password used to authenticate with the ESXi host. This should be a vault-encrypted variable.                                          |
| `role_bootstrap_vmware_esxi_hostconfig__ntp_state`      | `present`                                                                       | Specifies whether NTP settings should be configured (`present`) or removed (`absent`).                                                      |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_dns_servers`  | `[8.8.8.8, 8.8.4.4]`                                                            | A list of DNS servers to configure on the ESXi host.                                                                                      |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_ntp_servers`  | `[132.163.96.5, 132.163.97.5]`                                                   | A list of NTP servers to configure on the ESXi host.                                                                                      |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_change_hostname`  | `false`                                                                         | Specifies whether the hostname should be changed. If set to `true`, ensure the `fqdn` variable is defined in your inventory.               |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_adv_settings`  | `{}`                                                                            | A dictionary of advanced settings to configure on the ESXi host. Each key-value pair represents an option and its value.                 |
| `role_bootstrap_vmware_esxi_hostconfig__esxi_service_list`  | `[]`                                                                          | A list of dictionaries specifying services to manage on the ESXi host. Each dictionary should include `name`, `policy`, and `state`.     |

## Usage

To use this role, ensure that you have defined the necessary variables in your inventory or playbook. Here is an example of how to include this role in a playbook:

```yaml
- hosts: esxi_hosts
  gather_facts: no
  roles:
    - role: bootstrap_vmware_esxi_hostconfig
      vars:
        role_bootstrap_vmware_esxi_hostconfig__esxi_username: '{{ vault_esxi_username }}'
        role_bootstrap_vmware_esxi_hostconfig__esxi_password: '{{ vault_esxi_password }}'
        role_bootstrap_vmware_esxi_hostconfig__esxi_dns_servers:
          - 8.8.8.8
          - 8.8.4.4
        role_bootstrap_vmware_esxi_hostconfig__esxi_ntp_servers:
          - 132.163.96.5
          - 132.163.97.5
        role_bootstrap_vmware_esxi_hostconfig__esxi_change_hostname: true
        role_bootstrap_vmware_esxi_hostconfig__fqdn: example.com
        role_bootstrap_vmware_esxi_hostconfig__esxi_adv_settings:
          UserVars.SuppressShellWarning: 1
        role_bootstrap_vmware_esxi_hostconfig__esxi_service_list:
          - name: sshd
            policy: on
            state: start
```

## Dependencies

This role requires the `community.vmware` collection. Ensure that it is installed before running this playbook:

```bash
ansible-galaxy collection install community.vmware
```

## Best Practices

- **Security**: Always use vault-encrypted variables for sensitive information such as usernames and passwords.
- **Inventory Management**: Define all necessary variables in your inventory to ensure consistency across multiple hosts.
- **Advanced Settings**: Use the `esxi_adv_settings` variable with caution, as incorrect settings can affect the stability of the ESXi host.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_esxi_hostconfig/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_esxi_hostconfig/tasks/main.yml)