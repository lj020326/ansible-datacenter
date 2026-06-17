---
title: Ansible Role - bootstrap_ansible_controller
role: bootstrap_ansible_controller
category: Automation
type: Configuration Management
tags: ansible, tower, automation, configuration, credentials, inventory, job_templates

---

## Summary

The `bootstrap_ansible_controller` role is designed to automate the setup and management of an Ansible Controller (formerly known as Ansible Tower). This includes configuring SMTP settings for email notifications, managing inventories, creating job templates, validating credentials, and setting up schedules. The role ensures that all necessary resources are properly configured and validated according to specified definitions.

## Variables

| Variable Name                                      | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ansible_controller__state`              | `present`                                                                                               | Determines whether the role should create or remove resources. Valid values are `present` and `absent`.                                                                                                 |
| `bootstrap_ansible_controller__smtp_host`          | `smtp.dettonville.int`                                                                                  | The SMTP server host used for sending emails.                                                                                                                                                             |
| `bootstrap_ansible_controller__smtp_port`          | `25`                                                                                                    | The port number on which the SMTP server is listening.                                                                                                                                                    |
| `bootstrap_ansible_controller__smtp_sender`        | `svc.ansible@dettonville.org`                                                                           | The email address from which notifications will be sent.                                                                                                                                                  |
| `bootstrap_ansible_controller__default_email_notification_settings` | `{ host: "{{ bootstrap_ansible_controller__smtp_host }}", port: "{{ bootstrap_ansible_controller__smtp_port }}", use_tls: false, use_ssl: false, username: '', password: '', sender: "{{ bootstrap_ansible_controller__smtp_sender }}", timeout: 120 }` | Default settings for email notifications.                                                                                                                                                                 |
| `__bootstrap_ansible_controller__project_sync_timeout` | `300`                                                                                                   | Timeout in seconds for project synchronization operations.                                                                                                                                                |
| `__bootstrap_ansible_controller__controller_host`  | `{{ bootstrap_ansible_controller__controller_host \| d(tower_host) \| d(ansible_facts.env.bootstrap_ansible_controller__controller_host) \| d(ansible_facts.env.TOWER_HOST) }}` | The host of the Ansible Controller.                                                                                                                                         |
| `__bootstrap_ansible_controller__controller_oauth_token` | `{{ bootstrap_ansible_controller__controller_oauth_token \| d(tower_oauth_token) \| d(ansible_facts.env.bootstrap_ansible_controller__controller_oauth_token) \| d(ansible_facts.env.TOWER_OAUTH_TOKEN) }}` | OAuth token for authenticating with the Ansible Controller.                                                                                                                                             |
| `__bootstrap_ansible_controller__controller_verify_ssl` | `{{ bootstrap_ansible_controller__controller_verify_ssl \| d(tower_verify_ssl) \| d(ansible_facts.env.CONTROLLER_VERIFY_SSL) \| d(ansible_facts.env.TOWER_VERIFY_SSL) \| d(false) }}` | Whether to verify SSL certificates when connecting to the Ansible Controller.                                                                                                                           |
| `bootstrap_ansible_controller__validate_credentials` | `true`                                                                                                  | Determines whether credentials should be validated during execution.                                                                                                                                      |
| `__bootstrap_ansible_controller__test_environments` | `[sandbox]`                                                                                             | List of environments used for testing.                                                                                                                                                                    |
| `__bootstrap_ansible_controller__missing_playbook_fallback_project` | `dettonville - Ansible Tower Management`                                                                | Fallback project to use if a playbook is missing.                                                                                                                                                         |
| `__bootstrap_ansible_controller__missing_playbook_fallback_playbook` | `playbook_does_not_exist.yml`                                                                           | Fallback playbook to use if the specified playbook does not exist.                                                                                                                                        |
| `__bootstrap_ansible_controller__async_max_batch_size_default` | `40`                                                                                                    | Default maximum batch size for asynchronous operations.                                                                                                                                                   |
| `__bootstrap_ansible_controller__async_max_batch_size` | `{{ bootstrap_ansible_controller__async_max_batch_size \| d(__bootstrap_ansible_controller__async_max_batch_size_default) }}` | Maximum batch size for asynchronous operations, with a default value if not specified.                                                                                                                |
| `__bootstrap_ansible_controller__async_max_runtime_in_seconds_default` | `120`                                                                                                 | Default maximum runtime in seconds for asynchronous operations.                                                                                                                                           |
| `__bootstrap_ansible_controller__async_max_runtime_in_seconds` | `{{ bootstrap_ansible_controller__async_max_runtime_in_seconds \| d(__bootstrap_ansible_controller__async_max_runtime_in_seconds_default) }}` | Maximum runtime in seconds for asynchronous operations, with a default value if not specified.                                                                                                        |

## Usage

To use the `bootstrap_ansible_controller` role, include it in your playbook and define any necessary variables as needed. Here is an example of how to include this role in a playbook:

```yaml
---
- name: Bootstrap Ansible Controller Configuration
  hosts: localhost
  gather_facts: false
  roles:
    - role: bootstrap_ansible_controller
      vars:
        bootstrap_ansible_controller__smtp_host: smtp.example.com
        bootstrap_ansible_controller__smtp_port: 587
        bootstrap_ansible_controller__smtp_sender: admin@example.com
