---
title: Bootstrap Ansible Controller Role Documentation
role: bootstrap_ansible_controller
category: Configuration Management
type: Ansible Role
tags: ansible, controller, automation, configuration
---

## Summary

The `bootstrap_ansible_controller` role is designed to automate the setup and management of an Ansible Controller instance. It handles various tasks such as validating credentials, updating configurations, creating organizations, managing roles, schedules, inventories, job templates, and more. This role ensures that the Ansible Controller environment is configured according to specified definitions and requirements.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_ansible_controller__state` | `present` | Determines whether the configuration should be applied (`present`) or removed (`absent`). |
| `bootstrap_ansible_controller__smtp_host` | `smtp.dettonville.int` | SMTP server host for email notifications. |
| `bootstrap_ansible_controller__smtp_port` | `25` | Port number for the SMTP server. |
| `bootstrap_ansible_controller__smtp_sender` | `svc.ansible@dettonville.org` | Sender email address used in notifications. |
| `bootstrap_ansible_controller__default_email_notification_settings` | `{ host: "{{ bootstrap_ansible_controller__smtp_host }}", port: "{{ bootstrap_ansible_controller__smtp_port }}", use_tls: false, use_ssl: false, username: '', password: '', sender: "{{ bootstrap_ansible_controller__smtp_sender }}", timeout: 120 }` | Default settings for email notifications. |
| `bootstrap_ansible_controller__project_sync_timeout` | `300` | Timeout duration in seconds for project synchronization operations. |
| `bootstrap_ansible_controller__controller_host` | `{{ bootstrap_ansible_controller__controller_host \| d(tower_host) \| d(ansible_env.bootstrap_ansible_controller__controller_host) \| d(ansible_env.TOWER_HOST) }}` | Hostname or IP address of the Ansible Controller instance. |
| `bootstrap_ansible_controller__controller_oauth_token` | `{{ bootstrap_ansible_controller__controller_oauth_token \| d(tower_oauth_token) \| d(ansible_env.bootstrap_ansible_controller__controller_oauth_token) \| d(ansible_env.TOWER_OAUTH_TOKEN) }}` | OAuth token for authenticating with the Ansible Controller API. |
| `bootstrap_ansible_controller__controller_verify_ssl` | `{{ bootstrap_ansible_controller__controller_verify_ssl \| d(tower_verify_ssl) \| d(ansible_env.CONTROLLER_VERIFY_SSL) \| d(ansible_env.TOWER_VERIFY_SSL) \| d(false) }}` | Whether to verify SSL certificates when connecting to the Ansible Controller. |
| `bootstrap_ansible_controller__validate_credentials` | `true` | Flag to determine whether credentials should be validated during execution. |
| `bootstrap_ansible_controller__test_environments` | `[sandbox]` | List of environments where tests should be run. |
| `bootstrap_ansible_controller__missing_playbook_fallback_project` | `dettonville - Ansible Tower Management` | Project name to use as a fallback when a playbook is missing. |
| `bootstrap_ansible_controller__missing_playbook_fallback_playbook` | `playbook_does_not_exist.yml` | Playbook file to use as a fallback when the specified playbook does not exist. |
| `bootstrap_ansible_controller__async_max_batch_size_default` | `40` | Default maximum batch size for asynchronous operations. |
| `bootstrap_ansible_controller__async_max_runtime_in_seconds_default` | `120` | Default maximum runtime in seconds for asynchronous tasks. |

## Usage

To use the `bootstrap_ansible_controller` role, include it in your playbook and define any necessary variables as shown below:

```yaml
- name: Bootstrap Ansible Controller Configuration
  hosts: localhost
  gather_facts: false
  roles:
    - role: bootstrap_ansible_controller
      vars:
        bootstrap_ansible_controller__state: present
        bootstrap_ansible_controller__controller_host: tower.dettonville.int
        bootstrap_ansible_controller__controller_oauth_token: your_oauth_token_here
```

## Dependencies

- `ansible.controller` collection for interacting with the Ansible Controller API.
- `containers.podman` collection for handling container login operations.
- `redhat.satellite` collection for Foreman/Satellite interactions.
- `community.general.jira` module for JIRA operations.
- `dettonville.utils.ntlm_uri` module for NTLM-based URI requests.
- `dettonville.akamai.manage_akamai` module for Akamai API interactions.
- `dettonville.sciencelogic.device_info` module for ScienceLogic device information retrieval.
- `dettonville.netbrain.network_device_info` module for NetBrain network device information retrieval.
- `dettonville.cyberark.get_accounts` module for CyberArk account management.

## Tags

The role uses the following tags to allow selective execution of tasks:

- `always`: Always executed tasks, such as variable initialization.
- `validate-credentials`: Tasks related to credential validation.
- `validate-definitions`: Tasks related to definition validation.

To run specific tagged tasks, use the `--tags` option with your Ansible playbook command:

```bash
ansible-playbook -i inventory playbook.yml --tags validate-credentials
```

## Best Practices

1. **Secure Credentials**: Ensure that sensitive information such as OAuth tokens and passwords are stored securely using Ansible Vault.
2. **Environment-Specific Configurations**: Use environment-specific variables to tailor the configuration for different environments (e.g., development, staging, production).
3. **Regular Updates**: Keep the role and its dependencies up-to-date with the latest versions to benefit from bug fixes and new features.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

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