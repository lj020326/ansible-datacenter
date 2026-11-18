---
title: "Bootstrap Jenkins Agent Role"
role: bootstrap_jenkins_agent
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_jenkins_agent]
---

# Bootstrap Jenkins Agent Role

The `bootstrap_jenkins_agent` role is designed to automate the setup and configuration of Jenkins agents on both Linux and Windows systems. It ensures that Jenkins agents are properly registered with a Jenkins controller, have the necessary directories and permissions set up, and are running as a system service. This role supports both secure and insecure connections to the Jenkins controller and handles the registration process, including obtaining and storing the agent's secret password.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `jenkins_agent__controller` | `jenkins.example.int` | The hostname or IP address of the Jenkins controller. |
| `jenkins_agent__controller_port` | `"443"` | The port on which the Jenkins controller is listening. |
| `jenkins_agent__controller_protocol` | `"https"` | The protocol used to connect to the Jenkins controller. |
| `jenkins_agent__controller_url` | `{{ jenkins_agent__controller_protocol }}://{{ jenkins_agent__controller }}:{{ jenkins_agent__controller_port }}` | The full URL of the Jenkins controller. |
| `jenkins_agent__tunnel` | `{{ jenkins_agent__controller }}:9000` | The tunnel address for the Jenkins agent. |
| `jenkins_agent__username` | `jenkins_agent` | The username used to authenticate with the Jenkins controller. |
| `jenkins_agent__password_file` | `{{ jenkins_agent__path }}/password.jenkins-agent` | The path to the file containing the Jenkins agent password. |
| `jenkins_agent__name` | `{{ inventory_hostname }}` | The name of the Jenkins agent. |
| `jenkins_agent__num_executors_min` | `4` | The minimum number of executors for the Jenkins agent. |
| `jenkins_agent__num_executors` | `{{ [ansible_facts['processor_cores'] | d(1) * 2, jenkins_agent__num_executors_min] | max }}` | The number of executors for the Jenkins agent, calculated based on the number of processor cores. |
| `jenkins_agent__labels` | `{{ (ansible_os_family | lower() == 'windows') | ternary(['windows'], ['linux']) | list }}` | The labels assigned to the Jenkins agent. |
| `jenkins_agent__label` | `{{ jenkins_agent__labels | join(' ') }}` | The labels assigned to the Jenkins agent, joined into a single string. |
| `jenkins_agent__log_file` | `{{ jenkins_agent__path }}/jenkins-agent.log` | The path to the Jenkins agent log file. |
| `jenkins_agent__additional_args` | `['failIfWorkDirIsMissing']` | Additional arguments passed to the Jenkins agent. |
| `jenkins_agent__systemd_service_dir` | `/lib/systemd/system` | The directory where the systemd service file for the Jenkins agent is stored. |
| `jenkins_agent__conf` | `None` | Additional configuration for the Jenkins agent. |
| `jenkins_agent__download_url` | `{{ jenkins_agent__controller_url }}/jnlpJars/agent.jar` | The URL from which to download the Jenkins agent JAR file. |
| `jenkins_agent__validate_certs` | `true` | Whether to validate SSL certificates when connecting to the Jenkins controller. |
| `jenkins_agent__path` | `/var/lib/jenkins-agent` | The base directory for the Jenkins agent. |
| `jenkins_agent__config_path` | `/etc/jenkins-agent` | The directory where the Jenkins agent configuration files are stored. |
| `jenkins_agent__task_name` | `Jenkins Agent` | The name of the Jenkins agent task. |
| `jenkins_agent__service_name` | `jenkins-agent` | The name of the Jenkins agent service. |
| `jenkins_agent__service_force_update` | `true` | Whether to force an update of the Jenkins agent service file. |
| `jenkins_agent__work_dir` | `/home/jenkins/agent` | The working directory for the Jenkins agent. |
| `jenkins_agent__remoting_dir` | `{{ jenkins_agent__work_dir }}/remoting` | The directory where the Jenkins agent remoting files are stored. |
| `jenkins_agent__jenkins_user_groups` | `['docker']` | The groups to which the Jenkins user belongs. |
| `jenkins_agent__jre_packages` | `['default-jre']` | The JRE packages to install on the Jenkins agent. |
| `jenkins_agent__java_home` | `/etc/alternatives/java` | The path to the Java installation. |
| `jenkins_agent__wrapper_version` | `2.0.3` | The version of the Windows service wrapper to use. |
| `jenkins_agent__wrapper_download_url` | `{{ jenkins_agent__plugins_url }}/releases/com/sun/winsw/winsw/{{ jenkins_agent__wrapper_version }}/winsw-{{ jenkins_agent__wrapper_version }}-bin.exe` | The URL from which to download the Windows service wrapper. |
| `jenkins_agent__win_java_version` | `8.0.144` | The version of Java to install on Windows. |
| `jenkins_agent__win_base_jenkins_path` | `C:\jenkins-agent` | The base directory for the Jenkins agent on Windows. |
| `jenkins_agent__win_jenkins_agent_jar_path` | `{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar }}` | The path to the Jenkins agent JAR file on Windows. |
| `jenkins_agent__win_jenkins_agent_wrapper_path` | `{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.exe') }}` | The path to the Windows service wrapper executable. |
| `jenkins_agent__win_jenkins_agent_wrapper_config_path` | `{{ jenkins_agent__win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.xml') }}` | The path to the Windows service wrapper configuration file. |
| `jenkins_agent__register_with_controller` | `true` | Whether to register the Jenkins agent with the controller. |
| `jenkins_agent__plugins_url` | `https://repo1.maven.org/maven2` | The base URL for downloading plugins. |

## Usage

To use the `bootstrap_jenkins_agent` role, include it in your playbook and set the required variables. For example:

```yaml
- hosts: jenkins_agents
  roles:
    - role: bootstrap_jenkins_agent
      vars:
        jenkins_agent__controller: "jenkins.example.int"
        jenkins_agent__username: "admin"
        jenkins_agent__password: "password"
        jenkins_agent__register_with_controller: true
```

## Dependencies

This role does not have any external dependencies. However, it requires the `community.general` collection (version 3.0.0 or later) for XML parsing.

## Best Practices

- Ensure that the Jenkins controller is reachable and running before attempting to register the agent.
- Use secure connections (HTTPS) to the Jenkins controller whenever possible.
- Regularly update the Jenkins agent and controller to the latest versions.
- Monitor the Jenkins agent logs for any errors or warnings.
- Store sensitive information like passwords securely, using Ansible Vault if necessary.
- Test the role in a development environment before deploying to production.
- Ensure proper firewall and network configurations to allow communication between agents and the controller.

## Windows-Specific Configuration

For Windows agents, the role configures additional settings:

- Installs the specified version of Java
- Downloads and configures the Windows service wrapper
- Creates a Windows service for the Jenkins agent
- Sets appropriate permissions and environment variables

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_jenkins_agent/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_agent/tasks/main.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_agent/handlers/main.yml)