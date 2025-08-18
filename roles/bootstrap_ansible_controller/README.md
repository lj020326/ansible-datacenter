bootstrap_ansible_controller
=========

This role adds (or removes) defined resources to an instance of Ansible Automation Controller. Resources include:

* Organization (this role does not currently remove organizations when `bootstrap_ansible_controller__state` set to `absent`)
* Credential types
* Credentials
* Teams
* Projects
* Inventories
* Job templates
* Workflow job templates
* Schedules
* Local users
* Execution Environments
* Roles
* Settings (this role does not currently remove settings when `bootstrap_ansible_controller__state` set to `absent`)

The tasks in validate-definitions.yml will ensure that defined variables are internally consistent. For example, the playbook will fail during this step if a credential is defined but references a credential type that is *not* defined.

Requirements
------------

This role uses the ansible.controller collection.
https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/docs/

Tags
---

`validate-credentials`: Tasks which validate credentials prior to making any changes.
`validate-definitions`: Tasks that validate various definitions, e.g. all credentials referenced in job templates are defined in code

Role Variables
--------------
### A note on roles
If a variable says it can have roles assigned, then `roles` may be added as a key. Beneath that, other keys are added (e.g. `use`, `admin`, etc) where each value is a list of teams and/or local users to be granted that role. Example:

    - name: sample job template
      ...
      roles:
        admin:
          - Team_A
        execute:
          - Team_B
          - Team_C
          - Local_User_A

The type of roles available will be noted for each entry.

### bootstrap_ansible_controller__state (defaults/main.yml)
The default is present. When set to absent, defined items will be removed with the exceptions noted above.

### controller_general_settings (controller-settings.yml)
A dictionary of settings to be applied. Available keys can be viewed at {{ hostname }}/api/v2/settings/all/

### controller_saml_settings (controller-settings.yml)
A dictionary of SAML-specific settings. Of note is the `team_org_map` value, which is set to a dynamically generated mapping of organizations and teams. (See `__org_team_list` variable)

### __controller_default_credential_types (credential-types.yml)
This uses the ansible.controller.controller_api query to get a list of built-in credential types. This is required for validation of credential definitions.

### controller_credential_types (credential-types.yml)
A list of dictionaries that define credential types. _Any new credential types must have a corresponding credential test. See **Credential Testing** below._

### controller_credentials (credentials.yml)
A list of dictionaries that define credentials. The `use` role may be added to these items.

* The credential_type must be defined in either `controller_credential_types` or exist in `__controller_default_credential_types`
* Any input that is defined as secret in the assocatied credential type should be referred to as a variable referring to an entry in `_vaulted_credentials` (see `_vaulted_credentials variable`)

### bootstrap_ansible_controller__env_specific_vars (env-specific.yml)
This variable contains keys for sandbox, dev, qa, and prod. If a resource definition will vary based on the Controller environment, the environment-specific values should be defined here and referred to. The sandbox/dev/etc value is provided by the 'controller api access' credential type as `controller_env`. For example, this sample credential:

    - name: sample credential
      hostname: {{ bootstrap_ansible_controller__env_specific_vars[controller_env]['sample_cred_hostname']}}

would be listed under:

    bootstrap_ansible_controller__env_specific_vars:
      sandbox:
        ...
        sample_cred_hostname: sandboxhost.example.com
      dev:
        ...
        sample_cred_hostname: devhost.example.com
      ...

### controller_inventories (inventories.yml)
A list of inventory definitions. Each inventory definition consists of the inventory itself as well as its sources. The following roles are accepted for these items:

* `use`
* `admin`
* `update`
* `adhoc`

The following dependencies apply:

* `organization` must be defined in `controller_organizations`
* `source_project` must be defined in `controller_projects`
* `credential` must be defined in `controller_credentials`

**NOTE:** As of this writing, The ansible.controller.inventory_source module does not appear to respect credentials that are assigned. Credentials will need to be manually added. This only affects inventory sources that have credentials assigned to them directly, such as an AWS dynamic inventory.

### controller_job_templates (job-templates.yml)
A list of job template definitions. The `execute` and `admin` roles are accepted for these items. The following dependencies apply:

* `inventory` must be defined in `controller_inventories`
* `organization` must be defined in `controller_organizations`
* `project` must be defined in `controller_projects`
* `credentials` must be defined in `controller_credentials`
* `environments` (optional) must be a list and contain only the following values: sandbox, dev, qa, prod. This specificies which environments receive the template. If omitted, template is pushed to all environments.
* `notification_templates_started`, `notification_templates_success`, and `notification_templates_error` (optional) must be lists. Each item within the list must be defined within `bootstrap_ansible_controller__notification_templates`.

### controller_workflow_templates (workflow-templates.yml)
A list of workflow job template definitions. The `execute`, `admin`, and `approval` roles are accepted for these items. The following dependencies apply:

* `inventory` must be defined in `controller_inventories` if it is specified in the workflow definition
* `unified_job_template` within each workflow node must be defined in `controller_job_templates`
* `environments` (optional) must be a list and contain only the following values: sandbox, dev, qa, prod. This specificies which environments receive the template. If omitted, workflow is pushed to all environments.

