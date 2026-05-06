---
title: Bootstrap OpenStack Cloud Role Documentation
role: bootstrap_openstack_cloud
category: Ansible Roles
type: Infrastructure as Code (IaC)
tags: openstack, ansible, automation, cloud-setup
---

## Summary

The `bootstrap_openstack_cloud` role is designed to automate the setup of an OpenStack environment. It handles various tasks such as creating flavors, uploading images, configuring projects and users, setting up access controls including security groups, managing networks and subnets, and starting instances.

## Variables

| Variable Name                             | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ansible_local_user`                      | `{{ lookup('env', 'USER') }}`                                                                     | The local user running the Ansible playbook. Defaults to the current environment user.                                                                                                                      |
| `openstack_images_dir`                    | `{{ '~/images' \| expanduser }}`                                                                  | Directory where OpenStack images will be stored locally before uploading them to Glance.                                                                                                                    |
| `openstack_ssh_public_key_file`           | `{{ '~' \| expanduser }}/.ssh/id_rsa.pub`                                                         | Path to the SSH public key file that will be uploaded to Nova as a keypair.                                                                                                                                |
| `openstack_images`                        | List of image definitions (see below)                                                             | A list of images to download and upload to Glance. Each item includes `name`, `filename`, `url`, and optionally `container_format` and `disk_format`.                                                      |
| `openstack_image_flavors`                 | List of flavor definitions (see below)                                                            | A list of compute flavors to create in OpenStack, each defined by `ram`, `disk`, `vcpus`, and `name`.                                                                                                    |
| `openstack_cloud_networks`                | List of network definitions (see below)                                                           | A list of networks to create in OpenStack, including `name`, `external`, and `shared` flags.                                                                                                              |
| `openstack_admin_cloud_name`              | `default`                                                                                         | The name of the admin cloud configuration used for authentication and authorization tasks.                                                                                                                  |
| `openstack_cloud_projects`                | List of project definitions (see below)                                                           | A list of projects to configure in OpenStack, including details like `name`, `description`, `domain_id`, quotas, and users with roles.                                                                   |

### Example `openstack_images`
```yaml
- name: centos-7-atomic
  filename: centos-7-atomic.qcow2
  url: http://cloud.centos.org/centos/7/atomic/images/CentOS-Atomic-Host-7-GenericCloud.qcow2
```

### Example `openstack_image_flavors`
```yaml
- { ram: 256, disk: 1, vcpus: 1, name: m1.nano }
```

### Example `openstack_cloud_networks`
```yaml
- name: testnet
  external: false
  shared: false
```

### Example `openstack_cloud_projects`
```yaml
- name: demo123
  description: demo project
  domain_id: default
  quota_cores: 20
  quota_instances: 10
  quota_ram: 40960
  users:
    - login: demo_user
      email: demo@centos.org
      password: Ch@ngeM3
      role: admin # can be _member_ or admin
```

## Usage

To use the `bootstrap_openstack_cloud` role, include it in your playbook and provide the necessary variables as shown below:

```yaml
- hosts: localhost
  gather_facts: false
  roles:
    - role: bootstrap_openstack_cloud
      vars:
        openstack_images_dir: /path/to/images
        openstack_ssh_public_key_file: /path/to/id_rsa.pub
```

## Dependencies

This role depends on the `openstack.cloud` collection, which must be installed before running the playbook. You can install it using:

```bash
ansible-galaxy collection install openstack.cloud
```

## Best Practices

- Ensure that the OpenStack environment is properly configured and accessible with the provided credentials.
- Use strong passwords for users and consider encrypting sensitive information in your Ansible inventory or vault.
- Regularly update the images and flavors to match the latest requirements of your infrastructure.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding them to ensure the reliability and maintainability of the role.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_openstack_cloud/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_openstack_cloud/tasks/main.yml)
- [tasks/setup-access.yml](../../roles/bootstrap_openstack_cloud/tasks/setup-access.yml)
- [tasks/setup-images.yml](../../roles/bootstrap_openstack_cloud/tasks/setup-images.yml)
- [tasks/setup-instances.yml](../../roles/bootstrap_openstack_cloud/tasks/setup-instances.yml)
- [tasks/setup-networks.yml](../../roles/bootstrap_openstack_cloud/tasks/setup-networks.yml)
- [tasks/setup-projects.yml](../../roles/bootstrap_openstack_cloud/tasks/setup-projects.yml)