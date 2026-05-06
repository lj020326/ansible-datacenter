---
title: Bootstrap Maven Role Documentation
role: bootstrap_maven
category: Ansible Roles
type: Installation
tags: maven, installation, ansible-role
---

## Summary

The `bootstrap_maven` role is designed to automate the installation and configuration of Apache Maven on target systems. It handles downloading, extracting, and setting up Maven in a specified directory, creating symbolic links for easy access, and optionally configuring Ansible facts for further use.

## Variables

| Variable Name                  | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|--------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `maven_version`                | `3.8.4`                                                                                         | The version of Maven to be installed.                                                                                                                                                                       |
| `maven_mirror`                 | `http://archive.apache.org/dist/maven/maven-\|\| maven_version \| regex_replace('\.\*','') \|\| /{{ maven_version }}/binaries` | The base URL for the Maven mirror from which the binaries will be downloaded.                                                                                                                               |
| `maven_install_dir`            | `/opt/maven`                                                                                    | The directory where Maven will be installed.                                                                                                                                                                  |
| `maven_download_dir`           | `{{ x_ansible_download_dir \| default(ansible_env.HOME + '/.ansible/tmp/downloads') }}`          | The directory where the Maven binaries will be downloaded temporarily.                                                                                                                                      |
| `maven_download_timeout`       | `10`                                                                                            | Timeout in seconds for downloading the Maven binaries.                                                                                                                                                      |
| `maven_use_proxy`              | `true`                                                                                          | Whether to use a proxy when downloading Maven binaries.                                                                                                                                                   |
| `maven_validate_certs`         | `true`                                                                                          | Whether to validate SSL certificates when downloading Maven binaries.                                                                                                                                       |
| `maven_is_default_installation`| `true`                                                                                          | If set to true, symbolic links for `mvn` and `mvnDebug` will be created in `/usr/local/bin`.                                                                                                                 |
| `maven_fact_group_name`        | `maven`                                                                                         | The name of the fact group used when creating Ansible facts for Maven.                                                                                                                                      |

## Usage

To use the `bootstrap_maven` role, include it in your playbook and specify any variables you wish to override from their default values.

Example Playbook:
```yaml
- hosts: all
  roles:
    - role: bootstrap_maven
      vars:
        maven_version: 3.8.6
```

## Dependencies

This role has the following dependencies:

- `which` package (for locating binaries)
- `tar`, `unzip`, and `gzip` packages (for extracting archives)

These dependencies are automatically installed by the role as required.

## Tags

No specific tags are defined in this role. However, you can use the default Ansible tags to target specific tasks if needed.

## Best Practices

- Ensure that the specified Maven version is available at the provided mirror URL.
- Adjust `maven_download_dir` and `maven_install_dir` as necessary based on your system's file structure and permissions.
- Set `maven_use_proxy` and `maven_validate_certs` according to your network environment.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios for testing in various environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_maven/defaults/main.yml)
- [tasks/create-symbolic-links.yml](../../roles/bootstrap_maven/tasks/create-symbolic-links.yml)
- [tasks/main.yml](../../roles/bootstrap_maven/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_maven/handlers/main.yml)