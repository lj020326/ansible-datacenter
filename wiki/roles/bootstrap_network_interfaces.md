---
title: "Bootstrap Network Interfaces Role"
role: bootstrap_network_interfaces
category: Networking
type: Ansible Role
tags: network, interfaces, bonds, bridges, vlans, ovs
---

## Summary

The `bootstrap_network_interfaces` role is designed to configure network interfaces, bonds, bridges, VLANs, and Open vSwitch (OVS) components on Debian and RedHat-based systems. It installs necessary packages, configures the specified network entities, and optionally restarts them based on user-defined parameters.

## Variables

| Variable Name                             | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_network_interfaces__interface_template` | `etc/network/interfaces.j2`                                                   | The Jinja2 template used to configure network interfaces. This variable is internal and should not be overridden by users.                                                                                 |
| `dns_nameservers`                         | `['8.8.8.8', '8.8.4.4']`                                                      | A list of DNS nameservers to be configured on the system.                                                                                                                                                   |
| `dns_search`                              | `"{{ pri_domain_name }}"`                                                     | The domain name used for DNS search. Defaults to the value of `pri_domain_name`.                                                                                                                            |
| `enable_configured_interfaces_after_defining` | `false`                                                                       | If set to `true`, the role will restart all configured network interfaces, bonds, bridges, VLANs, and OVS components after defining them.                                                                   |
| `network_bonds`                           | `[]`                                                                          | A list of bond configurations. Each item should be a dictionary with details about the bond interface (e.g., name, mode, slaves).                                                                            |
| `network_bridges`                         | `[]`                                                                          | A list of bridge configurations. Each item should be a dictionary with details about the bridge interface (e.g., name, ports).                                                                              |
| `network_interfaces`                      | `[]`                                                                          | A list of network interface configurations. Each item should be a dictionary with details about the interface (e.g., name, ip_address, netmask).                                                            |
| `network_vlans`                           | `[]`                                                                          | A list of VLAN configurations. Each item should be a dictionary with details about the VLAN interface (e.g., name, vlan_id, physical_interface).                                                              |
| `ovs_bonds`                               | `[]`                                                                          | A list of OVS bond configurations. Each item should be a dictionary with details about the OVS bond interface (e.g., name, mode, slaves).                                                                  |
| `ovs_bridges`                             | `[]`                                                                          | A list of OVS bridge configurations. Each item should be a dictionary with details about the OVS bridge interface (e.g., name, ports).                                                                      |
| `ovs_interfaces`                          | `[]`                                                                          | A list of OVS interface configurations. Each item should be a dictionary with details about the OVS interface (e.g., name, ip_address, netmask).                                                            |
| `pri_domain_name`                         | `"example.org"`                                                               | The primary domain name used for DNS search and other network configurations.                                                                                                                               |
| `config_install_lldp`                     | `true`                                                                        | If set to `true`, the role will install LLDP (Link Layer Discovery Protocol) packages on the system.                                                                                                       |

## Usage

To use this role, include it in your playbook and define the necessary variables as per your network configuration requirements. Below is an example of how to configure a simple bond interface on a Debian-based system:

```yaml
- hosts: all
  roles:
    - role: bootstrap_network_interfaces
      vars:
        bootstrap_network_interfaces__network_bonds: true
        network_bonds:
          - name: bond0
            mode: active-backup
            slaves: [eth0, eth1]
```

For RedHat-based systems, the configuration is similar but uses different templates and package names. Here's an example of configuring a VLAN:

```yaml
- hosts: all
  roles:
    - role: bootstrap_network_interfaces
      vars:
        bootstrap_network_interfaces__network_vlans: true
        network_vlans:
          - name: vlan10
            vlan_id: 10
            physical_interface: eth0
```

## Dependencies

- `community.general` Ansible collection (for RedHat-based systems to enable bonding and bridging modules).

Ensure that the required collections are installed:

```bash
ansible-galaxy collection install community.general
```

## Tags

This role does not define any specific tags. However, you can use the default Ansible tags such as `always`, `never`, or custom tags if needed.

## Best Practices

- Always back up your current network configuration before applying changes.
- Test configurations in a non-production environment to ensure they work as expected.
- Use variables to parameterize your network configurations for better reusability and maintainability.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to write and run tests to validate the role's functionality across different operating systems and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_network_interfaces/defaults/main.yml)
- [tasks/debian.yml](../../roles/bootstrap_network_interfaces/tasks/debian.yml)
- [tasks/main.yml](../../roles/bootstrap_network_interfaces/tasks/main.yml)
- [tasks/redhat.yml](../../roles/bootstrap_network_interfaces/tasks/redhat.yml)
- [handlers/main.yml](../../roles/bootstrap_network_interfaces/handlers/main.yml)