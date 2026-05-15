---
title: Deploy Authorized Keys Role Documentation
role: deploy_authorized_keys
category: Ansible Roles
type: Configuration Management
tags: ansible, ssh, authorized_keys
---

## Summary

The `deploy_authorized_keys` role is designed to manage SSH authorized keys for specified users on target hosts. It leverages the `ansible.posix.authorized_key` module to ensure that the provided SSH public key is correctly deployed and managed in the user's `.ssh/authorized_keys` file.

## Variables

| Variable Name                | Default Value | Description                                                                 |
|------------------------------|---------------|-----------------------------------------------------------------------------|
| `role_deploy_authorized_keys__username` | (none)        | **Required**. The username for which the SSH key should be deployed.  |
| `role_deploy_authorized_keys__authorized_sshkey` | (none)      | **Required**. The path to the file containing the SSH public key. |

## Usage

To use this role, include it in your playbook and provide the required variables:

```yaml
- name: Deploy authorized keys for users
  hosts: all
  roles:
    - role: deploy_authorized_keys
      vars:
        role_deploy_authorized_keys__username: myuser
        role_deploy_authorized_keys__authorized_sshkey: /path/to/ssh/public/key.pub
```

## Dependencies

This role does not have any external dependencies.

## Best Practices

- Ensure that the SSH public key file is accessible and readable by Ansible.
- Use absolute paths for the `role_deploy_authorized_keys__authorized_sshkey` variable to avoid path resolution issues.
- Validate the username before deploying keys to prevent errors related to non-existent users.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding tests to ensure the role functions as expected in various scenarios.

## Backlinks

- [defaults/main.yml](../../roles/deploy_authorized_keys/defaults/main.yml)
- [tasks/main.yml](../../roles/deploy_authorized_keys/tasks/main.yml)
- [handlers/main.yml](../../roles/deploy_authorized_keys/handlers/main.yml)