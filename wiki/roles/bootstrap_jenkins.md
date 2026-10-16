---
title: "Bootstrap Jenkins Role"
role: bootstrap_jenkins
category: CI/CD
type: role
tags: [ansible, role, bootstrap_jenkins]
---

```yaml
---
role: bootstrap_jenkins
category: CI/CD
type: role
summary: |
  The `bootstrap_jenkins` role provides a comprehensive solution for installing and configuring Jenkins on both Debian and RedHat-based systems. It handles the installation of Jenkins, its dependencies, and configuration of plugins, proxy settings, and security settings. This role ensures Jenkins is set up to run as a service and is ready for use in a CI/CD pipeline.

variables: |
  | Variable Name                    | Default Value                       | Description                                                                                     |
  |----------------------------------|-------------------------------------|-------------------------------------------------------------------------------------------------|
  | `jenkins_package_state`          | `present`                           | State of the Jenkins package (present/absent).                                                   |
  | `jenkins_prefer_lts`             | `false`                             | Prefer Long Term Support (LTS) version of Jenkins.                                              |
  | `jenkins_connection_delay`       | `5`                                 | Delay between retries when waiting for Jenkins to start.                                        |
  | `jenkins_connection_retries`     | `60`                                | Number of retries when waiting for Jenkins to start.                                             |
  | `jenkins_home`                   | `/var/lib/jenkins`                  | Jenkins home directory.                                                                         |
  | `jenkins_hostname`               | `localhost`                         | Hostname where Jenkins is accessible.                                                           |
  | `jenkins_http_port`              | `8080`                              | HTTP port where Jenkins is accessible.                                                          |
  | `jenkins_jar_location`           | `/opt/jenkins-cli.jar`              | Location of the Jenkins CLI jar file.                                                           |
  | `jenkins_url_prefix`             | `""`                                | URL prefix for Jenkins.                                                                         |
  | `jenkins_options`                | `""`                                | Additional Jenkins options.                                                                     |
  | `jenkins_java_options`           | `-Djenkins.install.runSetupWizard=false` | Java options for Jenkins.                                                                      |
  | `jenkins_plugins`                | `[]`                                | List of Jenkins plugins to install.                                                             |
  | `jenkins_plugins_state`          | `present`                           | State of Jenkins plugins (present/absent).                                                      |
  | `jenkins_plugin_updates_expiration` | `86400`                           | Expiration time for plugin updates in seconds.                                                  |
  | `jenkins_plugin_timeout`         | `30`                                | Timeout for plugin installation in seconds.                                                     |
  | `jenkins_plugins_install_dependencies` | `true`                           | Install dependencies for Jenkins plugins.                                                       |
  | `jenkins_updates_url`            | `https://updates.jenkins.io`        | URL for Jenkins updates.                                                                       |
  | `jenkins_admin_username`         | `admin`                             | Jenkins admin username.                                                                         |
  | `jenkins_admin_password`         | `admin`                             | Jenkins admin password.                                                                         |
  | `jenkins_admin_password_file`    | `""`                                | Path to a file containing the Jenkins admin password.                                           |
  | `jenkins_process_user`           | `jenkins`                           | User that runs the Jenkins process.                                                             |
  | `jenkins_process_group`          | `{{ jenkins_process_user }}`       | Group that runs the Jenkins process.                                                            |
  | `jenkins_init_changes`           | List of initialization changes for Jenkins | List of initialization changes for Jenkins.                                                     |
  | `jenkins_proxy_host`             | `""`                                | Proxy host for Jenkins.                                                                         |
  | `jenkins_proxy_port`             | `""`                                | Proxy port for Jenkins.                                                                         |
  | `jenkins_proxy_noproxy`          | `["127.0.0.1", "localhost"]`       | List of hosts that should not use the proxy.                                                    |
  | `jenkins_init_folder`            | `/etc/systemd/system/jenkins.service.d` | Directory for Jenkins initialization files.                                                    |
  | `jenkins_init_file`              | `{{ jenkins_init_folder }}/override.conf` | Jenkins initialization file.                                                                   |

usage: |
  To use the `bootstrap_jenkins` role, include it in your playbook and configure the variables as needed. Here is an example playbook:

  ```yaml
  - hosts: jenkins_servers
    become: yes
    roles:
      - role: bootstrap_jenkins
        vars:
          jenkins_plugins:
            - name: git
            - name: github
            - name: blueocean
          jenkins_admin_password: "secure_password"
          jenkins_prefer_lts: true
  ```

dependencies: |
  This role does not have any external dependencies, but it requires the `community.general` collection (version >= 3.0.0) for the `jenkins_plugin` module.

best_practices: |
  - Ensure that the Jenkins admin password is securely managed, either by setting it directly or by using a file.
  - Regularly update Jenkins and its plugins to benefit from the latest features and security patches.
  - Use the `jenkins_prefer_lts` variable to ensure stability by preferring LTS versions of Jenkins.
  - Configure proxy settings if Jenkins needs to access resources through a proxy.
  - Secure Jenkins by configuring appropriate security settings and plugins.
  - Backup Jenkins configurations and critical data regularly.
  - Monitor Jenkins performance and resource usage.

backlinks: |
  - [defaults/main.yml](../../roles/bootstrap_jenkins/defaults/main.yml)
  - [tasks/main.yml](../../roles/bootstrap_jenkins/tasks/main.yml)
  - [tasks/plugins.yml](../../roles/bootstrap_jenkins/tasks/plugins.yml)
  - [tasks/settings.yml](../../roles/bootstrap_jenkins/tasks/settings.yml)
  - [tasks/setup-Debian.yml](../../roles/bootstrap_jenkins/tasks/setup-Debian.yml)
  - [tasks/setup-RedHat.yml](../../roles/bootstrap_jenkins/tasks/setup-RedHat.yml)
  - [handlers/main.yml](../../roles/bootstrap_jenkins/handlers/main.yml)