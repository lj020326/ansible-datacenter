---
title: "report_inventory_facts Role Documentation"
role: report_inventory_facts
category: Ansible Roles
type: Technical Documentation
tags: ansible, role, inventory, facts, reporting

---

## Summary

The `report_inventory_facts` role is designed to gather detailed system information (facts) about managed hosts and update a Git repository with this data. The role supports both SSH and HTTPS protocols for interacting with the Git repository and can optionally create mindmaps of the inventory.

## Variables

| Variable Name                                      | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_report_inventory_facts__inventory_source`    | `DEV`                                                                                           | Specifies the source or environment (e.g., DEV, PROD) for the inventory report.                                                                                                                             |
| `role_report_inventory_facts__git_repo_endpoint`   | `gitea.admin.example.int/infra/report-inventory-facts.git`                                      | The endpoint of the Git repository where the inventory reports will be stored.                                                                                                                              |
| `role_report_inventory_facts__git_repo_url_scheme` | `https`                                                                                         | The URL scheme for accessing the Git repository (either `http`, `https`, or `ssh`).                                                                                                                         |
| `role_report_inventory_facts__git_repo_branch`     | `main`                                                                                          | The branch of the Git repository to clone and update.                                                                                                                                                       |
| `role_report_inventory_facts__git_repo_cred`       | `{{ 'git' if role_report_inventory_facts__git_repo_url_scheme=='ssh' else role_report_inventory_facts__git_repo_user +':' + role_report_inventory_facts__git_repo_token }}` | The credentials used for accessing the Git repository. For SSH, it defaults to `git`. For HTTPS, it uses a username and token combination.     |
| `role_report_inventory_facts__git_repo_url`        | `{{ role_report_inventory_facts__git_repo_url_scheme }}://{{ role_report_inventory_facts__git_repo_endpoint }}` | The full URL of the Git repository without credentials.                                                                                                                                                     |
| `role_report_inventory_facts__git_repo_url_cred`   | `{{ role_report_inventory_facts__git_repo_url_scheme }}://{{ role_report_inventory_facts__git_repo_cred }}@{{ role_report_inventory_facts__git_repo_endpoint }}` | The full URL of the Git repository with credentials embedded.                                                                                                                                                 |
| `role_report_inventory_facts__git_ssh_private_keyfile` | `ansible_git_ssh.key`                                                                         | The filename for the SSH private key used to authenticate with the Git repository when using SSH.                                                                                                             |
| `role_report_inventory_facts__create_mindmap`      | `false`                                                                                         | A boolean flag indicating whether to create a mindmap of the inventory data.                                                                                                                                |
| `role_report_inventory_facts__git_user`            | `ansible`                                                                                       | The Git username used for committing changes to the repository.                                                                                                                                             |
| `role_report_inventory_facts__git_email`           | `ansible@example.int`                                                                           | The email address associated with the Git user.                                                                                                                                                             |
| `role_report_inventory_facts__cleanup_tempdir`     | `true`                                                                                          | A boolean flag indicating whether to clean up temporary directories created during the execution of the role.                                                                                                |
| `role_report_inventory_facts__report_list_facts_flattened_common` | Various fields from `ansible_facts`                                                            | A dictionary containing common host facts that will be reported, such as nodename, machine type, domain, distribution, and more.                                                                         |

**Note:** Variables starting with double underscores (e.g., `__internal_var`) are internal to the role and should not be overridden by users.

## Usage

To use the `report_inventory_facts` role, include it in your playbook and provide the necessary variables as shown below:

```yaml
- hosts: all
  roles:
    - role: report_inventory_facts
      vars:
        role_report_inventory_facts__inventory_source: PROD
        role_report_inventory_facts__git_repo_endpoint: gitea.admin.example.int/infra/report-inventory-facts.git
        role_report_inventory_facts__git_repo_url_scheme: https
        role_report_inventory_facts__git_repo_branch: main
        role_report_inventory_facts__git_repo_user: your_username
        role_report_inventory_facts__git_repo_token: your_token
```

## Dependencies

- `community.general` collection (for `git_config` and `json_query` modules)

Ensure that the required collections are installed:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Secure Credentials:** Ensure that Git credentials (`role_report_inventory_facts__git_repo_user` and `role_report_inventory_facts__git_repo_token`) are stored securely, such as using Ansible Vault.
2. **Branch Management:** Specify the correct branch in `role_report_inventory_facts__git_repo_branch` to avoid unintended updates to the wrong branch.
3. **Environment Variables:** Use environment variables or secure vaults for sensitive information like SSH keys and tokens.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/report_inventory_facts/defaults/main.yml)
- [tasks/fetch-reports-repo.yml](../../roles/report_inventory_facts/tasks/fetch-reports-repo.yml)
- [tasks/main.yml](../../roles/report_inventory_facts/tasks/main.yml)
- [tasks/update-reports-repo.yml](../../roles/report_inventory_facts/tasks/update-reports-repo.yml)
- [handlers/main.yml](../../roles/report_inventory_facts/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `report_inventory_facts` role, including its purpose, configuration options, usage guidelines, and best practices.