### controller_execution_environments (execution-environments.yml)
A list of execution environments to be added. Execution environments must already exist in an image registry (e.g. Private Automation Hub).

Project and job template definitions will be validated against this list to ensure only pre-defined execution environments are referenced, though this functionality is not yet in place.

### controller_schedules (schedules.yml)
A list of schedule definitions. The following dependencies apply:

* `organization` must be defined in `controller_organizations`
* `job_template_name` must be defined in `controller_job_templates`
* `environments` (optional) must be a list and contain only the following values: sandbox, dev, qa, prod. This specificies which environments receive the schedule. If omitted, schedule is pushed to all environments.

`rule_parameters` is a list of parameters used to create a schedule. See full documentation [here](https://docs.ansible.com/ansible/latest/collections/awx/awx/schedule_rruleset_lookup.html#ansible-collections-awx-awx-schedule-rruleset-lookup).

### controller_organizations (orgs-and-teams.yml)
A list of controller organizations.

* `teams` - Any teams listed here will be created (or removed) by the role. Any teams listed under `roles` for resources must be defined here.
* `galaxy_credentials` - Credentials that will be used to access remote collections.
* `admin_roles` - Teams and local users listed here will be given organizational admin rights.
* `auditors` - Teams and local users listed here will be given organization audit (full read) rights

### __org_team_list (orgs-and-teams.yml)
This is a generated list derived from `controller_organizations` where each item provides an organization and team pairing. This is used to create and remove teams as well as for the SAML group mapping.

### bootstrap_ansible_controller__local_users (local-users.yml)
A list of local users to be created, defined by username, password (vaulted), and organization. These users will be created in each environment.

### controller_projects (projects.yml)
A list of controller projects. The `use`, `admin`, and `update` roles are accepted for these items. The following dependencies apply:

* `organization` must be defined in `controller_organizations`
* `credential` must be defined in `controller_credentials`

### bootstrap_ansible_controller__notification_templates
A list of notification templates. Only email and webhook types are currently supported by this role.

#### _default_git_credential and _default_scm_branch (projects.yml)
These items are provided as shorthand. As most projects will have the same git credential and scm branch, these variables allow these items to be defined once for ease of management. Those projects that deviate from the defaults can have their values replaced accordingly.

### _vaulted_credentials
A dictionary (*not* a list of dictionaries as other items have been) where the values are encrypted with ansible-vault. This allows those credentials to be stored without exposure. This is intended to be a temporary solution. In future state, these vaulted values would be replaced with Conjur (or equivalent) lookup definitions.

Credential Testing
---

To ensure that the defined credentials are valid before promoting to environments, the tasks under `credential-tests.yml` are intended to perform tests as part of the validation phase. These tests can be run independently through use of the `validate-credentials` tag. The guidelines for credential tests are:

* Tests are based on `credential_type`. Each test should be able to loop through all credentials of a given type.
* Credential types should include all fields necessary for said testing. For example, an endpoint URL which indicates the address against which each credential of that typeshould be tested. (There are several credential types that are pending updates to support credential testing)
* Tests should not be capable of making changes. This may mean making a simple login API call, forcing check mode at the task level, etc. The tests are not intended to validate all permissions of a given credential, only that the credential itself is correctly defined.
* Tests should run in both Run and Check modes. `check_mode` should be set on each task as needed. For example, the `ansible.builtin.uri` module does not support check mode, so `check_mode: False` is set on these tasks.

Job template conversion
---

To convert an existing job template to yaml for purposes of inclusion into job-templates.yml, the `convert-template-to-yaml.yml` task file has been provided. This will take the variable `template_name`, fetch said template from the AAC environment, and convert. However, due to limitations of the debug module, some cleanup is required by the end user.

An example output looks like this when the play is run:

```
TASK [bootstrap_ansible_controller : Output yaml] ******************************
ok: [localhost] => {
    "msg": [
        "- name: APP - Selenium Validation - release/aap-master",
        "  description: Run Selenium Validations mte:15",
        "  organization: dettonville",
        "  inventory: dettonville inventory",
        "  project: APP - Operations",
        "  playbook: selenium_validations.yml",
        "  credentials:",
        "  - dettonville - JIRA PROD",
        "  - Domain Join dettonville",
        "  - LNX - Ansible Linux",
        "  limit: abc123",
        "  roles:",
        "    admin:",
        "    execute:"
    ]
}
```

As the output is provided as a list, unwanted characters must be removed. This includes the double-quotes (") and commas. After cleanup, the output would look like this:

```
- name: APP - Selenium Validation - release/aap-master
  description: Run Selenium Validations mte:15
  organization: dettonville
  inventory: dettonville inventory
  project: APP - Operations
  playbook: selenium_validations.yml
  credentials:
    - dettonville - JIRA PROD
    - Domain Join dettonville
    - LNX - Ansible Linux
  limit: abc123
  roles:
    admin:
    execute:
```

**NOTE:** The roles section is provided only as a placeholder. To add specific roles, each key (e.g. admin, execute, etc.) must be populated by a list of groups. These can be left blank if no job template-specific roles are required.
