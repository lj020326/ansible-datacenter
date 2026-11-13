---
title: "Bootstrap Linux Networking Role"
role: bootstrap_linux_networking
category: Networking
type: Role
tags: [ansible, role, bootstrap_linux_networking]
---

# Bootstrap Linux Networking Role

This Ansible role is designed to configure and manage network interfaces on Linux systems. It supports various types of interfaces including Ethernet, bridge, bond, and VLAN interfaces. The role is compatible with both Debian-based and RedHat-based distributions.

## Variables

| Variable Name                           | Default Value | Description                                                                 |
|-----------------------------------------|---------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_network_pkgs`          | `[]`          | List of network-related packages to install                                |
| `bootstrap_linux_network_ether_interfaces` | `[]`          | List of Ethernet interfaces to configure                                   |
| `bootstrap_linux_network_bridge_interfaces` | `[]`          | List of bridge interfaces to configure                                     |
| `bootstrap_linux_network_bond_interfaces` | `[]`          | List of bond interfaces to configure                                       |
| `bootstrap_linux_network_vlan_interfaces` | `[]`          | List of VLAN interfaces to configure                                       |
| `bootstrap_linux_network_check_packages` | `true`        | Whether to check and install required packages                             |
| `bootstrap_linux_network_allow_service_restart` | `true`        | Whether to allow service restarts during configuration                      |
| `bootstrap_linux_network_modprobe_persist` | `false`       | Whether to persist modprobe settings                                        |

## Usage

To use this role, include it in your playbook and define the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_networking
      vars:
        bootstrap_linux_network_pkgs:
          - ifupdown
          - ifupdown2
        bootstrap_linux_network_ether_interfaces:
          - device: eth0
            ip: 192.168.1.10
            netmask: 255.255.255.0
            gateway: 192.168.1.1
        bootstrap_linux_network_bridge_interfaces:
          - name: br0
            members:
              - eth1
              - eth2
        bootstrap_linux_network_bond_interfaces:
          - name: bond0
            slaves:
              - eth2
              - eth3
            mode: active-backup
        bootstrap_linux_network_vlan_interfaces:
          - name: eth0.10
            vlan_id: 10
```

## Dependencies

This role does not have any external dependencies. It only requires Ansible to be installed on the control node.

## Best Practices

1. **Package Management**: Ensure that the required network packages are specified in `bootstrap_linux_network_pkgs`. This is crucial for the role to function correctly on different distributions.

2. **Interface Configuration**: Define all necessary interfaces in their respective variables. Be sure to include all required parameters for each interface type to avoid configuration issues.

3. **Service Restart**: Be cautious with `bootstrap_linux_network_allow_service_restart` as setting it to `true` can cause network interruptions during application. It's generally recommended to test with this set to `false` first.

4. **Testing**: Always test the configuration on a non-production environment before applying it to production systems. This helps catch any potential issues that could disrupt network connectivity.

5. **Documentation**: Keep your interface configurations documented, especially in complex setups involving bonds and bridges.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_networking/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_networking/tasks/main.yml)
- [tasks/restartscript.yml](../../roles/bootstrap_linux_networking/tasks/restartscript.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_linux_networking/tasks/setup-Debian.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_linux_networking/tasks/setup-RedHat.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_networking/handlers/main.yml)