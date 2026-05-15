---
title: Bootstrap Linux Systemd Role Documentation
role: bootstrap_linux_systemd
category: System Configuration
type: Ansible Role
tags: systemd, journald, timesyncd, resolved, networkd, udev, vconsole, tmpfiles
---

## Summary

The `bootstrap_linux_systemd` role is designed to configure various aspects of the systemd system and service manager on Linux systems. It handles configurations for services such as `journald`, `timesyncd`, `resolved`, `networkd`, `udev`, `vconsole`, and `tmpfiles`. This role ensures that these systemd components are properly set up according to user-defined variables, enhancing system management and automation.

## Variables

| Variable Name                         | Default Value  | Description                                                                 |
|---------------------------------------|----------------|-----------------------------------------------------------------------------|
| bootstrap_linux_systemd__tmpfiles     | []             | List of tmpfiles configurations.                                          |
| bootstrap_linux_systemd__timesyncd    | []             | List of timesyncd configurations.                                         |
| bootstrap_linux_systemd__journald_settings | []        | List of journald settings configurations.                                 |
| bootstrap_linux_systemd__udev         | []             | List of udev rules configurations.                                        |
| bootstrap_linux_systemd__vconsole     | []             | Configuration for vconsole settings.                                      |
| bootstrap_linux_systemd__resolved     | []             | List of resolved configurations.                                          |
| bootstrap_linux_systemd__networkd     | []             | List of networkd configurations, including interfaces and network settings. |

## Usage

To use the `bootstrap_linux_systemd` role, include it in your playbook and define the necessary variables as per your requirements. Below is an example playbook that demonstrates how to configure some of the systemd components:

```yaml
---
- name: Bootstrap Linux Systemd Configuration
  hosts: all
  become: yes
  roles:
    - role: bootstrap_linux_systemd
      vars:
        bootstrap_linux_systemd__journald_settings:
          - Storage: persistent
            Compress: yes
        bootstrap_linux_systemd__timesyncd:
          - NTP: ntp.example.com
            FallbackNTP: pool.ntp.org
        bootstrap_linux_systemd__resolved:
          - DNS: 8.8.8.8 8.8.4.4
            Domains: example.com
        bootstrap_linux_systemd__networkd:
          - interfaces:
              - interface: eth0
                type: ether
                physaddr: 00:1A:2B:3C:4D:5E
```

## Dependencies

This role does not have any external dependencies. However, it requires that the target system uses `systemd` as its init system.

## Tags

- `journald`: Configures journald settings.
- `timesyncd`: Configures timesyncd settings.
- `resolved`: Configures resolved settings.
- `networkd`: Configures networkd settings, including interfaces and network configurations.
- `udev`: Configures udev rules.
- `vconsole`: Configures vconsole settings.
- `tmpfiles`: Configures tmpfiles settings.

## Best Practices

1. **Use Tags**: Utilize tags to target specific systemd components for configuration, which can speed up playbook execution when only certain services need adjustment.
2. **Define Variables Clearly**: Ensure that all variables are clearly defined in your inventory or playbook to avoid misconfigurations.
3. **Test Configurations**: Use Molecule tests (if available) to verify the role's functionality and configurations before deploying it to production environments.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to create test scenarios using Molecule to ensure that the role behaves as expected across different Linux distributions and versions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_systemd/defaults/main.yml)
- [tasks/deploy_journald.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_journald.yml)
- [tasks/deploy_modules_load.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_modules_load.yml)
- [tasks/deploy_networkd.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd.yml)
- [tasks/deploy_networkd_interfaces_generic.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces_generic.yml)
- [tasks/deploy_networkd_interfaces_macvlan.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces_macvlan.yml)
- [tasks/deploy_networkd_interfaces_prereq.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces_prereq.yml)
- [tasks/deploy_networkd_interfaces_vlan.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces_vlan.yml)
- [tasks/deploy_networkd_interfaces_vlan_macvlan.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces_vlan_macvlan.yml)
- [tasks/deploy_networkd_interfaces.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_networkd_interfaces.yml)
- [tasks/deploy_resolved.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_resolved.yml)
- [tasks/deploy_timesyncd.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_timesyncd.yml)
- [tasks/deploy_tmpfiles.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_tmpfiles.yml)
- [tasks/deploy_udev.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_udev.yml)
- [tasks/deploy_vconsole.yml](../../roles/bootstrap_linux_systemd/tasks/deploy_vconsole.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_systemd/tasks/main.yml)
- [tasks/modules_load_executor.yml](../../roles/bootstrap_linux_systemd/tasks/modules_load_executor.yml)
- [tasks/networkd_executor.yml](../../roles/bootstrap_linux_systemd/tasks/networkd_executor.yml)
- [tasks/pre_requisite.yml](../../roles/bootstrap_linux_systemd/tasks/pre_requisite.yml)
- [tasks/prereq_systemd_modules_load.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_modules_load.yml)
- [tasks/prereq_systemd_networkd.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_networkd.yml)
- [tasks/prereq_systemd_resolved.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_resolved.yml)
- [tasks/prereq_systemd_timedatectl.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_timedatectl.yml)
- [tasks/prereq_systemd_tmpfilesd.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_tmpfilesd.yml)
- [tasks/prereq_systemd_udev.yml](../../roles/bootstrap_linux_systemd/tasks/prereq_systemd_udev.yml)
- [tasks/tmpfiles_executor.yml](../../roles/bootstrap_linux_systemd/tasks/tmpfiles_executor.yml)
- [tasks/udev_executor.yml](../../roles/bootstrap_linux_systemd/tasks/udev_executor.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_systemd/handlers/main.yml)