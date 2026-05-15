---
title: "Run InSpec Role Documentation"
role: run_inspec
category: Ansible Roles
type: Execution
tags: ["InSpec", "Security", "Automation"]
---

## Summary

The `run_inspec` role is designed to execute InSpec profiles on a group of hosts specified in the inventory. It supports running InSpec tests via SSH, with options for sudo execution, input files, and custom controls. The role also handles asynchronous task management to ensure that all InSpec runs are completed before proceeding.

## Variables

| Variable Name                       | Default Value                      | Description                                                                 |
|-------------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| `role_run_inspec__inspec_profile`   | N/A                                | Path to the InSpec profile to be executed.                                  |
| `role_run_inspec__ssh_keyfile`      | N/A                                | Path to the SSH key file used for authentication.                           |
| `role_run_inspec__input_file`       | N/A                                | Path to the input file containing variables for the InSpec profile.         |
| `role_run_inspec__inspec_wait_time` | 3600                               | Time in seconds to wait for asynchronous tasks to complete.                 |
| `role_run_inspec__inspec_poll`      | 10                                 | Polling interval in seconds for checking the status of asynchronous tasks.  |
| `role_run_inspec__inspec_wait_async_retries` | 36                            | Number of retries for checking the status of asynchronous tasks.            |
| `role_run_inspec__inspec_wait_async_delay` | 10                             | Delay in seconds between retries for checking the status of asynchronous tasks.|
| `debug`                             | false                              | Boolean to enable or disable debug output.                                  |

## Usage

To use this role, include it in your playbook and define the necessary variables:

```yaml
- hosts: inspec_test_group
  roles:
    - run_inspec
  vars:
    role_run_inspec__inspec_profile: /path/to/your/inspec/profile
    role_run_inspec__ssh_keyfile: /path/to/your/private/key
    role_run_inspec__input_file: /path/to/your/input/file.yml
```

Ensure that the `inspec_test_group` is defined in your inventory file and contains the hosts you want to test.

## Dependencies

- **InSpec**: Ensure InSpec is installed on the control machine.
- **SSH Access**: The control machine must have SSH access to the target hosts using the specified keyfile.
- **Ansible Modules**: `ansible.builtin.debug`, `ansible.builtin.shell`, and `ansible.windows.async_status`.

## Best Practices

- **Security**: Always use secure SSH keys and ensure they are not exposed in your repository or logs.
- **Profiles**: Use well-defined InSpec profiles that align with your security policies.
- **Input Files**: Keep input files organized and version-controlled to maintain consistency across environments.

## Molecule Tests

No Molecule tests are currently defined for this role. Consider adding Molecule scenarios to ensure the role behaves as expected in different environments.

## Backlinks

- [tasks/inspec_exec.yml](../../roles/run_inspec/tasks/inspec_exec.yml)
- [tasks/main.yml](../../roles/run_inspec/tasks/main.yml)