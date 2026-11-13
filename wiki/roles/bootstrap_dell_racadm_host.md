---
title: "Bootstrap Dell Racadm Host Role"
role: roles/bootstrap_dell_racadm_host
category: System Configuration
type: Role
tags: [ansible, role, bootstrap_dell_racadm_host]
---

# Bootstrap Dell RACADM Host Role

## Purpose

The `bootstrap_dell_racadm_host` role is designed to configure and manage Dell servers using RACADM commands. This role handles various aspects of server setup including RAID configuration, firmware updates, BIOS settings, and iDRAC configuration. It is particularly useful for automating the initial setup and ongoing maintenance of Dell servers in a data center environment.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_dell_racadm_host__ansible_user` | `root` | The user to run Ansible tasks with. |
| `bootstrap_dell_racadm_host__keystore_user` | `{{ bootstrap_dell_racadm_host__ansible_user }}` | The user to access the keystore. |
| `bootstrap_dell_racadm_host__ca_keystore_host` | `node01.example.int` | The host where the CA keystore is located. |
| `bootstrap_dell_racadm_host__ca_keystore_base_dir` | `/usr/share/ca-certs` | The base directory for the CA keystore. |
| `bootstrap_dell_racadm_host__racadm_raid_force` | `false` | Force RAID configuration. |
| `bootstrap_dell_racadm_host__racadm_fw_update_force` | `false` | Force firmware updates. |
| `bootstrap_dell_racadm_host__racadm_setup_bios` | `false` | Setup BIOS settings. |
| `bootstrap_dell_racadm_host__racadm_setup_idrac` | `true` | Setup iDRAC settings. |
| `bootstrap_dell_racadm_host__config_list` | `[]` | List of configuration items. |

## Usage

To use this role, include it in your playbook and set the necessary variables. Here's an example:

```yaml
- hosts: dell_servers
  roles:
    - role: bootstrap_dell_racadm_host
      vars:
        bootstrap_dell_racadm_host__racadm_raid_force: true
        bootstrap_dell_racadm_host__racadm_fw_update_force: true
        bootstrap_dell_racadm_host__racadm_setup_bios: true
        bootstrap_dell_racadm_host__racadm_setup_idrac: true
```

In this example:
- `bootstrap_dell_racadm_host__racadm_raid_force: true` forces RAID configuration
- `bootstrap_dell_racadm_host__racadm_fw_update_force: true` forces firmware updates
- `bootstrap_dell_racadm_host__racadm_setup_bios: true` sets up BIOS settings
- `bootstrap_dell_racadm_host__racadm_setup_idrac: true` sets up iDRAC settings

## Dependencies

This role requires the `racadm` command-line tool to be installed and accessible on the target servers. You can typically install it using the Dell Repository Manager or by downloading it from Dell's support website.

Additionally, it requires access to a CA keystore for certificate management.

## Best Practices

- Ensure that the `racadm` tool is installed and configured correctly on the target servers.
- Verify that the CA keystore is accessible and contains the necessary certificates.
- Test the role in a development environment before deploying it to production.
- Monitor the execution of the role to ensure that all tasks are completed successfully.
- Regularly update the role to accommodate changes in Dell's hardware or software.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_dell_racadm_host/defaults/main.yml)
- [tasks/get_cert_from_keyring.yml](../../roles/bootstrap_dell_racadm_host/tasks/get_cert_from_keyring.yml)
- [tasks/main.yml](../../roles/bootstrap_dell_racadm_host/tasks/main.yml)
- [tasks/racadm-setup-bios.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-bios.yml)
- [tasks/racadm-setup-fw-updates.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-fw-updates.yml)
- [tasks/racadm-setup-pxe-boot.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-pxe-boot.yml)
- [tasks/racadm-setup-raid-r620.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-raid-r620.yml)
- [tasks/racadm-setup-raid-r730.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-raid-r730.yml)
- [tasks/racadm-setup-idrac-settings.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-idrac-settings.yml)
- [tasks/setup_disks.yml](../../roles/bootstrap_dell_racadm_host/tasks/setup_disks.yml)