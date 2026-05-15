---
title: Bootstrap VMware Tools Role Documentation
role: bootstrap_vmware_tools
category: System Configuration
type: Ansible Role
tags: vmware, tools, open-vm-tools, automation

---

## Summary
The `bootstrap_vmware_tools` role is designed to install and configure Open VMware Tools (`open-vm-tools`) on target systems. This ensures that essential functionalities such as time synchronization, mouse integration, and enhanced graphics are available when the system runs within a VMware environment.

## Variables

| Variable Name                  | Default Value  | Description                                                                 |
|--------------------------------|----------------|-----------------------------------------------------------------------------|
| `role_bootstrap_vmware_tools__package_name` | `open-vm-tools` | The name of the package to be installed for Open VMware Tools.     |

**Note:** All role variable names should start with `role_bootstrap_vmware_tools__` to adhere to the naming convention.

## Usage

To use this role, include it in your playbook as follows:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_vmware_tools
```

You can also override the default package name if necessary by specifying a different value for `role_bootstrap_vmware_tools__package_name`:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_vmware_tools
      vars:
        role_bootstrap_vmware_tools__package_name: custom-open-vm-tools
```

## Dependencies

This role does not have any external dependencies. It relies solely on the `ansible.builtin.package` and `ansible.builtin.service` modules, which are part of Ansible's core functionality.

## Best Practices

1. **Ensure Compatibility:** Verify that the specified package name is available in your target system's repositories.
2. **Test Thoroughly:** Use Molecule tests to ensure that the role functions as expected across different environments and distributions.
3. **Monitor Logs:** After applying this role, monitor the logs for `vmtoolsd` service to confirm it is running without issues.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Molecule installed along with any necessary drivers (e.g., Docker) before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_tools/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_tools/tasks/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_vmware_tools` role, including its purpose, configuration options, usage instructions, and best practices. For further assistance or questions, refer to the provided backlinks or contact your system administrator.