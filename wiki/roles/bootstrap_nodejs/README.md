---
title: Ansible Role: bootstrap_nodejs
original_path: roles/bootstrap_nodejs/README.md
category: Ansible
tags:
  - Ansible
  - Node.js
  - RHEL
  - CentOS
  - Debian
  - Ubuntu
harvested_date: '2023-08-07T18:07:09.362814+00:00'
source_type: legacy_markdown
---

# Ansible Role: bootstrap_nodejs

Installs Node.js on RHEL/CentOS or Debian/Ubuntu systems. This role handles the installation of Node.js and npm, configuration of npm settings, and installation of global npm packages.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

- `bootstrap_nodejs__version: "14.x"`

  The Node.js version to install. "14.x" is the default and works on most supported OSes. Other versions such as "8.x", "10.x", "13.x", etc. should work on the latest versions of Debian/Ubuntu and RHEL/CentOS.

- `bootstrap_nodejs__install_npm_user: "{{ ansible_ssh_user }}`

  The user for whom the npm packages will be installed can be set here, this defaults to `ansible_user`.

- `bootstrap_nodejs__npm_config_prefix: "/usr/local/lib/npm"`

  The global installation directory. This should be writable by the `bootstrap_nodejs__install_npm_user`.

- `bootstrap_nodejs__npm_config_unsafe_perm: "false"`

  Set to true to suppress the UID/GID switching when running package scripts. If set explicitly to false, then installing as a non-root user will fail.

- `bootstrap_nodejs__npm_global_packages: []`

  A list of npm packages with a `name` and (optional) `version` to be installed globally. For example:

  ```yaml
  bootstrap_nodejs__npm_global_packages:
    # Install a specific version of a package.
    - name: jslint
      version: 0.9.3
    # Install the latest stable release of a package.
    - name: node-sass
    # This shorthand syntax also works (same as previous example).
    - node-sass
  ```

- `bootstrap_nodejs__package_json_path: ""`

  Set a path pointing to a particular `package.json` (e.g. `"/var/www/app/package.json"`). This will install all of the defined packages globally using Ansible's `npm` module.

- `bootstrap_nodejs__generate_etc_profile: "true"`

  By default, the role will create `/etc/profile.d/npm.sh` with exported variables (`PATH`, `NPM_CONFIG_PREFIX`, `NODE_PATH`). If you prefer to avoid generating that file (e.g., you want to set the variables yourself for a non-global install), set it to "false".

## Dependencies

None.

## Example Playbook

```yaml
- hosts: utility
  vars_files:
    - vars/main.yml
  roles:
    - bootstrap_nodejs
```

*Inside `vars/main.yml`*:

```yaml
bootstrap_nodejs__version: "14.x"
bootstrap_nodejs__npm_global_packages:
  - name: jslint
  - name: node-sass
```

## Verification

To verify the installation, you can run:

```yaml
- name: Verify Node.js installation
  command: node -v
  register: node_version

- name: Display Node.js version
  debug:
    var: node_version.stdout
```

## Known Issues

- On some systems, you might need to install additional dependencies manually.

## Backlinks

<!-- Backlinks section will be populated automatically -->