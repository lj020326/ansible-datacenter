---
title: "VMware ESXi Host Configuration Bootstrap"
original_path: "roles/bootstrap_vmware_esxi_hostconfig/README.md"
category: "Ansible Roles"
tags: ["VMware", "ESXi", "Host Configuration", "Ansible"]
harvested_date: "2023-08-07T18:07:09.449496+00:00"
source_type: "markdown"
---

# VMware ESXi Host Configuration Bootstrap

This Ansible role manages ESXi node settings, including hostname, DNS, and NTP configurations.

## Requirements

- `pyvmomi` Python library
- Ansible Vault file with ESXi credentials

## Role Variables

```yaml
esxi_username: '{{ vault_esxi_username }}'
esxi_password: '{{ vault_esxi_password }}'
ntp_state: present

dns_servers:
  - 8.8.8.8
  - 8.8.4.4

ntp_servers:
  - 132.163.96.5
  - 132.163.97.5

change_hostname: false
```

- `esxi_username`: The username for ESXi API access (retrieved from Ansible Vault)
- `esxi_password`: The password for ESXi API access (retrieved from Ansible Vault)
- `ntp_state`: The desired state of NTP service (present or absent)
- `dns_servers`: List of DNS servers to configure on the ESXi host
- `ntp_servers`: List of NTP servers to configure on the ESXi host
- `change_hostname`: Boolean to determine if the hostname should be changed

## Dependencies

This role requires an Ansible Vault file to securely store ESXi credentials. The Vault file must include the following variables:

```yaml
vault_esxi_username: 'root'
vault_esxi_password: 'password'
```

## Example Playbook

```yaml
---
- name: Run bootstrap_vmware_esxi_hostconfig
  hosts: all
  connection: local
  gather_facts: false

  vars_files:
    - secrets.yml  # This should contain the Ansible Vault encrypted variables

  roles:
    - role: bootstrap_vmware_esxi_hostconfig
      vars:
        dns_servers:
          - 1.1.1.1
          - 9.9.9.9
        ntp_servers:
          - 0.pool.ntp.org
          - 1.pool.ntp.org
        change_hostname: true
```

## License

This project is licensed under the MIT License.

## Author Information

This role was created by [Your Name or Organization].