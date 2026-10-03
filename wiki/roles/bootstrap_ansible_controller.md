---
title: "Bootstrap Ansible Controller Role"
role: roles/bootstrap_ansible_controller
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_ansible_controller]
---

```yaml
---
title: Bootstrap Ansible Controller Role
role: bootstrap_ansible_controller
category: Automation
type: Role

summary: |
  The `bootstrap_ansible_controller` role is designed to bootstrap and configure an Ansible Controller (formerly known as Ansible Tower). This role handles the setup of various components such as organizations, credentials, job templates, workflows, and schedules. It also includes validation tasks to ensure that the configurations are correctly applied and that credentials are valid.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_ansible_controller__state` | `present` | The desired state of the Ansible Controller resources. |
| `bootstrap_ansible_controller__smtp_host` | `smtp.dettonville.int` | The SMTP host for email notifications. |
| `bootstrap_ansible_controller__smtp_port` | `25` | The SMTP port for email notifications. |
| `bootstrap_ansible_controller__smtp_sender` | `svc.ansible@dettonville.org` | The sender email address for notifications. |
| `bootstrap_ansible_controller__default_email_notification_settings` | `{"host": "{{ bootstrap_ansible_controller__smtp_host }}", "port": "{{ bootstrap_ansible_controller__smtp_port }}", "use_tls": false, "use_ssl": false, "username": "", "password": "", "sender": "{{ bootstrap_ansible_controller__smtp_sender }}", "timeout": 120}` | Default settings for email notifications. |
| `__bootstrap_ansible_controller__project_sync_timeout` | `300` | Timeout for project synchronization. |
| `__bootstrap_ansible_controller__controller_host` | `{{ bootstrap_ansible_controller__controller_host \| d(tower_host) \| d(ansible_facts.env.bootstrap_ansible_controller__controller_host) \| d(ansible_facts.env.TOWER_HOST) }}` | The host of the Ansible Controller. |
| `__bootstrap_ansible_controller__controller_oauth_token` | `{{ bootstrap_ansible_controller__controller_oauth_token \| d(tower_oauth_token) \| d(ansible_facts.env.bootstrap_ansible_controller__controller_oauth_token) \| d(ansible_facts.env.TOWER_OAUTH_TOKEN) }}` | The OAuth token for the Ansible Controller. |
| `__bootstrap_ansible_controller__controller_verify_ssl` | `{{ bootstrap_ansible_controller__controller_verify_ssl \| d(tower_verify_ssl) \| d(ansible_facts.env.CONTROLLER_VERIFY_SSL) \| d(ansible_facts.env.TOWER_VERIFY_SSL) \| d(false) }}` | Whether to verify SSL certificates for the Ansible Controller. |
| `bootstrap_ansible_controller__validate_credentials` | `true` | Whether to validate credentials. |
| `__bootstrap_ansible_controller__test_environments` | `["sandbox"]` | Environments to test. |
| `__bootstrap_ansible_controller__missing_playbook_fallback_project` | `dettonville - Ansible Tower Management` | Fallback project for missing playbooks. |
| `__bootstrap_ansible_controller__missing_playbook_fallback_playbook` | `playbook_does_not_exist.yml` | Fallback playbook for missing playbooks. |
| `__bootstrap_ansible_controller__async_max_batch_size_default` | `40` | Default maximum batch size for asynchronous operations. |
| `__bootstrap_ansible_controller__async_max_batch_size` | `{{ bootstrap_ansible_controller__async_max_batch_size \| d(__bootstrap_ansible_controller__async_max_batch_size_default) }}` | Maximum batch size for asynchronous operations. |
| `__bootstrap_ansible_controller__async_max_runtime_in_seconds_default` | `120` | Default maximum runtime for asynchronous operations in seconds. |
| `__bootstrap_ansible_controller__async_max_runtime_in_seconds` | `{{ bootstrap_ansible_controller__async_max_runtime_in_seconds \| d(__bootstrap_ansible_controller__async_max_runtime_in_seconds_default) }}` | Maximum runtime for asynchronous operations in seconds. |

## Usage

To use the `bootstrap_ansible_controller` role, include it in your playbook and set the necessary variables. Here is an example:

```yaml
- hosts: localhost
  roles:
    - role: bootstrap_ansible_controller
      vars:
        bootstrap_ansible_controller__state: present
        bootstrap_ansible_controller__smtp_host: smtp.example.com
        bootstrap_ansible_controller__smtp_port: 587
        bootstrap_ansible_controller__smtp_sender: ansible@example.com
```

## Dependencies

This role does not have any external dependencies. However, it assumes that the Ansible Controller is already installed and accessible.

## Best Practices

- Ensure that the Ansible Controller is properly configured and accessible before running this role.
- Validate credentials regularly to ensure that they are correct and up-to-date.
- Use the `state` variable to manage the lifecycle of resources (e.g., `present` to create, `absent` to remove).

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
```