---
title: "Bootstrap Linux Systemd Role"
role: bootstrap_linux_systemd
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_systemd]
---

# Bootstrap Linux Systemd Role

The `bootstrap_linux_systemd` role is designed to configure and manage various systemd components on a Linux system. This role provides a comprehensive set of tasks to deploy and manage configurations for systemd-journald, systemd-networkd, systemd-resolved, systemd-timesyncd, systemd-tmpfiles, and systemd-udev.

## Variables

| Variable Name                          | Default Value | Description                                                                 |
|----------------------------------------|---------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_systemd__tmpfiles`    | `[]`          | List of tmpfiles configurations to deploy.                                  |
| `bootstrap_linux_systemd__timesyncd`   | `[]`          | List of timesyncd configurations to deploy.                                 |
| `bootstrap_linux_systemd__journald_settings` | `[]`  | List of journald settings to deploy.                                       |
| `bootstrap_linux_systemd__udev`        | `[]`          | List of udev rules to deploy.                                              |
| `bootstrap_linux_systemd__vconsole`    | `[]`          | List of vconsole configurations to deploy.                                 |
| `bootstrap_linux_systemd__resolved`    | `[]`          | List of resolved configurations to deploy.                                 |
| `bootstrap_linux_systemd__networkd`    | `[]`          | List of networkd configurations to deploy.                                 |

## Usage

To use this role, include it in your playbook and define the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_systemd
      vars:
        bootstrap_linux_systemd__tmpfiles:
          - file_name: example-tmpfiles
            content: |
              d /path/to/directory 0755 root root 10d
        bootstrap_linux_systemd__timesyncd:
          - enable: true
            servers:
              - time.example.com
        bootstrap_linux_systemd__journald_settings:
          - setting: Storage
            value: persistent
        bootstrap_linux_systemd__udev:
          - file_name: example-udev
            content: |
              ACTION=="add", SUBSYSTEM=="net", NAME="eth0"
        bootstrap_linux_systemd__vconsole:
          - content: |
              KEYMAP=us
              FONT=latarcyrheb-sun16
        bootstrap_linux_systemd__resolved:
          - enable: true
            DNS:
              - 8.8.8.8
              - 8.8.4.4
        bootstrap_linux_systemd__networkd:
          - enable: true
            interfaces:
              - interface: eth0
                type: ether
                physaddr: 00:11:22:33:44:55
```

## Dependencies

This role requires the `community.general` collection for JSON query operations.

```yaml
collections:
  - community.general
```

## Best Practices

- Ensure that the system is using `systemd` as the service manager.
- Define all necessary configurations in the role's variables to avoid missing configurations.
- Review the default configurations and adjust them as needed for your environment.
- Test the role in a development environment before deploying it to production.
- Regularly review and update the role to accommodate changes in systemd or your infrastructure.
- Consider the security implications of each configuration change.
- Document any custom configurations for future reference and knowledge sharing.

## Idempotency

This role is designed to be idempotent, meaning it can be run multiple times without causing unintended side effects. The role checks the current state of the system before making any changes.

## Testing

The role includes tests to verify its functionality. You can run these tests using the provided test framework. It's recommended to run the tests in a development environment before deploying the role to production.

## Limitations

This role focuses on configuring systemd components and may not cover all possible use cases or advanced configurations. Some systemd components or features might not be supported or might require additional customization.

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