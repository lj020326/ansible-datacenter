---
title: "Jenkins Agent Bootstrap Role"
role: bootstrap_jenkins_agent
category: Jenkins
type: Ansible Role
tags: jenkins, ansible, ci/cd, automation
---

## Summary

The `bootstrap_jenkins_agent` role is designed to automate the setup and configuration of Jenkins agents on various operating systems. This includes downloading the Jenkins agent software, configuring system services, registering the agent with a Jenkins controller, and ensuring that the agent can communicate securely with the controller.

## Variables

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_agent__controller`               | `jenkins.example.int`                                                                         | The hostname or IP address of the Jenkins controller.                                                                                                                                                         |
| `jenkins_agent__controller_port`          | `"443"`                                                                                         | The port on which the Jenkins controller is running.                                                                                                                                                          |
| `jenkins_agent__controller_protocol`      | `"https"`                                                                                       | The protocol used to communicate with the Jenkins controller (e.g., `http`, `https`).                                                                                                                       |
| `jenkins_agent__controller_url`           | `"{{ jenkins_agent__controller_protocol }}://{{ jenkins_agent__controller }}:{{ jenkins_agent__controller_port }}"` | The full URL of the Jenkins controller.                                                                                                                                                                     |
| `jenkins_agent__tunnel`                   | `"{{ jenkins_agent__controller }}:9000"`                                                       | The tunnel address for the agent to connect through.                                                                                                                                                          |
| `jenkins_agent__username`                 | `jenkins_agent`                                                                               | The username used to authenticate with the Jenkins controller.                                                                                                                                                |
| `jenkins_agent__password_file`            | `"{{ jenkins_agent__path }}/password.jenkins-agent"`                                            | The path where the agent's password file will be stored.                                                                                                                                                      |
| `jenkins_agent__name`                     | `"{{ inventory_hostname }}"`                                                                    | The name of the Jenkins agent, typically set to the inventory hostname.                                                                                                                                     |
| `jenkins_agent__num_executors_min`        | `4`                                                                                             | The minimum number of executors for the agent.                                                                                                                                                              |
| `jenkins_agent__num_executors`            | `"{{ [ansible_facts['processor_cores'] \| d(1) * 2, jenkins_agent__num_executors_min] \| max }}"`   | The calculated number of executors based on processor cores or minimum executors.                                                                                                                           |
| `jenkins_agent__labels`                   | `"{{ (ansible_os_family \| lower() == 'windows') \| ternary(['windows'], ['linux']) \| list }}"`  | Labels assigned to the Jenkins agent, determined by OS family.                                                                                                                                              |
| `jenkins_agent__label`                    | `"{{ jenkins_agent__labels \| join(' ') }}"`                                                     | A single string of labels for the agent.                                                                                                                                                                    |
| `jenkins_agent__log_file`                 | `"{{ jenkins_agent__path }}/jenkins-agent.log"`                                                  | The path to the log file for the Jenkins agent.                                                                                                                                                             |
| `jenkins_agent__additional_args`          | `["failIfWorkDirIsMissing"]`                                                                    | Additional arguments passed to the Jenkins agent.                                                                                                                                                           |
| `jenkins_agent__systemd_service_dir`      | `/lib/systemd/system`                                                                           | The directory where systemd service files are stored.                                                                                                                                                         |
| `jenkins_agent__download_url`             | `"{{ jenkins_agent__controller_url }}/jnlpJars/agent.jar"`                                      | The URL to download the Jenkins agent JAR file from the controller.                                                                                                                                         |
| `jenkins_agent__validate_certs`           | `true`                                                                                          | Whether to validate SSL certificates when communicating with the Jenkins controller.                                                                                                                        |
| `jenkins_agent__path`                     | `/var/lib/jenkins-agent`                                                                        | The base directory for the Jenkins agent files.                                                                                                                                                             |
| `jenkins_agent__config_path`              | `/etc/jenkins-agent`                                                                            | The configuration path for the Jenkins agent.                                                                                                                                                               |
| `jenkins_agent__task_name`                | `Jenkins Agent`                                                                                 | The name of the task or service for the Jenkins agent on Windows.                                                                                                                                           |
| `jenkins_agent__systemd_path`             | `/lib/systemd/system`                                                                           | The directory where systemd service files are stored (Linux).                                                                                                                                               |
| `jenkins_agent__service_name`             | `jenkins-agent`                                                                                 | The name of the systemd service for the Jenkins agent.                                                                                                                                                    |
| `jenkins_agent__service_force_update`     | `true`                                                                                          | Whether to force update the systemd service file.                                                                                                                                                           |
| `jenkins_agent__work_dir`                 | `/home/jenkins/agent`                                                                           | The working directory for the Jenkins agent.                                                                                                                                                                |
| `jenkins_agent__remoting_dir`             | `"{{ jenkins_agent__work_dir }}/remoting"`                                                      | The remoting directory used by the Jenkins agent.                                                                                                                                                           |
| `jenkins_agent__jenkins_user_groups`      | `["docker"]`                                                                                    | Additional groups to which the Jenkins user will be added.                                                                                                                                                |
| `jenkins_agent__jre_packages`             | `["default-jre"]`                                                                               | The Java Runtime Environment packages to install on Linux systems.                                                                                                                                          |
| `jenkins_agent__java_home`                | `/etc/alternatives/java`                                                                        | The path to the Java home directory.                                                                                                                                                                        |
| `jenkins_agent__wrapper_version`          | `2.0.3`                                                                                         | The version of the Jenkins Service Wrapper for Windows.                                                                                                                                                     |
| `jenkins_agent__wrapper_download_url`     | `"{{ jenkins_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_agent__wrapper_version }}/winsw-{{jenkins_agent__wrapper_version}}-bin.exe"` | The URL to download the Jenkins Service Wrapper for Windows.                                                                                                                                                |
| `jenkins_agent__win_java_version`         | `8.0.144`                                                                                       | The version of Java to install on Windows systems using Chocolatey.                                                                                                                                         |
| `jenkins_agent__win_base_jenkins_path`    | `C:\jenkins-agent`                                                                              | The base directory for Jenkins agent files on Windows systems.                                                                                                                                              |
| `jenkins_agent__win_jenkins_agent_jar_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.jar"`                                      | The path to the Jenkins agent JAR file on Windows systems.                                                                                                                                                |
| `jenkins_agent__win_jenkins_agent_wrapper_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.exe"`                                  | The path to the Jenkins Service Wrapper executable on Windows systems.                                                                                                                                      |
| `jenkins_agent__win_jenkins_agent_wrapper_config_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\agent.xml"`                            | The path to the Jenkins Service Wrapper configuration file on Windows systems.                                                                                                                              |
| `jenkins_agent__register_with_controller` | `true`                                                                                          | Whether to register the agent with the Jenkins controller during setup.                                                                                                                                     |

## Usage

To use the `bootstrap_jenkins_agent` role, include it in your Ansible playbook and provide the necessary variables as per your environment configuration.

### Example Playbook

```yaml
---
- name: Bootstrap Jenkins Agents
  hosts: jenkins_agents
  become: yes
  roles:
    - role: bootstrap_jenkins_agent
      vars:
        jenkins_agent__controller: "jenkins.example.com"
        jenkins_agent__username: "admin"
        jenkins_agent__password: "{{ lookup('file', '/path/to/jenkins_password') }}"
```

## Dependencies

- **Ansible**: The role requires Ansible 2.9 or later.
- **Chocolatey**: Required for installing Java on Windows systems.

## Best Practices

1. **Secure Communication**: Ensure that `jenkins_agent__validate_certs` is set to `true` and use HTTPS for secure communication with the Jenkins controller.
2. **Resource Allocation**: Adjust `jenkins_agent__num_executors_min` based on the available resources of the agent machine.
3. **User Management**: Add necessary groups to `jenkins_agent__jenkins_user_groups` if the agent requires access to specific system resources.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_jenkins_agent/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_agent/tasks/main.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_agent/handlers/main.yml)