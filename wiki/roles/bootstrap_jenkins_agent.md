---
title: "Jenkins Agent Bootstrap Role"
role: bootstrap_jenkins_agent
category: Ansible Roles
type: Infrastructure Automation
tags: jenkins, ansible, ci/cd, automation
---

## Summary

The `bootstrap_jenkins_agent` role is designed to automate the setup and configuration of Jenkins agents on various operating systems. This role handles tasks such as downloading the Jenkins agent software, configuring system services, registering agents with a Jenkins controller, and ensuring that the agents are properly integrated into the CI/CD pipeline.

## Variables

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_agent__controller`               | `jenkins.example.int`                                                                                 | The hostname or IP address of the Jenkins controller.                                                                                                                                                       |
| `jenkins_agent__controller_port`          | `"443"`                                                                                                 | The port on which the Jenkins controller is accessible.                                                                                                                                                     |
| `jenkins_agent__controller_protocol`      | `"https"`                                                                                               | The protocol used to communicate with the Jenkins controller (http or https).                                                                                                                             |
| `jenkins_agent__controller_url`           | `"{{ jenkins_agent__controller_protocol }}://{{ jenkins_agent__controller }}:{{ jenkins_agent__controller_port }}"` | The full URL of the Jenkins controller.                                                                                                                                                                     |
| `jenkins_agent__tunnel`                   | `"{{ jenkins_agent__controller }}:9000"`                                                                | The tunnel address for connecting to the Jenkins controller.                                                                                                                                                |
| `jenkins_agent__username`                 | `jenkins_agent`                                                                                         | The username used to authenticate with the Jenkins controller.                                                                                                                                            |
| `jenkins_agent__password_file`            | `"{{ jenkins_agent__path }}/password.jenkins-agent"`                                                    | The path to the file where the agent's password is stored.                                                                                                                                                |
| `jenkins_agent__name`                     | `"{{ inventory_hostname }}"`                                                                              | The name of the Jenkins agent, typically set to the hostname.                                                                                                                                             |
| `jenkins_agent__num_executors_min`        | `4`                                                                                                     | The minimum number of executors for the agent.                                                                                                                                                              |
| `jenkins_agent__num_executors`            | `"{{ [ansible_facts['processor_cores'] | d(1) * 2, jenkins_agent__num_executors_min] | max }}"`          | The calculated number of executors based on system cores and minimum executors.                                                                                                                           |
| `jenkins_agent__labels`                   | `"{{ (ansible_os_family | lower() == 'windows') | ternary(['windows'], ['linux']) | list }}"`           | Labels assigned to the Jenkins agent, used for job distribution.                                                                                                                                          |
| `jenkins_agent__label`                    | `"{{ jenkins_agent__labels | join(' ') }}"`                                                              | A single string of labels joined by spaces.                                                                                                                                                                 |
| `jenkins_agent__log_file`                 | `"{{ jenkins_agent__path }}/jenkins-agent.log"`                                                         | The path to the log file for the Jenkins agent.                                                                                                                                                             |
| `jenkins_agent__additional_args`          | `['failIfWorkDirIsMissing']`                                                                            | Additional arguments passed to the Jenkins agent.                                                                                                                                                           |
| `jenkins_agent__systemd_service_dir`      | `/lib/systemd/system`                                                                                   | The directory where systemd service files are stored.                                                                                                                                                       |
| `jenkins_agent__conf`                     | (empty)                                                                                                 | Placeholder for additional configuration settings.                                                                                                                                                            |
| `jenkins_agent__download_url`             | `"{{ jenkins_agent__controller_url }}/jnlpJars/agent.jar"`                                              | The URL to download the Jenkins agent JAR file.                                                                                                                                                             |
| `jenkins_agent__validate_certs`           | `true`                                                                                                  | Whether to validate SSL certificates when communicating with the Jenkins controller.                                                                                                                      |
| `jenkins_agent__path`                     | `/var/lib/jenkins-agent`                                                                                | The base directory for the Jenkins agent files.                                                                                                                                                             |
| `jenkins_agent__config_path`              | `/etc/jenkins-agent`                                                                                    | The configuration directory for the Jenkins agent.                                                                                                                                                          |
| `jenkins_agent__task_name`                | `Jenkins Agent`                                                                                         | The name of the task used in Windows service management.                                                                                                                                                  |
| `jenkins_agent__systemd_path`             | `/lib/systemd/system`                                                                                   | The path to the systemd directory where the Jenkins agent service file will be placed.                                                                                                                    |
| `jenkins_agent__service_name`             | `jenkins-agent`                                                                                         | The name of the systemd service for the Jenkins agent.                                                                                                                                                      |
| `jenkins_agent__service_force_update`     | `true`                                                                                                  | Whether to force update the systemd service file if it already exists.                                                                                                                                      |
| `jenkins_agent__work_dir`                 | `/home/jenkins/agent`                                                                                   | The working directory for the Jenkins agent.                                                                                                                                                                |
| `jenkins_agent__remoting_dir`             | `"{{ jenkins_agent__work_dir }}/remoting"`                                                               | The remoting directory used by the Jenkins agent.                                                                                                                                                           |
| `jenkins_agent__jenkins_user_groups`      | `['docker']`                                                                                            | Additional groups to which the Jenkins user will be added.                                                                                                                                                |
| `jenkins_agent__jre_packages`             | `['default-jre']`                                                                                       | The Java Runtime Environment packages to install on Linux systems.                                                                                                                                        |
| `jenkins_agent__java_home`                | `/etc/alternatives/java`                                                                                | The path to the Java home directory.                                                                                                                                                                        |
| `jenkins_agent__wrapper_version`          | `2.0.3`                                                                                                 | The version of the Jenkins Service Wrapper to use on Windows systems.                                                                                                                                       |
| `jenkins_agent__wrapper_download_url`     | `"{{ jenkins_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_agent__wrapper_version }}/winsw-{{jenkins_agent__wrapper_version}}-bin.exe"` | The URL to download the Jenkins Service Wrapper for Windows.                                                                                                                                                |
| `jenkins_agent__win_java_version`         | `8.0.144`                                                                                               | The version of Java to install on Windows systems using Chocolatey.                                                                                                                                         |
| `jenkins_agent__win_base_jenkins_path`    | `C:\jenkins-agent`                                                                                      | The base directory for Jenkins agent files on Windows systems.                                                                                                                                              |
| `jenkins_agent__win_jenkins_agent_jar_path`| `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.jar"`                                               | The path to the Jenkins agent JAR file on Windows systems.                                                                                                                                                |
| `jenkins_agent__win_jenkins_agent_wrapper_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.exe"`                                         | The path to the Jenkins Service Wrapper executable on Windows systems.                                                                                                                                    |
| `jenkins_agent__win_jenkins_agent_wrapper_config_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.xml"`                                 | The path to the configuration file for the Jenkins Service Wrapper on Windows systems.                                                                                                                    |
| `jenkins_agent__register_with_controller` | `true`                                                                                                  | Whether to automatically register the agent with the Jenkins controller during setup.                                                                                                                       |

