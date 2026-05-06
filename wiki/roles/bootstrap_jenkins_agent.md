---
title: "Jenkins Agent Bootstrap Role"
role: bootstrap_jenkins_agent
category: Jenkins
type: Ansible Role
tags: jenkins, ansible, ci/cd, automation

---

## Summary

The `bootstrap_jenkins_agent` role is designed to automate the setup and configuration of Jenkins agents on various operating systems. It handles tasks such as downloading the Jenkins agent software, configuring system services, registering the agent with a Jenkins controller, and ensuring that the agent can communicate securely with the controller.

## Variables

| Variable Name                            | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_agent__controller`              | `jenkins.example.int`                                                                                 | The hostname or IP address of the Jenkins controller.                                                                                                                                                       |
| `jenkins_agent__controller_port`         | `"443"`                                                                                                 | The port number on which the Jenkins controller is listening.                                                                                                                                             |
| `jenkins_agent__controller_protocol`     | `"https"`                                                                                               | The protocol used to communicate with the Jenkins controller (`http` or `https`).                                                                                                                         |
| `jenkins_agent__tunnel`                  | `"{{ jenkins_agent__controller }}:9000"`                                                                | The tunnel address for connecting to the Jenkins controller.                                                                                                                                            |
| `jenkins_agent__username`                | `jenkins_agent`                                                                                         | The username used to authenticate with the Jenkins controller.                                                                                                                                          |
| `jenkins_agent__password_file`           | `"{{ jenkins_agent__path }}/password.jenkins-agent"`                                                    | The path to the file where the agent's password will be stored.                                                                                                                                         |
| `jenkins_agent__name`                    | `"{{ inventory_hostname }}"`                                                                            | The name of the Jenkins agent, typically set to the hostname of the machine.                                                                                                                            |
| `jenkins_agent__num_executors_min`       | `4`                                                                                                     | The minimum number of executors for the Jenkins agent.                                                                                                                                                  |
| `jenkins_agent__num_executors`           | `"{{ [ansible_facts['processor_cores'] | d(1) * 2, jenkins_agent__num_executors_min] | max }}"`          | The calculated number of executors based on the number of processor cores or a minimum value.                                                                                                           |
| `jenkins_agent__labels`                  | `"{{ (ansible_os_family | lower() == 'windows') | ternary(['windows'], ['linux']) | list }}"`           | A list of labels to assign to the Jenkins agent, used for job selection.                                                                                                                                |
| `jenkins_agent__label`                   | `"{{ jenkins_agent__labels | join(' ') }}"`                                                              | The concatenated string of labels assigned to the Jenkins agent.                                                                                                                                        |
| `jenkins_agent__log_file`                | `"{{ jenkins_agent__path }}/jenkins-agent.log"`                                                          | The path to the log file for the Jenkins agent.                                                                                                                                                         |
| `jenkins_agent__additional_args`         | `["failIfWorkDirIsMissing"]`                                                                            | Additional arguments passed to the Jenkins agent.                                                                                                                                                       |
| `jenkins_agent__systemd_service_dir`     | `/lib/systemd/system`                                                                                   | The directory where systemd service files are stored.                                                                                                                                                   |
| `jenkins_agent__download_url`            | `"{{ jenkins_agent__controller_url }}/jnlpJars/agent.jar"`                                              | The URL to download the Jenkins agent JAR file from the controller.                                                                                                                                     |
| `jenkins_agent__validate_certs`          | `true`                                                                                                  | Whether to validate SSL certificates when communicating with the Jenkins controller.                                                                                                                    |
| `jenkins_agent__path`                    | `/var/lib/jenkins-agent`                                                                                | The base path for the Jenkins agent files and directories.                                                                                                                                            |
| `jenkins_agent__config_path`             | `/etc/jenkins-agent`                                                                                    | The configuration path for the Jenkins agent.                                                                                                                                                           |
| `jenkins_agent__task_name`               | `Jenkins Agent`                                                                                         | The name of the task or service used to run the Jenkins agent on Windows.                                                                                                                               |
| `jenkins_agent__systemd_path`            | `/lib/systemd/system`                                                                                   | The path where systemd service files are stored (Linux).                                                                                                                                              |
| `jenkins_agent__service_name`            | `jenkins-agent`                                                                                         | The name of the Jenkins agent service.                                                                                                                                                                  |
| `jenkins_agent__service_force_update`    | `true`                                                                                                  | Whether to force update the Jenkins agent service definition file.                                                                                                                                      |
| `jenkins_agent__work_dir`                | `/home/jenkins/agent`                                                                                   | The working directory for the Jenkins agent.                                                                                                                                                            |
| `jenkins_agent__remoting_dir`            | `"{{ jenkins_agent__work_dir }}/remoting"`                                                               | The remoting directory used by the Jenkins agent.                                                                                                                                                       |
| `jenkins_agent__jenkins_user_groups`     | `["docker"]`                                                                                            | A list of additional groups to which the Jenkins user should be added.                                                                                                                                |
| `jenkins_agent__jre_packages`            | `["default-jre"]`                                                                                       | The Java Runtime Environment (JRE) packages to install on Linux systems.                                                                                                                              |
| `jenkins_agent__java_home`               | `/etc/alternatives/java`                                                                                | The path to the Java home directory.                                                                                                                                                                    |
| `jenkins_agent__wrapper_version`         | `2.0.3`                                                                                                 | The version of the Jenkins Service Wrapper to use on Windows systems.                                                                                                                                   |
| `jenkins_agent__wrapper_download_url`    | `"{{ jenkins_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_agent__wrapper_version }}/winsw-{{jenkins_agent__wrapper_version}}-bin.exe"` | The URL to download the Jenkins Service Wrapper for Windows.                                                                                                                                            |
| `jenkins_agent__win_java_version`        | `8.0.144`                                                                                               | The version of Java to install on Windows systems using Chocolatey.                                                                                                                                     |
| `jenkins_agent__win_base_jenkins_path`   | `C:\jenkins-agent`                                                                                      | The base path for Jenkins agent files and directories on Windows systems.                                                                                                                               |
| `jenkins_agent__win_jenkins_agent_jar_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar }}"`                             | The path to the Jenkins agent JAR file on Windows systems.                                                                                                                                            |
| `jenkins_agent__win_jenkins_agent_wrapper_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.exe') }}"` | The path to the Jenkins Service Wrapper executable on Windows systems.                                                                                                                                |
| `jenkins_agent__win_jenkins_agent_wrapper_config_path` | `"{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.xml') }}"` | The path to the Jenkins Service Wrapper configuration file on Windows systems.                                                                                                                        |
| `jenkins_agent__register_with_controller` | `true`                                                                                                  | Whether to automatically register the agent with the Jenkins controller during setup.                                                                                                                   |

## Usage

To use the `bootstrap_jenkins_agent` role, include it in your Ansible playbook and provide the necessary variables as per your environment configuration. Here is an example of how to include this role in a playbook:

```yaml
- name: Setup Jenkins Agents
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

- `chocolatey.chocolatey` (for Windows systems)

Ensure that the required dependencies are installed in your Ansible environment before running this role.

## Tags

This role uses the following tags:

- `jenkins_agent`: Applies all tasks related to setting up and configuring Jenkins agents.
- `register_agent`: Specifically handles the registration of the agent with the Jenkins controller.

You can use these tags to target specific parts of the role during playbook execution. For example, to only run the registration tasks, you can use:

```bash
ansible-playbook -i inventory setup_jenkins_agents.yml --tags register_agent
```

## Best Practices

- **Security**: Ensure that SSL certificates are validated when communicating with the Jenkins controller by setting `jenkins_agent__validate_certs` to `true`.
- **Resource Management**: Adjust the number of executors based on the available resources and workload requirements.
- **User Groups**: Add necessary user groups to the Jenkins user to grant appropriate permissions, such as access to Docker.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to create test scenarios using Molecule to ensure that the role functions correctly across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_jenkins_agent/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_agent/tasks/main.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_agent/handlers/main.yml)