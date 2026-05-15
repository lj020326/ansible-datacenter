```markdown
---
title: Bootstrap AWX Resources Role Documentation
original_path: roles/bootstrap_awx_resources/README.md
category: Ansible Roles
tags: [ansible, awx, automation]
---

# Overview & Purpose

Use this role to create and/or remove Ansible Tower resources including:

- Organizations
  - Credentials
  - Inventories
  - Projects
    - Job Templates
  - Teams
    - Roles

# Role Objectives

Define each Tower resource under the configuration root node `bootstrap_awx_resources__config`:

- Create a list of one or more organizations under the node `bootstrap_awx_resources__config.organizations`.
- Each organization can define the following lists:
  - **credentials**: List of credential maps containing the [credential definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/credential_module.html#ansible-collections-awx-awx-credential-module).
  - **inventories**: List of inventory maps containing the [inventory definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/inventory_module.html#ansible-collections-awx-awx-inventory-module).
  - **projects**: List of project maps containing the [project definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/project_module.html#ansible-collections-awx-awx-project-module).
    - **job_templates**: List of job_template maps containing the [job_template definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/job_template_module.html#ansible-collections-awx-awx-job-template-module).
  - **teams**: List of team maps containing the [team definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/team_module.html#ansible-collections-awx-awx-team-module).
    - **roles**: List of role maps containing the [role definition](https://docs.ansible.com/ansible/latest/collections/awx/awx/role_module.html#ansible-collections-awx-awx-role-module).

The following conditional actions are observed upon execution of the role:

- If any object with the same `name` already exists in the Tower runtime environment with the same details defined in the `bootstrap_awx_resources__config` map, no changes will be made to the object.
- If any object with the same `name` already exists in the Tower runtime environment and the details in the `bootstrap_awx_resources__config` map are different, the respective object(s) will be updated/changed accordingly.
- If any object exists in the Tower runtime environment and is not defined by `name` in the `bootstrap_awx_resources__config` map, the object will not be changed or removed.
- Upon setting the `bootstrap_awx_resources__state` to `absent`, any object with the same `name` that already exists in the Tower runtime environment will be removed. **Be judicious/careful when utilizing Tower object removal.**

**NOTE**: If the `state` variable is defined for any object, it will be overridden and ignored with precedence given to the `tower_config_state` variable which defaults to `present`.

## Example 1: 2 Organizations

In the following example, the YAML definition will create 2 organizations.

For the second organization 'New Org2', an inventory 'New Inventory', a project 'New Project' and job template 'Job Template to Launch' will be created with details as defined below.

```yaml
bootstrap_awx_resources__config:
  organizations:
    - name: "New Org1"
      description: "test org"
      state: present

    - name: "New Org2"
      description: "test org"
      state: present

      inventories:
        - name: "New Inventory"
          description: "test inv"
          state: present

      projects:
        - name: "New Project"
          scm_type: git
          scm_url: https://github.com/ansible/test-playbooks.git
          job_templates:
            - name: "Job Template to Launch"
              project: "New Project"
              inventory: "New Inventory"
              playbook: debug.yml
```

## Example 2: 2 Organizations, with Elaboration for Team Roles

In the next example, the definition for the second organization 'New Org2' is elaborated to include team roles as defined.

```yaml
bootstrap_awx_resources__config:
  organizations:
    - name: "TEST - New Org111"
      description: "test org"

    - name: "TEST - New Org222"
      description: "test org"

      credentials:
        - name: 'TEST - Example password'
          credential_type: Vault
          inputs:
            vault_password: 'new_password'
        - name: "TEST - SCM Credential"
          credential_type: Source Control
          inputs:
            username: joe
            password: secret

      inventories:
        - name: "TEST - New Inventory"
          description: "test inv"
          state: present

      projects:
        - name: "TEST - New Project"
          scm_type: git
          scm_url: https://github.com/ansible/test-playbooks.git
          job_templates:
            - name: "TEST - Job Template to Launch"
              inventory: "TEST - New Inventory"
              playbook: debug.yml

      teams:
        - name: "TEST - Test Team 1"
          description: "test team"
          roles:
            - role: use
              inventories:
                - "TEST - New Inventory"
            - role: use
              projects:
                - "TEST - New Project"
            - role: use
              credentials:
                - "TEST - Example password"
                - "TEST - SCM Credential"
            - role: execute
              job_templates:
                - "TEST - Job Template to Launch"

#              ## if using older ansible.tower collection versions, it may not support lists - in that case, change to singletons as follows
#              - role: use
#                inventory: "TEST - New Inventory"
#              - role: use
#                project: "TEST - New Project"
#              - role: use
#                credential: "TEST - Example password"
```

# Backlinks

- [Ansible Roles](../ansible_roles.md)
- [AWX Documentation](https://docs.ansible.com/ansible-tower/latest/html/index.html)
```