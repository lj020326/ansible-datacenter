---
title: "Jenkins Swarm Agent Bootstrap Role"
role: bootstrap_jenkins_swarm_agent
category: Jenkins
type: Ansible Role
tags: jenkins, swarm, agent, automation

## Summary
The `bootstrap_jenkins_swarm_agent` role is designed to automate the setup and configuration of a Jenkins Swarm agent on various operating systems. It handles user creation, directory setup, downloading the necessary Jenkins Swarm client JAR file, configuring labels, setting up service definitions, and optionally registering the agent with the Jenkins controller.

## Variables

| Variable Name                                | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_swarm_agent__controller`            | `jenkins.example.int`                                                                         | The hostname or IP address of the Jenkins controller.                                                                                                                                                         |
| `jenkins_swarm_agent__controller_port`       | `8080`                                                                                          | The port on which the Jenkins controller is running.                                                                                                                                                            |
| `jenkins_swarm_agent__controller_protocol`   | `http`                                                                                            | The protocol used to communicate with the Jenkins controller (e.g., http, https).                                                                                                                           |
| `jenkins_swarm_agent__controller_url`        | `"{{ jenkins_swarm_agent__controller_protocol }}://{{ jenkins_swarm_agent__controller }}:{{ jenkins_swarm_agent__controller_port }}"` | The full URL to the Jenkins controller.                                                                                                                                                                       |
| `jenkins_swarm_agent__tunnel`                | `"{{ jenkins_swarm_agent__controller }}:9000"`                                                   | The tunnel address for connecting to the Jenkins controller.                                                                                                                                                |
| `jenkins_swarm_agent__arch`                  | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                             | The architecture of the system (automatically detected).                                                                                                                                                      |
| `jenkins_swarm_agent__username`              | `sa_swarm_agent`                                                                                | The username used to authenticate with the Jenkins controller.                                                                                                                                                |
| `jenkins_swarm_agent__password_file`         | `"{{ jenkins_swarm_agent__path }}/password.swarm"`                                              | The path to the file containing the password for the Jenkins user.                                                                                                                                          |
| `jenkins_swarm_agent__name`                  | `"{{ ansible_facts['hostname'] }}"`                                                              | The name of the Jenkins Swarm agent (defaults to the hostname).                                                                                                                                             |
| `jenkins_swarm_agent__num_executors`         | `"{{ ansible_facts['processor_cores'] | d(1)*2 }}"`                                             | The number of executors for the agent.                                                                                                                                                                        |
| `jenkins_swarm_agent__labels`                | `"{{ (ansible_os_family | lower() == 'windows') | ternary(['windows'], ['linux']) | list }}"`         | The labels assigned to the Jenkins Swarm agent.                                                                                                                                                               |
| `jenkins_swarm_agent__label`                 | `"{{ jenkins_swarm_agent__labels | join(' ') }}"`                                                 | A space-separated string of labels for the agent.                                                                                                                                                             |
| `jenkins_swarm_agent__labels_file`           | `"{{ jenkins_swarm_agent__path }}/labels.swarm"`                                                | The path to the file containing the labels for the Jenkins Swarm agent.                                                                                                                                       |
| `jenkins_swarm_agent__log_file`              | `"{{ jenkins_swarm_agent__path }}/swarm.log"`                                                   | The path to the log file for the Jenkins Swarm agent.                                                                                                                                                         |
| `jenkins_swarm_agent__additional_args`       | `["-deleteExistingClients", "-disableClientsUniqueId"]`                                         | Additional arguments passed to the Jenkins Swarm client.                                                                                                                                                    |
| `jenkins_swarm_agent__systemd_service_dir`   | `/lib/systemd/system`                                                                           | The directory where systemd service files are stored.                                                                                                                                                         |
| `jenkins_swarm_agent__download_url`          | `"{{ jenkins_swarm_agent__controller_url }}/jnlpJars/agent.jar"`                                 | The URL to download the Jenkins Swarm client JAR file.                                                                                                                                                    |
| `jenkins_swarm_agent__validate_certs`        | `false`                                                                                         | Whether to validate SSL certificates when downloading files.                                                                                                                                                  |
| `jenkins_swarm_agent__path`                  | `/var/lib/jenkins-swarm-agent`                                                                  | The base directory for the Jenkins Swarm agent.                                                                                                                                                               |
| `jenkins_swarm_agent__config_path`           | `/etc/jenkins-swarm-agent`                                                                      | The configuration directory for the Jenkins Swarm agent.                                                                                                                                                    |
| `jenkins_swarm_agent__task_name`             | `Jenkins Swarm Client`                                                                          | The name of the task or service for the Jenkins Swarm client.                                                                                                                                               |
| `jenkins_swarm_agent__systemd_path`          | `/lib/systemd/system`                                                                           | The path to the systemd directory.                                                                                                                                                                            |
| `jenkins_swarm_agent__service_name`          | `swarm-agent`                                                                                   | The name of the systemd service for the Jenkins Swarm agent.                                                                                                                                                |
| `jenkins_swarm_agent__service_force_update`  | `true`                                                                                          | Whether to force update the systemd service file.                                                                                                                                                           |
| `jenkins_swarm_agent__remote_fs`             | `/home/jenkins/agent`                                                                           | The remote filesystem path for the Jenkins Swarm agent.                                                                                                                                                     |
| `jenkins_swarm_agent__jenkins_user_groups`   | `['docker']`                                                                                    | Additional groups to which the jenkins user should be added.                                                                                                                                                |
| `jenkins_swarm_agent__jre_packages`          | `['default-jre']`                                                                               | The Java Runtime Environment packages to install.                                                                                                                                                           |
| `jenkins_swarm_agent__java_home`             | `/etc/alternatives/java`                                                                        | The path to the Java Home directory.                                                                                                                                                                        |
| `jenkins_swarm_agent__wrapper_version`       | `2.0.3`                                                                                         | The version of the Jenkins Service Wrapper to use (Windows only).                                                                                                                                           |
| `jenkins_swarm_agent__wrapper_download_url`  | `"{{ jenkins_swarm_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_swarm_agent__wrapper_version }}/winsw-{{jenkins_swarm_agent__wrapper_version}}-bin.exe"` | The URL to download the Jenkins Service Wrapper (Windows only).                                                                                                                                             |
| `jenkins_swarm_agent__win_java_version`      | `8.0.144`                                                                                       | The version of Java to install on Windows systems.                                                                                                                                                          |
| `jenkins_swarm_agent__win_base_jenkins_path` | `"C:\\jenkins"`                                                                                 | The base directory for Jenkins on Windows systems.                                                                                                                                                            |
| `jenkins_swarm_agent__win_swarm_agent_jar_path` | `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar }}"`       | The path to the Jenkins Swarm agent JAR file on Windows systems.                                                                                                                                            |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_path` | `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar | replace('.jar', '.exe') }}"` | The path to the Jenkins Service Wrapper executable on Windows systems.                                                                                                                                        |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_config_path` | `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar | replace('.jar', '.xml') }}"` | The path to the Jenkins Service Wrapper configuration file on Windows systems.                                                                                                                                |
| `jenkins_swarm_agent__register_with_controller` | `true`                                                                                        | Whether to register the agent with the Jenkins controller automatically.                                                                                                                                      |

## Usage
To use this role, include it in your playbook and specify any necessary variables as needed. Here is an example:

```yaml
- hosts: jenkins_agents
  roles:
    - role: bootstrap_jenkins_swarm_agent
      vars:
        jenkins_swarm_agent__controller: "jenkins.example.com"
        jenkins_swarm_agent__username: "admin"
        jenkins_swarm_agent__password: "{{ lookup('file', 'path/to/password') }}"
```

## Dependencies
- `chocolatey.chocolatey` (for Windows tasks)

## Best Practices
- Ensure that the Jenkins controller is accessible from the agent nodes.
- Use secure methods to handle credentials, such as Ansible Vault or encrypted files.
- Regularly update the role and its dependencies to ensure compatibility with the latest versions of Jenkins and related software.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_jenkins_swarm_agent/defaults/main.yml)
- [tasks/debian.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/debian.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/main.yml)
- [tasks/redhat-7.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat-7.yml)
- [tasks/redhat.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_swarm_agent/handlers/main.yml)