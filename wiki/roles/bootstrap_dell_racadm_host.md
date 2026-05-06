---
title: "Bootstrap Dell RACADM Host Role"
role: bootstrap_dell_racadm_host
category: Ansible Roles
type: Configuration Management
tags: dell, racadm, ansible, idrac, bios, firmware, raid

---

## Summary

The `bootstrap_dell_racadm_host` role is designed to automate the configuration of Dell servers using RACADM (Remote Access Controller Administration Module). This includes setting up BIOS and iDRAC settings, managing RAID configurations, applying firmware updates, and handling SSL certificates. The role ensures that the server is configured according to specified parameters and can be customized through a set of user-configurable variables.

## Variables

| Variable Name                                      | Default Value                          | Description                                                                 |
|----------------------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_dell_racadm_host__ansible_user`         | `root`                                 | The Ansible user to use for executing tasks.                              |
| `bootstrap_dell_racadm_host__keystore_user`        | `"{{ bootstrap_dell_racadm_host__ansible_user }}"` | The user on the CA keystore host used to fetch certificates and keys.   |
| `bootstrap_dell_racadm_host__ca_keystore_host`     | `node01.example.int`                   | The hostname of the CA keystore server.                                   |
| `bootstrap_dell_racadm_host__ca_keystore_base_dir` | `/usr/share/ca-certs`                  | Base directory on the CA keystore host where certificates and keys are stored.|
| `bootstrap_dell_racadm_host__racadm_raid_force`    | `false`                                | Force RAID configuration setup.                                           |
| `bootstrap_dell_racadm_host__racadm_fw_update_force` | `false`                              | Force firmware update process.                                            |
| `bootstrap_dell_racadm_host__racadm_setup_bios`    | `false`                                | Setup BIOS settings.                                                      |
| `bootstrap_dell_racadm_host__racadm_setup_idrac`   | `true`                                 | Setup iDRAC settings.                                                     |
| `bootstrap_dell_racadm_host__config_list`          | `[]`                                   | List of configuration items to apply (not used in the provided tasks).    |

## Usage

To use this role, include it in your Ansible playbook and configure the necessary variables as per your requirements. Below is an example playbook snippet:

```yaml
- name: Configure Dell RACADM Host
  hosts: dell_servers
  roles:
    - role: bootstrap_dell_racadm_host
      vars:
        bootstrap_dell_racadm_host__racadm_raid_force: true
        bootstrap_dell_racadm_host__racadm_setup_idrac: true
```

## Dependencies

- `ansible.builtin` module for basic Ansible tasks.
- `community.general.filesystem` module for filesystem management.

Ensure that the required modules are available in your Ansible environment. The role assumes that RACADM is installed on the target hosts and accessible via the command line.

## Tags

The following tags can be used to selectively run parts of this role:

- `racadm-get-cert`: Fetch SSL certificates from the CA keystore.
- `racadm-setup-raid-r620`: Setup RAID configuration for PowerEdge R620 servers.
- `racadm-setup-raid-r730`: Setup RAID configuration for PowerEdge R730 servers.
- `racadm-setup-idrac-settings`: Configure iDRAC settings.
- `racadm-setup-bios`: Configure BIOS settings.
- `racadm-setup-fw-updates`: Apply firmware updates.

Example usage with tags:

```bash
ansible-playbook -i inventory playbook.yml --tags racadm-setup-idrac-settings,racadm-setup-fw-updates
```

## Best Practices

1. **Backup Configuration**: Always back up the current configuration before making changes.
2. **Test Changes**: Test configurations in a non-production environment before applying them to production servers.
3. **Monitor Jobs**: Monitor scheduled jobs and ensure they complete successfully.
4. **Review Logs**: Review Ansible logs for any errors or warnings that may indicate issues.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios to test the role's functionality in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_dell_racadm_host/defaults/main.yml)
- [tasks/get_cert_from_keyring.yml](../../roles/bootstrap_dell_racadm_host/tasks/get_cert_from_keyring.yml)
- [tasks/main.yml](../../roles/bootstrap_dell_racadm_host/tasks/main.yml)
- [tasks/racadm-setup-BIOS.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-BIOS.yml)
- [tasks/racadm-setup-FWupdates.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-FWupdates.yml)
- [tasks/racadm-setup-PXE-boot.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-PXE-boot.yml)
- [tasks/racadm-setup-RAID-r620.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-RAID-r620.yml)
- [tasks/racadm-setup-RAID-r730.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-RAID-r730.yml)
- [tasks/racadm-setup-iDRAC-settings.yml](../../roles/bootstrap_dell_racadm_host/tasks/racadm-setup-iDRAC-settings.yml)
- [tasks/setup_disks.yml](../../roles/bootstrap_dell_racadm_host/tasks/setup_disks.yml)