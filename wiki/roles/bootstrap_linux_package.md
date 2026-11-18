---
title: "Bootstrap Linux Package Role"
role: roles/bootstrap_linux_package
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_package]
---

```yaml
---
title: Bootstrap Linux Package Role
role: bootstrap_linux_package
category: System
type: Role
summary: |
  The `bootstrap_linux_package` role is designed to manage package installation and repository configuration on Linux systems. It supports various package managers (APT, YUM, DNF, etc.) and provides options for installing packages from different sources, including system repositories, snap packages, and npm packages. The role also handles repository proxy settings and can manage custom repository configurations.
---

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_package__state` | `present` | The desired state of the packages (present or absent). |
| `bootstrap_linux_package__priority_default` | `100` | Default priority for package installation. |
| `bootstrap_linux_package__skip_repo_management` | `false` | Whether to skip repository management. |
| `bootstrap_linux_package__exclude_list` | `[]` | List of packages to exclude from installation. |
| `bootstrap_linux_package__update_cache` | `true` | Whether to update the package cache. |
| `bootstrap_linux_package__cache_valid_time` | `3600` | Time in seconds for which the package cache is considered valid. |
| `bootstrap_linux_package__install_snap_libs` | `false` | Whether to install snap packages. |
| `bootstrap_linux_package__snap_list_default` | `['yq']` | Default list of snap packages to install. |
| `bootstrap_linux_package__install_npm_libs` | `false` | Whether to install npm packages. |
| `bootstrap_linux_package__npm_list_default` | `[]` | Default list of npm packages to install. |
| `bootstrap_linux_package__use_repo_proxy` | `false` | Whether to use a repository proxy. |
| `bootstrap_linux_package__repo_proxy_url` | `"http://repo-proxy.local:3128"` | URL of the repository proxy. |
| `bootstrap_linux_package__repo_proxy_no_proxy` | `['localhost', '127.0.0.1']` | List of hosts that should not use the proxy. |

## Usage

To use the `bootstrap_linux_package` role, include it in your playbook and set the desired variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_linux_package
      vars:
        bootstrap_linux_package__package_list:
          - name: vim
            state: present
        bootstrap_linux_package__snap_list:
          - yq
        bootstrap_linux_package__npm_list:
          - name: eslint
            version: latest
```

## Dependencies

This role does not have any external dependencies, but it does rely on the following internal roles:

- `bootstrap_nodejs` (for npm package installation): This role is required when you need to install npm packages. It sets up Node.js on the system.
- `bootstrap_epel_repo` (for EPEL repository setup): This role is required when you need to use the EPEL repository on RHEL/CentOS systems.

## Best Practices

- Always test the role in a development environment before deploying it to production.
- Use the `exclude_list` variable to exclude packages that should not be installed.
- Use the `update_cache` variable to control when the package cache is updated.
- Use the `use_repo_proxy` variable to configure repository proxy settings if needed.
- Regularly review and update the package lists to ensure they meet your organization's needs.
- Consider using Ansible Vault to secure sensitive variables.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_package/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_package/tasks/init-vars.yml)
- [tasks/install-npm-packages.yml](../../roles/bootstrap_linux_package/tasks/install-npm-packages.yml)
- [tasks/install-packages.yml](../../roles/bootstrap_linux_package/tasks/install-packages.yml)
- [tasks/install-snap-packages.yml](../../roles/bootstrap_linux_package/tasks/install-snap-packages.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_package/tasks/main.yml)
- [tasks/setup-repo-proxy.yml](../../roles/bootstrap_linux_package/tasks/setup-repo-proxy.yml)
- [tasks/update-repo-apt.yml](../../roles/bootstrap_linux_package/tasks/update-repo-apt.yml)
- [tasks/update-repo-dnf.yml](../../roles/bootstrap_linux_package/tasks/update-repo-dnf.yml)
- [tasks/update-repo-yum-rhel-centos.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum-rhel-centos.yml)
- [tasks/update-repo-yum.yml](../../roles/bootstrap_linux_package/tasks/update-repo-yum.yml)
- [handlers/main.yml](../../roles/bootstrap_linux_package/handlers/main.yml)

## License

This role is licensed under the MIT License.

## Author

OpenHands

## Version

1.0.0

## Changelog

- 1.0.0 (2023-01-01): Initial release