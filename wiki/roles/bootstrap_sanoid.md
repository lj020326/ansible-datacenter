---
title: Bootstrap Sanoid Role Documentation
role: bootstrap_sanoid
category: Ansible Roles
type: Configuration Management
tags: sanoid, replication, cron, ansible
---

## Summary
The `bootstrap_sanoid` role is designed to automate the installation and configuration of Sanoid, a tool for managing ZFS snapshots and replications. This role supports both installing Sanoid via APT package manager or building it from source using a provided Git repository.

## Variables

| Variable Name                      | Default Value                          | Description                                                                 |
|------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `role_bootstrap_sanoid__build_from_source` | `false`                              | Determines whether to build Sanoid from source. If set to `true`, the role will clone a Git repository and build the package. |
| `role_bootstrap_sanoid__apt_package_name`  | `sanoid`                             | The name of the APT package for Sanoid if building from source is disabled.   |
| `syncoid_binary_path`              | `/usr/sbin/syncoid`                    | Path to the Syncoid binary, used in cron jobs for replication tasks.        |

## Usage

To use this role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook
```yaml
- hosts: all
  roles:
    - role: bootstrap_sanoid
      vars:
        role_bootstrap_sanoid__build_from_source: true
```

## Dependencies

This role depends on the following packages:

- `libcapture-tiny-perl` (required for Sanoid)
- Git (if building from source)

Ensure these dependencies are available in your target environment.

## Best Practices

1. **Configuration Management**: Always manage configuration files through Ansible to ensure consistency across environments.
2. **Source Control**: If building from source, consider pinning the Git repository to a specific tag or branch for stability.
3. **Cron Jobs**: Customize `syncoid_cron_jobs` in your inventory to suit your replication needs.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding test scenarios to ensure the role behaves as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_sanoid/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_sanoid/tasks/main.yml)
- [tasks/replication.yml](../../roles/bootstrap_sanoid/tasks/replication.yml)
- [tasks/sanoid.yml](../../roles/bootstrap_sanoid/tasks/sanoid.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_sanoid` role, including its purpose, configuration options, and usage guidelines. For further customization or troubleshooting, refer to the linked source files.