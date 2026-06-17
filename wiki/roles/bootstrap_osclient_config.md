---
title: "bootstrap_osclient_config Role Documentation"
role: bootstrap_osclient_config
category: Ansible Roles
type: Configuration
tags: openstack-client, osclient-config, clouds.yaml, openrc
---

## Summary

The `bootstrap_osclient_config` role is designed to configure OpenStack client authentication settings by creating and setting up the necessary configuration files (`openrc` and `clouds.yaml`). This role reads credentials from a specified file, creates the required directories, and generates the configuration files with appropriate permissions. The configurations are tailored for internal URLs and secure connections as defined by the variables.

## Variables

| Variable Name                           | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-----------------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `openstack_kolla_internal_vip_address`  | `"10.1.0.250"`                                                                                | The internal VIP address for OpenStack services.                                                                                                                                                            |
| `openrc_cinder_endpoint_type`           | `internalURL`                                                                                 | Endpoint type for Cinder service in the `openrc` file.                                                                                                                                                    |
| `openrc_nova_endpoint_type`             | `internalURL`                                                                                 | Endpoint type for Nova service in the `openrc` file.                                                                                                                                                      |
| `openrc_manila_endpoint_type`           | `internalURL`                                                                                 | Endpoint type for Manila service in the `openrc` file.                                                                                                                                                    |
| `openrc_os_endpoint_type`               | `internalURL`                                                                                 | General endpoint type for OpenStack services in the `openrc` file.                                                                                                                                        |
| `openrc_clouds_yml_interface`           | `internal`                                                                                    | Interface type used in the `clouds.yaml` configuration file.                                                                                                                                                |
| `openstack_cloud_name`                  | `default`                                                                                     | Name of the OpenStack cloud to be configured in `clouds.yaml`.                                                                                                                                            |
| `openrc_os_username`                    | `admin`                                                                                       | Username for authentication with OpenStack services.                                                                                                                                                      |
| `openrc_os_tenant_name`                 | `admin`                                                                                       | Tenant name (project) for authentication with OpenStack services.                                                                                                                                         |
| `openrc_os_auth_type`                   | `password`                                                                                    | Authentication type used in the `openrc` file.                                                                                                                                                            |
| `openrc_os_auth_url`                    | `"http://{{openstack_kolla_internal_vip_address}}:5000"`                                       | Authentication URL for OpenStack services, dynamically set based on `openstack_kolla_internal_vip_address`.                                                                                               |
| `openrc_os_user_domain_name`            | `Default`                                                                                     | User domain name used in the `openrc` file.                                                                                                                                                                 |
| `openrc_os_project_domain_name`         | `Default`                                                                                     | Project domain name used in the `openrc` file.                                                                                                                                                              |
| `openrc_region_name`                    | `RegionOne`                                                                                   | Region name for OpenStack services.                                                                                                                                                                         |
| `openrc_insecure`                       | >-<br>{{ (keystone_service_adminuri_insecure \| d(false) \| bool or<br>keystone_service_internaluri_insecure \| d(false) \| bool) }}                           | Boolean flag to allow insecure connections if set to true, dynamically determined based on other variables.                                                                                                 |
| `openrc_file_dest`                      | `"{{ ansible_facts.env.HOME }}/openrc"`                                                        | Destination path for the `openrc` file.                                                                                                                                                                     |
| `openrc_file_owner`                     | `"{{ ansible_user_id }}"`                                                                       | Owner of the `openrc` file, set to the current user ID.                                                                                                                                                   |
| `openrc_file_group`                     | `"{{ ansible_user_id }}"`                                                                       | Group owner of the `openrc` file, set to the current user ID.                                                                                                                                             |
| `openrc_file_mode`                      | `"0600"`                                                                                      | Permissions mode for the `openrc` file.                                                                                                                                                                     |
| `openstack_osclient_config_dir_dest`    | `"{{ ansible_facts.env.HOME }}/.config/openstack"`                                            | Destination path for the OpenStack client configuration directory.                                                                                                                                          |
| `openstack_osclient_config_dir_owner`   | `"{{ ansible_user_id }}"`                                                                       | Owner of the OpenStack client configuration directory, set to the current user ID.                                                                                                                        |
| `openstack_osclient_config_dir_group`   | `"{{ ansible_user_id }}"`                                                                       | Group owner of the OpenStack client configuration directory, set to the current user ID.                                                                                                                    |
| `openstack_osclient_config_dir_mode`    | `"0700"`                                                                                      | Permissions mode for the OpenStack client configuration directory.                                                                                                                                          |
| `openrc_clouds_yml_file_dest`           | `"{{ openstack_osclient_config_dir_dest }}/clouds.yaml"`                                        | Destination path for the `clouds.yaml` file.                                                                                                                                                                |
| `openrc_clouds_yml_file_owner`          | `"{{ ansible_user_id }}"`                                                                       | Owner of the `clouds.yaml` file, set to the current user ID.                                                                                                                                                |
| `openrc_clouds_yml_file_group`          | `"{{ ansible_user_id }}"`                                                                       | Group owner of the `clouds.yaml` file, set to the current user ID.                                                                                                                                          |
| `openrc_clouds_yml_file_mode`           | `"0600"`                                                                                      | Permissions mode for the `clouds.yaml` file.                                                                                                                                                                |
| `openrc_locale`                         | `"{{ ansible_facts.env.LANG \| d('C.UTF-8') }}"`                                                 | Locale setting for the environment, defaults to the system's LANG variable or 'C.UTF-8' if not set.                                                                                                         |

## Usage

To use this role, include it in your playbook and ensure that the required variables are set as needed. Here is an example of how you might include this role in a playbook:

```yaml
---
- name: Configure OpenStack client authentication settings
  hosts: all
  roles:
    - role: bootstrap_osclient_config
      vars:
        openstack_kolla_internal_vip_address: "10.1.0.250"
        openrc_os_username: "admin"
        openrc_os_tenant_name: "admin"
```

## Dependencies

This role depends on the `bootstrap_osclient` role, which is included to read OpenStack credentials from a specified file and store them in a fact.

## Best Practices

- Always ensure that sensitive information such as passwords are stored securely and not exposed in plain text.
- Use Ansible Vault or other secure methods to manage sensitive variables.
- Customize the `openrc_insecure` variable only if necessary, as allowing insecure connections can pose security risks.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure that the role behaves as expected in various environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_osclient_config/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_osclient_config/tasks/main.yml)