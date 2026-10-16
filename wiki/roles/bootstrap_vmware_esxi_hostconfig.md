---
title: "Bootstrap VMware ESXi Host Configuration"
role: "bootstrap_vmware_esxi_hostconfig"
category: "VMware"
type: "Role"
tags: [ansible, role, bootstrap_vmware_esxi_hostconfig]
---

```yaml
---
# Documentation for bootstrap_vmware_esxi_hostconfig role

title: "Bootstrap VMware ESXi Host Configuration"
role: "bootstrap_vmware_esxi_hostconfig"
category: "VMware"
type: "Role"

summary: |
  The `bootstrap_vmware_esxi_hostconfig` role configures various settings on VMware ESXi hosts, including DNS, hostname, NTP, advanced settings, and services. It uses the `community.vmware` Ansible collection.

## Variables

| Variable Name              | Default Value                                                                 | Description                                                                                       |
|----------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `esxi_username`            | `{{ vault_esxi_username }}`                                                   | The username for the ESXi host.                                                                   |
| `esxi_password`            | `{{ vault_esxi_password }}`                                                   | The password for the ESXi host.                                                                   |
| `ntp_state`                | `present`                                                                     | The state of NTP configuration (present or absent).                                               |
| `esxi_dns_servers`         | `['8.8.8.8', '8.8.4.4']`                                                      | List of DNS servers to configure on the ESXi host.                                                 |
| `esxi_ntp_servers`         | `['132.163.96.5', '132.163.97.5']`                                             | List of NTP servers to configure on the ESXi host.                                                 |
| `esxi_change_hostname`     | `false`                                                                       | Boolean to determine whether to change the ESXi hostname.                                         |
| `esxi_adv_settings`        | `{}`                                                                          | Dictionary of advanced settings to configure on the ESXi host.                                     |
| `esxi_service_list`        | `[]`                                                                          | List of services to manage on the ESXi host.                                                      |

## Usage

To use this role, include it in your playbook and define the necessary variables. Below is an example playbook:

```yaml
---
- name: Configure ESXi hosts
  hosts: esxi_hosts
  roles:
    - bootstrap_vmware_esxi_hostconfig
  vars:
    esxi_username: "your_esxi_username"
    esxi_password: "your_esxi_password"
    esxi_dns_servers:
      - 8.8.8.8
      - 8.8.4.4
    esxi_ntp_servers:
      - 132.163.96.5
      - 132.163.97.5
    esxi_adv_settings:
      "Disk.AutoremoveOnVMInflate": "TRUE"
      "Misc.AllowUnsignedDriver": "TRUE"
    esxi_service_list:
      - name: "ntpd"
        policy: "autostart"
        state: "started"
```

## Dependencies

This role requires the `community.vmware` Ansible collection. You can install it using the following command:

```bash
ansible-galaxy collection install community.vmware
```

## Best Practices

1. **Security**: Ensure that the `esxi_username` and `esxi_password` variables are securely managed, preferably using Ansible Vault.
2. **Validation**: Always validate the certificates when connecting to ESXi hosts in a production environment.
3. **Idempotency**: The role is designed to be idempotent, meaning it can be run multiple times without causing unintended side effects.
4. **Testing**: Test the role in a development environment before applying it to production ESXi hosts.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_esxi_hostconfig/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_esxi_hostconfig/tasks/main.yml)