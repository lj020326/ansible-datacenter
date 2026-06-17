---
title: "Ansible Role - bootstrap_cloud_init"
role: bootstrap_cloud_init
category: System Configuration
type: Ansible Role
tags: cloud-init, system, configuration
---

## Summary

The `bootstrap_cloud_init` Ansible role is designed to install, configure, and clean up the `cloud-init` service on various Linux distributions. This role ensures that `cloud-init` is properly set up according to specified configurations, which can include user management, package installation, and system customization.

## Variables

| Variable Name                | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cloud_init_clean`           | `false`                                                                                             | If `true`, the role will attempt to clean up existing cloud-init configurations and logs.                                                                                                                   |
| `cloud_init_config`          | `false`                                                                                             | If `true`, the role will configure `/etc/cloud/cloud.cfg` using a provided template.                                                                                                                      |
| `cloud_init_configuration`   | `{ groups: [], users: [], datasource_list: ['None'], datasource: [], cloud_init_modules: [...], cloud_config_modules: [...], cloud_final_modules: [...], packages: [] }` | A dictionary containing various configurations for `cloud-init`, including user and group management, data sources, modules to run at different stages, and package installations.                             |
| `cloud_init_configuration.groups` | `[]`                                                                                           | List of groups to be configured by `cloud-init`.                                                                                                                                                            |
| `cloud_init_configuration.users`  | `[]`                                                                                            | List of users to be configured by `cloud-init`.                                                                                                                                                             |
| `cloud_init_configuration.datasource_list` | `['None']`                                                                             | List of data sources for `cloud-init` to use.                                                                                                                                                               |
| `cloud_init_configuration.datasource` | `[]`                                                                                         | Additional configuration for specific data sources.                                                                                                                                                         |
| `cloud_init_configuration.cloud_init_modules` | `[migrator, seed_random, bootcmd, write-files, growpart, resizefs, disk_setup, mounts, set_hostname, update_hostname, update_etc_hosts, ca-certs, rsyslog, users-groups, ssh]` | List of modules to run during the initial stage of `cloud-init`.                                                                                                                                            |
| `cloud_init_configuration.cloud_config_modules` | `[emit_upstart, snap_config, ssh-import-id, locale, set-passwords, grub-dpkg, apt-pipelining, apt-configure, ntp, timezone, disable-ec2-metadata, runcmd, byobu]` | List of modules to run during the configuration stage of `cloud-init`.                                                                                                                                      |
| `cloud_init_configuration.cloud_final_modules` | `[snappy, package-update-upgrade-install, fan, landscape, lxd, puppet, chef, salt-minion, mcollective, rightscale_userdata, scripts-vendor, scripts-per-once, scripts-per-boot, scripts-per-instance, scripts-user, ssh-authkey-fingerprints, keys-to-console, phone-home, final-message, power-state-change]` | List of modules to run during the final stage of `cloud-init`.                                                                                                                                                |
| `cloud_init_configuration.packages` | `[]`                                                                                           | List of packages to be installed by `cloud-init`.                                                                                                                                                           |

## Usage

To use this role, include it in your playbook and set any necessary variables. Here is an example playbook:

```yaml
---
- name: Bootstrap cloud-init on target hosts
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
            - name: myuser
              groups: sudo
              shell: /bin/bash
          packages:
            - vim
```

## Dependencies

This role has no external dependencies.

## Best Practices

- Ensure that the `cloud_init_clean` and `cloud_init_config` variables are set appropriately based on your environment.
- Customize the `cloud_init_configuration` dictionary to match your specific requirements for user management, data sources, modules, and package installations.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios to ensure the role functions as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_cloud_init/defaults/main.yml)
- [tasks/clean.yml](../../roles/bootstrap_cloud_init/tasks/clean.yml)
- [tasks/config.yml](../../roles/bootstrap_cloud_init/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_cloud_init/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_cloud_init/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_cloud_init/tasks/service.yml)
- [meta/main.yml](../../roles/bootstrap_cloud_init/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_cloud_init/handlers/main.yml)