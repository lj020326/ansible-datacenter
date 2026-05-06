---
title: "Ansible Role - bootstrap_cloud_init"
role: "bootstrap_cloud_init"
category: "System Configuration"
type: "Role"
tags: ["cloud-init", "system", "configuration"]
---

## Summary

The `bootstrap_cloud_init` Ansible role is designed to install, configure, and clean up the cloud-init service on various Linux distributions. This role ensures that cloud-init is properly set up according to specified configurations, which can include user management, package installation, and system customization.

## Variables

| Variable Name                  | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|--------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cloud_init_clean`             | `false`                                                                                           | If set to `true`, the role will attempt to clean up existing cloud-init configurations and logs.                                                                                                             |
| `cloud_init_config`            | `false`                                                                                           | If set to `true`, the role will configure `/etc/cloud/cloud.cfg` using a template file.                                                                                                                   |
| `cloud_init_configuration`     | `{ groups: [], users: [], datasource_list: ['None'], datasource: [], cloud_init_modules: [...], cloud_config_modules: [...], cloud_final_modules: [...], packages: [] }` | A dictionary containing detailed configuration options for cloud-init, including user and group management, data sources, modules to run at different stages, and package installations.                            |
| `cloud_init_configuration.groups` | `[]`                                                                                             | List of groups to be configured in the cloud-init setup.                                                                                                                                                      |
| `cloud_init_configuration.users`  | `[]`                                                                                             | List of users to be configured in the cloud-init setup.                                                                                                                                                       |
| `cloud_init_configuration.datasource_list` | `['None']`                                                                                 | List of data sources to prioritize during cloud-init execution.                                                                                                                                             |
| `cloud_init_configuration.datasource` | `[]`                                                                                            | Additional configuration for specific data sources.                                                                                                                                                         |
| `cloud_init_configuration.cloud_init_modules` | `[migrator, seed_random, bootcmd, write-files, growpart, resizefs, disk_setup, mounts, set_hostname, update_hostname, update_etc_hosts, ca-certs, rsyslog, users-groups, ssh]` | List of modules to run during the initial stages of cloud-init.                                                                                                                                             |
| `cloud_init_configuration.cloud_config_modules` | `[emit_upstart, snap_config, ssh-import-id, locale, set-passwords, grub-dpkg, apt-pipelining, apt-configure, ntp, timezone, disable-ec2-metadata, runcmd, byobu]` | List of modules to run during the configuration stage of cloud-init.                                                                                                                                        |
| `cloud_init_configuration.cloud_final_modules` | `[snappy, package-update-upgrade-install, fan, landscape, lxd, puppet, chef, salt-minion, mcollective, rightscale_userdata, scripts-vendor, scripts-per-once, scripts-per-boot, scripts-per-instance, scripts-user, ssh-authkey-fingerprints, keys-to-console, phone-home, final-message, power-state-change]` | List of modules to run during the final stages of cloud-init.                                                                                                                                             |
| `cloud_init_configuration.packages` | `[]`                                                                                            | List of packages to be installed as part of the cloud-init configuration.                                                                                                                                   |

## Usage

To use this role, include it in your playbook and set any necessary variables as required. Here is an example playbook that demonstrates how to use the role:

```yaml
---
- name: Bootstrap Cloud Init Configuration
  hosts: all
  become: true
  roles:
    - role: bootstrap_cloud_init
      vars:
        cloud_init_clean: true
        cloud_init_config: true
        cloud_init_configuration:
          groups:
            - mygroup
          users:
            - default
          datasource_list:
            - Ec2
            - ConfigDrive
          packages:
            - vim
```

## Dependencies

This role has no external dependencies.

## Tags

- `install`: Installs the cloud-init package.
- `config`: Configures `/etc/cloud/cloud.cfg` using a template file.
- `clean`: Cleans up existing cloud-init configurations and logs.
- `service`: Enables the cloud-init service.

## Best Practices

- Ensure that the variables provided in `cloud_init_configuration` are tailored to your specific environment requirements.
- Use tags to selectively run parts of the role, such as only cleaning up or configuring cloud-init without reinstalling it.
- Test the role on a non-production system before applying it to production environments.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios for testing different configurations and use cases.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_cloud_init/defaults/main.yml)
- [tasks/clean.yml](../../roles/bootstrap_cloud_init/tasks/clean.yml)
- [tasks/config.yml](../../roles/bootstrap_cloud_init/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_cloud_init/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_cloud_init/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_cloud_init/tasks/service.yml)
- [meta/main.yml](../../roles/bootstrap_cloud_init/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_cloud_init/handlers/main.yml)