```

## Dependencies

This role does not have any external dependencies beyond the Ansible Controller and its API modules. Ensure that the necessary collections are installed, such as `ansible.controller`.

## Best Practices

- **Environment Variables**: Use environment variables for sensitive information like OAuth tokens to avoid hardcoding them in playbooks.
- **Validation**: Enable credential validation (`bootstrap_ansible_controller__validate_credentials: true`) to ensure all credentials are correctly configured and accessible.
- **Testing**: Test configurations in a sandbox environment before applying them to production.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have the necessary dependencies installed for Molecule and Ansible Controller API modules.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ansible_controller/defaults/main.yml)
- [tasks/convert-template-to-yaml.yml](../../roles/bootstrap_ansible_controller/tasks/convert-template-to-yaml.yml)
- [tasks/create-inventory.yml](../../roles/bootstrap_ansible_controller/tasks/create-inventory.yml)
- [tasks/credential-tests.yml](../../roles/bootstrap_ansible_controller/tasks/credential-tests.yml)
- [tasks/automationhub_publish.yml](../../roles/bootstrap_ansible_controller/tasks/automationhub_publish.yml)
- [tasks/bitbucket_api_credential.yml](../../roles/bootstrap_ansible_controller/tasks/bitbucket_api_credential.yml)
- [tasks/conjur_lookup_injector.yml](../../roles/bootstrap_ansible_controller/tasks/conjur_lookup_injector.yml)
- [tasks/controller_api_access.yml](../../roles/bootstrap_ansible_controller/tasks/controller_api_access.yml)
- [tasks/controlm_login.yml](../../roles/bootstrap_ansible_controller/tasks/controlm_login.yml)
- [tasks/cyberark_credential.yml](../../roles/bootstrap_ansible_controller/tasks/cyberark_credential.yml)
- [tasks/ee_build_credentials.yml](../../roles/bootstrap_ansible_controller/tasks/ee_build_credentials.yml)
- [tasks/foreman_login.yml](../../roles/bootstrap_ansible_controller/tasks/foreman_login.yml)
- [tasks/ivanti_security_controls.yml](../../roles/bootstrap_ansible_controller/tasks/ivanti_security_controls.yml)
- [tasks/jira_custom.yml](../../roles/bootstrap_ansible_controller/tasks/jira_custom.yml)
- [tasks/m365_application_access.yml](../../roles/bootstrap_ansible_controller/tasks/m365_application_access.yml)
- [tasks/men_and_mice.yml](../../roles/bootstrap_ansible_controller/tasks/men_and_mice.yml)
- [tasks/netbrain.yml](../../roles/bootstrap_ansible_controller/tasks/netbrain.yml)
- [tasks/ntw_akamai.yml](../../roles/bootstrap_ansible_controller/tasks/ntw_akamai.yml)
- [tasks/rapid7_credentials.yml](../../roles/bootstrap_ansible_controller/tasks/rapid7_credentials.yml)
- [tasks/sciencelogic.yml](../../roles/bootstrap_ansible_controller/tasks/sciencelogic.yml)
- [tasks/tableau_api.yml](../../roles/bootstrap_ansible_controller/tasks/tableau_api.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_ansible_controller/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_ansible_controller/tasks/main.yml)
- [tasks/manage-roles.yml](../../roles/bootstrap_ansible_controller/tasks/manage-roles.yml)
- [tasks/manage-schedules.yml](../../roles/bootstrap_ansible_controller/tasks/manage-schedules.yml)
- [tasks/remove-controller-config.yml](../../roles/bootstrap_ansible_controller/tasks/remove-controller-config.yml)
- [tasks/update-controller-config.yml](../../roles/bootstrap_ansible_controller/tasks/update-controller-config.yml)
- [tasks/update-job-template.yml](../../roles/bootstrap_ansible_controller/tasks/update-job-template.yml)
- [tasks/validate-definitions.yml](../../roles/bootstrap_ansible_controller/tasks/validate-definitions.yml)