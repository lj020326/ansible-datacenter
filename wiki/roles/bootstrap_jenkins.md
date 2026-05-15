---
title: "Jenkins Bootstrap Role"
role: bootstrap_jenkins
category: CI/CD
type: Ansible Role
tags: jenkins, ci-cd, automation
---

## Summary

The `bootstrap_jenkins` role is designed to automate the installation and configuration of Jenkins on Debian and RedHat-based systems. It handles repository setup, package installation, service management, initial configuration settings, plugin installation, and proxy configuration.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_package_state`                 | `present`                                                                     | The desired state of the Jenkins package (`present`, `absent`).                                                                                                                                             |
| `jenkins_prefer_lts`                    | `false`                                                                       | Whether to prefer the Long-Term Support (LTS) version of Jenkins.                                                                                                                                           |
| `jenkins_connection_delay`              | `5`                                                                           | The delay in seconds between connection retries when waiting for Jenkins to start.                                                                                                                            |
| `jenkins_connection_retries`            | `60`                                                                          | The number of times to retry the connection check before failing.                                                                                                                                             |
| `jenkins_home`                          | `/var/lib/jenkins`                                                            | The home directory for Jenkins data and configuration files.                                                                                                                                                  |
| `jenkins_hostname`                      | `localhost`                                                                   | The hostname or IP address where Jenkins is accessible.                                                                                                                                                       |
| `jenkins_http_port`                     | `8080`                                                                        | The port on which Jenkins will listen for HTTP requests.                                                                                                                                                    |
| `jenkins_jar_location`                  | `/opt/jenkins-cli.jar`                                                        | The location to save the Jenkins CLI jar file.                                                                                                                                                              |
| `jenkins_url_prefix`                    | `""`                                                                          | A URL prefix if Jenkins is served under a subpath (e.g., `/jenkins`).                                                                                                                                       |
| `jenkins_options`                       | `""`                                                                          | Additional options to pass to the Jenkins service.                                                                                                                                                          |
| `jenkins_java_options`                  | `-Djenkins.install.runSetupWizard=false`                                      | Java options for Jenkins, including disabling the setup wizard by default.                                                                                                                                    |
| `jenkins_plugins`                       | `[]`                                                                          | A list of plugins to install on Jenkins. Each plugin can be specified as a string or a dictionary with `name` and optional `version`.                                                                       |
| `jenkins_plugins_state`                 | `present`                                                                     | The desired state for the listed plugins (`present`, `absent`).                                                                                                                                             |
| `jenkins_plugin_updates_expiration`     | `86400`                                                                       | The expiration time in seconds for cached plugin updates.                                                                                                                                                   |
| `jenkins_plugin_timeout`                | `30`                                                                          | Timeout in seconds for installing each plugin.                                                                                                                                                              |
| `jenkins_plugins_install_dependencies`  | `true`                                                                        | Whether to install dependencies of the specified plugins automatically.                                                                                                                                       |
| `jenkins_updates_url`                   | `https://updates.jenkins.io`                                                | The URL for Jenkins updates and plugin information.                                                                                                                                                         |
| `jenkins_admin_username`                | `admin`                                                                       | The username for the Jenkins admin account.                                                                                                                                                                 |
| `jenkins_admin_password`                | `admin`                                                                       | The password for the Jenkins admin account (not recommended to use in production).                                                                                                                          |
| `jenkins_admin_password_file`           | `""`                                                                          | Path to a file containing the admin password, if provided. Overrides `jenkins_admin_password`.                                                                                                                |
| `jenkins_process_user`                  | `jenkins`                                                                     | The user under which Jenkins will run.                                                                                                                                                                      |
| `jenkins_process_group`                 | `"{{ jenkins_process_user }}"`                                              | The group under which Jenkins will run (defaults to the same as the process user).                                                                                                                          |
| `jenkins_init_changes`                  | List of options for Jenkins service configuration, see `defaults/main.yml`.   | A list of changes to apply to the Jenkins service configuration file.                                                                                                                                       |
| `jenkins_proxy_host`                    | `""`                                                                          | The hostname or IP address of the proxy server.                                                                                                                                                             |
| `jenkins_proxy_port`                    | `""`                                                                          | The port number of the proxy server.                                                                                                                                                                        |
| `jenkins_proxy_noproxy`                 | List of hosts that do not require a proxy, see `defaults/main.yml`.           | A list of hosts or IP addresses that should be accessed directly without using the proxy.                                                                                                                   |
| `jenkins_init_folder`                   | `/etc/systemd/system/jenkins.service.d`                                       | The directory where Jenkins service overrides are stored.                                                                                                                                                   |
| `jenkins_init_file`                     | `"{{ jenkins_init_folder }}/override.conf"`                                   | The path to the Jenkins service override configuration file.                                                                                                                                                |

## Usage
To use this role, include it in your playbook and specify any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Install and configure Jenkins
  hosts: jenkins_servers
  become: yes
  roles:
    - role: bootstrap_jenkins
      vars:
        jenkins_plugins:
          - name: git
          - name: workflow-aggregator
            version: "2.6"
```

## Dependencies
- `community.general` collection (for the `jenkins_plugin` module).

Ensure that the `community.general` collection is installed:

```bash
ansible-galaxy collection install community.general
```

## Tags
- `skip_ansible_lint`: Used to skip specific tasks from being linted by Ansible Lint.
- `restart jenkins`: Restarts the Jenkins service when changes are made that require a restart.

## Best Practices
- **Security**: Avoid hardcoding sensitive information like passwords in playbooks. Use variables or vaults instead.
- **Version Control**: Specify exact versions of plugins and Jenkins itself to avoid unexpected behavior due to version upgrades.
- **Testing**: Use Molecule tests to verify the role's functionality across different operating systems.

## Molecule Tests
This role includes Molecule tests to ensure it works as expected. To run the tests, execute:

```bash
molecule test
```

Ensure you have Molecule and its dependencies installed before running the tests.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_jenkins/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins/tasks/main.yml)
- [tasks/plugins.yml](../../roles/bootstrap_jenkins/tasks/plugins.yml)
- [tasks/settings.yml](../../roles/bootstrap_jenkins/tasks/settings.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_jenkins/tasks/setup-Debian.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_jenkins/tasks/setup-RedHat.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins/handlers/main.yml)