```markdown
---
title: bootstrap_ansible_controller Role Documentation
original_path: roles/bootstrap_ansible_controller/README.md
category: Ansible Roles
tags: [ansible, automation-controller, role-documentation]
---

# bootstrap_ansible_controller Role

This role manages (adds or removes) defined resources on an instance of Ansible Automation Controller. The resources include:

- Organizations (not removed when `bootstrap_ansible_controller__state` is set to `absent`)
- Credential types
- Credentials
- Teams
- Projects
- Inventories
- Job templates
- Workflow job templates
- Schedules
- Local users
- Execution environments
- Roles
- Settings (not removed when `bootstrap_ansible_controller__state` is set to `absent`)

The tasks in `validate-definitions.yml` ensure that defined variables are internally consistent. For example, the playbook will fail if a credential references an undefined credential type.

## Requirements

This role utilizes the `ansible.controller` collection.
[Ansible Controller Collection Documentation](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/docs/)

## Tags

- **validate-credentials**: Tasks that validate credentials before making any changes.
- **validate-definitions**: Tasks that ensure consistency in various definitions, such as all referenced credentials being defined.

## Role Variables

### A Note on Roles
If a variable allows roles to be assigned, you can add a `roles` key. Under this key, specify other keys (e.g., `use`, `admin`) with values as lists of teams and/or local users to be granted those roles. Example:

```yaml
- name: sample job template
  ...
  roles:
    admin:
      - Team_A
    execute:
      - Team_B
      - Team_C
      - Local_User_A
```

### bootstrap_ansible_controller__state (defaults/main.yml)
Default value is `present`. When set to `absent`, defined items will be removed, except for organizations and settings.

### controller_general_settings (controller-settings.yml)
A dictionary of settings to apply. Available keys can be found at `{{ hostname }}/api/v2/settings/all/`.

### controller_saml_settings (controller-settings.yml)
A dictionary of SAML-specific settings. Notably, the `team_org_map` value is dynamically generated based on organizations and teams (see `__org_team_list` variable).

### __controller_default_credential_types (credential-types.yml)
Uses the `ansible.controller.controller_api` query to retrieve a list of built-in credential types for validation.

### controller_credential_types (credential-types.yml)
A list of dictionaries defining credential types. Any new credential types must have corresponding tests (see **Credential Testing** below).

### controller_credentials (credentials.yml)
A list of dictionaries defining credentials. The `use` role can be added to these items.

- The `credential_type` must be defined in either `controller_credential_types` or exist in `__controller_default_credential_types`.
- Any input marked as secret in the associated credential type should reference a variable from `_vaulted_credentials`.

### bootstrap_ansible_controller__env_specific_vars (env-specific.yml)
Contains keys for sandbox, dev, qa, and prod. If resource definitions vary by environment, define them here and refer to using `controller_env` from the 'controller api access' credential type.

Example:

```yaml
- name: sample credential
  hostname: {{ bootstrap_ansible_controller__env_specific_vars[controller_env]['sample_cred_hostname']}}
```

Environment-specific values are defined under:

```yaml
bootstrap_ansible_controller__env_specific_vars:
  sandbox:
    ...
    sample_cred_hostname: sandboxhost.example.com
  dev:
    ...
    sample_cred_hostname: devhost.example.com
  ...
```

### controller_inventories (inventories.yml)
A list of inventory definitions, including their sources. Accepted roles are `use`, `admin`, `update`, and `adhoc`.

Dependencies:

- `organization` must be defined in `controller_organizations`.
- `source_project` must be defined in `controller_projects`.
- `credential` must be defined in `controller_credentials`.

**Note:** The `ansible.controller.inventory_source` module does not currently respect credentials assigned directly. Credentials need to be manually added for inventory sources that require them.

### controller_job_templates (job-templates.yml)
A list of job template definitions with accepted roles `execute` and `admin`. Dependencies:

- `inventory` must be defined in `controller_inventories`.
- `organization` must be defined in `controller_organizations`.
- `project` must be defined in `controller_projects`.
- `credentials` must be defined in `controller_credentials`.
- `environments` (optional) should be a list of values: sandbox, dev, qa, prod.
- `notification_templates_started`, `notification_templates_success`, and `notification_templates_error` (optional) should be lists with items from `bootstrap_ansible_controller__notification_templates`.

### controller_workflow_templates (workflow-templates.yml)
A list of workflow job template definitions. Accepted roles are `execute`, `admin`, and `approval`. Dependencies:

- `inventory` must be defined in `controller_inventories`.
- `organization` must be defined in `controller_organizations`.
- `project` must be defined in `controller_projects`.
- `credentials` must be defined in `controller_credentials`.

## Backlinks

- [Ansible Automation Controller Roles](/roles)
```

This improved version maintains all original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.