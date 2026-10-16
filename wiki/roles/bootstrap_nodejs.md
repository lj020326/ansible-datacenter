---
title: "Bootstrap Node.js Role"
role: bootstrap_nodejs
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_nodejs]
---

# Bootstrap Node.js Role Documentation

## Overview

The `bootstrap_nodejs` Ansible role provides a standardized way to install and configure Node.js and npm on various Linux distributions. This role supports both Debian-based (like Ubuntu) and RedHat-based (like CentOS) systems, ensuring consistency across different environments.

## Variables

| Variable Name                          | Default Value                           | Description                                                                 |
|----------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_nodejs_version`             | `14.x`                                  | The version of Node.js to install.                                           |
| `bootstrap_nodejs_npm_config_prefix`   | `/usr/local/lib/npm`                    | The prefix directory for npm global installations.                           |
| `bootstrap_nodejs_npm_config_unsafe_perm` | `false`                                | Whether to allow unsafe permissions for npm.                                |
| `bootstrap_nodejs_npm_global_packages` | `[]`                                    | List of npm packages to install globally.                                   |
| `bootstrap_nodejs_package_json_path`   | `""`                                    | Path to a package.json file for installing project-specific npm packages.   |
| `bootstrap_nodejs_generate_etc_profile`| `true`                                 | Whether to generate the `/etc/profile.d/npm.sh` file to add npm binaries to PATH. |
| `__bootstrap_nodejs_apt_repository_list` | `[]`                                    | Internal variable for managing apt repositories (not user-configurable).     |

## Usage

### Basic Usage

To use this role, include it in your playbook and configure the desired variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_nodejs
      vars:
        bootstrap_nodejs_version: "16.x"
        bootstrap_nodejs_npm_global_packages:
          - name: pm2
            version: "latest"
```

### Installing Project-Specific Packages

If you have a `package.json` file in your project, you can configure the role to install the packages defined in it:

```yaml
- hosts: all
  roles:
    - role: bootstrap_nodejs
      vars:
        bootstrap_nodejs_package_json_path: "/path/to/your/package.json"
```

## Dependencies

This role requires the `community.general` Ansible collection, which provides the `npm` module used to manage npm packages.

To install the required collection, run:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Version Management**: Always specify the desired Node.js version to ensure consistency across environments.
2. **Global Packages**: Use the `bootstrap_nodejs_npm_global_packages` variable to manage globally installed npm packages.
3. **Project-Specific Packages**: Use the `bootstrap_nodejs_package_json_path` variable to install packages defined in a project's `package.json` file.
4. **Path Management**: The role generates a `/etc/profile.d/npm.sh` file to add the npm binaries directory to the global PATH. Ensure this file is sourced in user sessions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_nodejs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nodejs/tasks/main.yml)
- [tasks/setup-debian.yml](../../roles/bootstrap_nodejs/tasks/setup-debian.yml)
- [tasks/setup-redhat.yml](../../roles/bootstrap_nodejs/tasks/setup-redhat.yml)