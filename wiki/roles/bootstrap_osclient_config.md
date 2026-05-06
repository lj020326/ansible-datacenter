---
title: "bootstrap_osclient_config Role Documentation"
role: bootstrap_osclient_config
category: Ansible Roles
type: Configuration
tags: openstack-client, osclient-config, clouds.yaml, openrc
---

## Summary

The `bootstrap_osclient_config` role is designed to configure OpenStack client authentication settings by creating and setting up the necessary configuration files (`openrc` and `clouds.yaml`). This role reads credentials from a specified file (typically `/etc/kolla/admin-openrc.sh`) and uses them to populate these configuration files, ensuring that they are correctly formatted and securely stored in the user's home directory.

## Variables

| Variable Name                          | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `openstack_kolla_internal_vip_address` | `"10.1.0.250"`                                                                                        | The internal VIP address for the OpenStack services.                                                                                                                                                        |
| `openrc_cinder_endpoint_type`          | `internalURL`                                                                                         | The endpoint type to use for Cinder in the `clouds.yaml` file.                                                                                                                                            |
| `openrc_nova_endpoint_type`            | `internalURL`                                                                                         | The endpoint type to use for Nova in the `clouds.yaml` file.                                                                                                                                              |
| `openrc_manila_endpoint_type`          | `internalURL`                                                                                         | The endpoint type to use for Manila in the `clouds.yaml` file.                                                                                                                                            |
| `openrc_os_endpoint_type`              | `internalURL`                                                                                         | The endpoint type to use for OpenStack services in the `clouds.yaml` file.                                                                                                                                |
| `openrc_clouds_yml_interface`          | `internal`                                                                                            | The interface to use for endpoints in the `clouds.yaml` file.                                                                                                                                             |
| `openstack_cloud_name`                 | `default`                                                                                             | The name of the OpenStack cloud configuration.                                                                                                                                                            |
| `openrc_os_username`                   | `admin`                                                                                               | The username for authentication with OpenStack services.                                                                                                                                                |
| `openrc_os_tenant_name`                | `admin`                                                                                               | The tenant (project) name for authentication with OpenStack services.                                                                                                                                     |
| `openrc_os_auth_type`                  | `password`                                                                                            | The type of authentication to use with OpenStack services.                                                                                                                                              |
| `openrc_os_auth_url`                   | `"http://{{openstack_kolla_internal_vip_address}}:5000"`                                               | The URL for the OpenStack Identity service (Keystone).                                                                                                                                                    |
| `openrc_os_user_domain_name`           | `Default`                                                                                             | The user domain name for authentication with OpenStack services.                                                                                                                                          |
| `openrc_os_project_domain_name`        | `Default`                                                                                             | The project domain name for authentication with OpenStack services.                                                                                                                                       |
| `openrc_region_name`                   | `RegionOne`                                                                                           | The region name for the OpenStack deployment.                                                                                                                                                             |
| `openrc_insecure`                      | >-<br>{{ (keystone_service_adminuri_insecure \| d(false) \| bool or<br>keystone_service_internaluri_insecure \| d(false) \| bool) }} | A boolean indicating whether to allow insecure connections to the OpenStack services.                                                                                                                     |
| `openrc_file_dest`                     | `"{{ ansible_env.HOME }}/openrc"`                                                                      | The destination path for the `openrc` file.                                                                                                                                                               |
| `openrc_file_owner`                    | `"{{ ansible_user_id }}"`                                                                             | The owner of the `openrc` file.                                                                                                                                                                           |
| `openrc_file_group`                    | `"{{ ansible_user_id }}"`                                                                             | The group ownership of the `openrc` file.                                                                                                                                                                 |
| `openrc_file_mode`                     | `"0600"`                                                                                              | The permissions mode for the `openrc` file.                                                                                                                                                               |
| `openstack_osclient_config_dir_dest`   | `"{{ ansible_env.HOME }}/.config/openstack"`                                                          | The destination path for the OpenStack client configuration directory.                                                                                                                                    |
| `openstack_osclient_config_dir_owner`  | `"{{ ansible_user_id }}"`                                                                             | The owner of the OpenStack client configuration directory.                                                                                                                                              |
| `openstack_osclient_config_dir_group`  | `"{{ ansible_user_id }}"`                                                                             | The group ownership of the OpenStack client configuration directory.                                                                                                                                        |
| `openstack_osclient_config_dir_mode`   | `"0700"`                                                                                              | The permissions mode for the OpenStack client configuration directory.                                                                                                                                    |
| `openrc_clouds_yml_file_dest`          | `"{{ openstack_osclient_config_dir_dest }}/clouds.yaml"`                                               | The destination path for the `clouds.yaml` file.                                                                                                                                                          |
| `openrc_clouds_yml_file_owner`         | `"{{ ansible_user_id }}"`                                                                             | The owner of the `clouds.yaml` file.                                                                                                                                                                      |
| `openrc_clouds_yml_file_group`         | `"{{ ansible_user_id }}"`                                                                             | The group ownership of the `clouds.yaml` file.                                                                                                                                                            |
| `openrc_clouds_yml_file_mode`          | `"0600"`                                                                                              | The permissions mode for the `clouds.yaml` file.                                                                                                                                                          |
| `openrc_locale`                        | `"{{ ansible_facts.env.LANG \| d('C.UTF-8') }}"`                                                        | The locale setting to use in the `openrc` file, defaulting to the system's LANG environment variable or 'C.UTF-8' if not set.                                                                              |

## Usage

To use the `bootstrap_osclient_config` role, include it in your playbook and ensure that the required variables are set appropriately. Here is an example of how to include this role in a playbook:

```yaml
---
- name: Configure OpenStack client authentication settings
  hosts: localhost
  gather_facts: true
  roles:
    - role: bootstrap_osclient_config
      vars:
        openstack_kolla_internal_vip_address: "10.1.0.250"
        openrc_os_username: "admin"
        openrc_os_tenant_name: "admin"
```

## Dependencies

This role depends on the `bootstrap_osclient` role, which is used to read OpenStack credentials from a specified file and store them in a fact variable.

- **Role:** bootstrap_osclient

## Best Practices

1. **Secure Credentials:** Ensure that the `openrc` and `clouds.yaml` files are stored with appropriate permissions (`0600`) to prevent unauthorized access.
2. **Environment Variables:** Use environment variables or Ansible facts to dynamically set values like `openstack_kolla_internal_vip_address` and `openrc_os_auth_url`.
3. **Customization:** Customize the role variables as needed for your specific OpenStack deployment, such as changing endpoint types or region names.

## Molecule Tests

This role does not currently include Molecule tests. However, it is recommended to add molecule scenarios to ensure that the role functions correctly across different environments and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_osclient_config/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_osclient_config/tasks/main.yml)