## Usage

To use this role, include it in your Ansible playbook and provide the necessary variables as needed. Here is an example of how you might include this role in a playbook:

```yaml
- name: Bootstrap Jenkins Agents
  hosts: jenkins_agents
  become: yes
  roles:
    - role: bootstrap_jenkins_agent
      vars:
        jenkins_agent__controller: "jenkins.example.com"
        jenkins_agent__username: "admin"
        jenkins_agent__password_file: "/etc/jenkins-agent/password.jenkins-agent"
```

## Dependencies

This role depends on the following:

- `ansible.builtin` modules for basic Ansible operations.
- `community.general.xml` module to parse XML content (used in agent registration).
- `chocolatey.chocolatey.win_chocolatey` module for installing Java on Windows systems.

Ensure that these dependencies are available in your Ansible environment. For Windows, you may need to install the Chocolatey package manager and the corresponding Ansible collection.

## Best Practices

1. **Security**: Ensure that sensitive information such as passwords is stored securely using Ansible Vault or other secure methods.
2. **Configuration Management**: Use variables to customize agent configurations without modifying role files directly.
3. **Testing**: Test the role in a staging environment before deploying it to production to ensure compatibility and functionality.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Molecule installed along with any necessary dependencies for your testing environment.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_jenkins_agent/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_agent/tasks/main.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_agent/handlers/main.yml)