---
title: "Run Inspec Role"
role: run_inspec
category: Roles
type: ansible-role
tags: [ansible, role, run_inspec]
---

# Run InSpec Role Documentation

## Purpose

The `run_inspec` role is designed to automate the execution of InSpec tests across a group of hosts defined in an Ansible inventory. This role facilitates security compliance checks and audit processes by leveraging InSpec profiles to validate system configurations against predefined security baselines.

## Variables

| Variable Name                   | Default Value | Description                                                                 |
|---------------------------------|---------------|-----------------------------------------------------------------------------|
| `inspec_profile`                |               | Path to the InSpec profile to be executed.                                  |
| `ssh_keyfile`                   |               | Path to the SSH key file used for authentication.                           |
| `input_file`                    |               | Path to the input file containing InSpec input parameters.                  |
| `inspec_wait_time`              | 600           | Time in seconds to wait for the InSpec execution to complete.               |
| `inspec_poll`                   | 10            | Interval in seconds between polls to check the status of the InSpec job.     |
| `inspec_wait_async_retries`     | 100           | Number of retries to wait for the InSpec job to complete.                   |
| `inspec_wait_async_delay`       | 10            | Delay in seconds between retries to check the status of the InSpec job.      |
| `debug`                         | false         | Enable debug mode to print host variables.                                  |

## Usage

To use the `run_inspec` role, include it in your playbook and define the necessary variables. Ensure that the `inspec_test_group` is defined in your inventory and contains the hosts you want to test.

```yaml
---
- hosts: all
  roles:
    - role: run_inspec
      vars:
        inspec_profile: "/path/to/inspec/profile"
        ssh_keyfile: "/path/to/ssh/key"
        input_file: "/path/to/input/file"
        inspec_wait_time: 600
        inspec_poll: 10
        inspec_wait_async_retries: 100
        inspec_wait_async_delay: 10
        debug: true
```

## Dependencies

This role does not have any external dependencies. However, it assumes that the InSpec tool is installed on the control node and that the necessary InSpec profile and input files are available.

## Best Practices

1. **Inventory Management**: Ensure that the `inspec_test_group` is correctly defined in your inventory file and includes all the hosts you want to test.
2. **SSH Key Management**: Use a secure method to manage and distribute SSH keys to ensure secure access to the target hosts.
3. **Profile Selection**: Choose the appropriate InSpec profile that matches the security baseline you want to validate.
4. **Resource Allocation**: Adjust the `inspec_wait_time`, `inspec_poll`, `inspec_wait_async_retries`, and `inspec_wait_async_delay` variables based on the expected load and performance of your infrastructure to optimize resource usage.

## Backlinks

- [tasks/inspec_exec.yml](../../roles/run_inspec/tasks/inspec_exec.yml)
- [tasks/main.yml](../../roles/run_inspec/tasks/main.yml)