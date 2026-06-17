---
title: Bootstrap Maven Role Documentation
role: bootstrap_maven
category: Ansible Roles
type: Installation
tags: maven, ansible, automation
---

## Summary

The `bootstrap_maven` role automates the installation of Apache Maven on target systems. It handles downloading, extracting, and configuring Maven, along with creating symbolic links for easy access to the Maven binaries. Additionally, it sets up Ansible facts to provide information about the installed Maven version.

## Variables

| Variable Name                  | Default Value                                                                                           | Description                                                                                                                                 |
|--------------------------------|---------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `maven_version`                | `3.8.4`                                                                                                 | The version of Maven to install.                                                                                                            |
| `maven_mirror`                 | `http://archive.apache.org/dist/maven/maven-{{ maven_version \| regex_replace('\..*', '') }}/{{ maven_version }}/binaries` | The base URL for downloading the Maven binaries.                                                                                              |
| `maven_install_dir`            | `/opt/maven`                                                                                            | The directory where Maven will be installed.                                                                                                |
| `maven_download_dir`           | `{{ x_ansible_download_dir \| default(ansible_facts.env.HOME + '/.ansible/tmp/downloads') }}`          | The directory where the Maven binaries will be downloaded temporarily.                                                                      |
| `maven_download_timeout`       | `10`                                                                                                    | Timeout in seconds for downloading Maven binaries.                                                                                        |
| `maven_use_proxy`              | `true`                                                                                                  | Whether to use a proxy for downloading Maven binaries.                                                                                    |
| `maven_validate_certs`         | `true`                                                                                                  | Whether to validate SSL certificates when downloading Maven binaries.                                                                       |
| `maven_is_default_installation`| `true`                                                                                                  | Whether to create symbolic links for the Maven binaries in `/usr/local/bin`.                                                                |
| `maven_fact_group_name`        | `maven`                                                                                                 | The name of the Ansible fact group that will store information about the installed Maven version.                                           |

## Usage

To use the `bootstrap_maven` role, include it in your playbook and optionally override any default variables as needed.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_maven
      vars:
        maven_version: 3.8.6
```

## Dependencies

This role has the following dependencies:

- **Package Manager**: The role supports `yum`, `dnf`, and `zypper` for installing necessary packages like `which`, `tar`, `unzip`, and `gzip`.
- **Ansible Modules**: The role uses standard Ansible modules such as `package`, `get_url`, `file`, `unarchive`, `template`, and `setup`.

## Best Practices

1. **Version Control**: Always specify the Maven version to ensure consistency across environments.
2. **Proxy Configuration**: If you are behind a proxy, make sure to configure your Ansible environment to use the proxy settings.
3. **SSL Validation**: Ensure SSL certificates are validated during downloads for security purposes.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios to ensure the role functions correctly across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_maven/defaults/main.yml)
- [tasks/create-symbolic-links.yml](../../roles/bootstrap_maven/tasks/create-symbolic-links.yml)
- [tasks/main.yml](../../roles/bootstrap_maven/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_maven/handlers/main.yml)