---
title: Bootstrap Node.js Role Documentation
role: bootstrap_nodejs
category: Ansible Roles
type: Configuration Management
tags: nodejs, npm, automation, ansible
---

## Summary

The `bootstrap_nodejs` role is designed to automate the installation and configuration of Node.js and npm on various Linux distributions. It supports Debian-based (e.g., Ubuntu) and Red Hat-based (e.g., CentOS) systems. The role allows users to specify the version of Node.js, configure npm settings, install global npm packages, and optionally add npm binaries to the system's PATH.

## Variables

| Variable Name                         | Default Value                      | Description                                                                 |
|---------------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_nodejs__version`           | `14.x`                             | The version of Node.js to be installed. Use 'x' as a wildcard for minor versions. |
| `bootstrap_nodejs__npm_config_prefix` | `/usr/local/lib/npm`               | The directory where npm will install global packages.                       |
| `bootstrap_nodejs__npm_config_unsafe_perm` | `false`                          | Whether to allow npm to run scripts with root privileges.                   |
| `bootstrap_nodejs__npm_global_packages` | `[]`                               | A list of npm packages to be installed globally. Each item can be a string or a dictionary specifying the package name and version. |
| `bootstrap_nodejs__package_json_path` | `""`                               | The path to a `package.json` file from which dependencies should be installed.|
| `bootstrap_nodejs__generate_etc_profile` | `true`                            | Whether to generate an `/etc/profile.d/npm.sh` script to add npm binaries to the global PATH. |

## Usage

To use the `bootstrap_nodejs` role, include it in your playbook and optionally override any of the default variables as needed.

### Example Playbook

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_nodejs
      vars:
        bootstrap_nodejs__version: "16.x"
        bootstrap_nodejs__npm_global_packages:
          - name: pm2
            version: latest
          - name: http-server
```

### Example with `package.json`

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_nodejs
      vars:
        bootstrap_nodejs__package_json_path: "/path/to/package.json"
```

## Dependencies

This role does not have any external dependencies other than the standard Ansible modules used in its tasks.

## Tags

The `bootstrap_nodejs` role uses the following tags:

- `nodejs`: For tasks related to Node.js installation.
- `npm`: For tasks related to npm configuration and package management.

You can use these tags to selectively run parts of the role. For example, to only install Node.js without configuring npm:

```bash
ansible-playbook -i inventory playbook.yml --tags nodejs
```

## Best Practices

1. **Specify Versions**: Always specify a version for Node.js to ensure consistency across environments.
2. **Global Packages**: Use `bootstrap_nodejs__npm_global_packages` to manage global npm packages, ensuring they are installed and up-to-date.
3. **Environment Configuration**: Adjust `bootstrap_nodejs__npm_config_prefix` if you need to change the default installation directory for npm packages.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, navigate to the role's directory and execute:

```bash
molecule test
```

Ensure that Docker is installed on your system as it is used by Molecule for testing.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_nodejs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nodejs/tasks/main.yml)
- [tasks/setup-debian.yml](../../roles/bootstrap_nodejs/tasks/setup-debian.yml)
- [tasks/setup-redhat.yml](../../roles/bootstrap_nodejs/tasks/setup-redhat.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_nodejs` role, covering its purpose, configuration options, usage examples, and best practices. For more detailed information, refer to the linked source files.