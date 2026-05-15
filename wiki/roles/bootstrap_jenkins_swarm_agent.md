---
title: "Jenkins Swarm Agent Bootstrap Role"
role: bootstrap_jenkins_swarm_agent
category: Jenkins Integration
type: Ansible Role
tags: jenkins, swarm, agent, automation

## Summary
The `bootstrap_jenkins_swarm_agent` role is designed to automate the setup and configuration of a Jenkins Swarm Agent on various operating systems. This includes downloading the necessary software, configuring user accounts, setting up directories, and registering the agent with a specified Jenkins controller.

## Variables

| Variable Name                                      | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `jenkins_swarm_agent__controller`                  | `jenkins.example.int`                                                                                   | The hostname or IP address of the Jenkins controller.                                                                                                                                                         |
| `jenkins_swarm_agent__controller_port`             | `8080`                                                                                                  | The port on which the Jenkins controller is running.                                                                                                                                                          |
| `jenkins_swarm_agent__controller_protocol`         | `http`                                                                                                  | The protocol used to communicate with the Jenkins controller (e.g., http, https).                                                                                                                           |
| `jenkins_swarm_agent__controller_url`              | `"{{ jenkins_swarm_agent__controller_protocol }}://{{ jenkins_swarm_agent__controller }}:{{ jenkins_swarm_agent__controller_port }}"`  | The full URL of the Jenkins controller.                                                                                                                                                                     |
| `jenkins_swarm_agent__tunnel`                      | `"{{ jenkins_swarm_agent__controller }}:9000"`                                                            | The tunnel to use for connecting to the Jenkins controller.                                                                                                                                                 |
| `jenkins_swarm_agent__arch`                        | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                                        | The architecture of the system (automatically detected).                                                                                                                                                    |
| `jenkins_swarm_agent__username`                    | `sa_swarm_agent`                                                                                        | The username used to authenticate with the Jenkins controller.                                                                                                                                              |
| `jenkins_swarm_agent__password_file`               | `"{{ jenkins_swarm_agent__path }}/password.swarm"`                                                        | The file path where the password for the Jenkins agent is stored.                                                                                                                                           |
| `jenkins_swarm_agent__name`                        | `"{{ ansible_facts['hostname'] }}"`                                                                      | The name of the Jenkins Swarm Agent (defaults to the hostname).                                                                                                                                             |
| `jenkins_swarm_agent__num_executors`               | `"{{ ansible_facts['processor_cores'] | d(1)*2 }}"`                                                        | The number of executors for the agent.                                                                                                                                                                      |
| `jenkins_swarm_agent__labels`                      | `"{{ (ansible_os_family | lower() == 'windows') | ternary(['windows'], ['linux']) | list }}"`                                                                      | Labels to assign to the Jenkins Swarm Agent based on OS family.                                                                                                                                             |
| `jenkins_swarm_agent__label`                       | `"{{ jenkins_swarm_agent__labels | join(' ') }}"`                                                          | A single string of labels joined by spaces.                                                                                                                                                                 |
| `jenkins_swarm_agent__labels_file`                 | `"{{ jenkins_swarm_agent__path }}/labels.swarm"`                                                        | The file path where the labels for the Jenkins agent are stored.                                                                                                                                            |
| `jenkins_swarm_agent__log_file`                    | `"{{ jenkins_swarm_agent__path }}/swarm.log"`                                                           | The log file path for the Jenkins Swarm Agent.                                                                                                                                                              |
| `jenkins_swarm_agent__additional_args`             | `["-deleteExistingClients", "-disableClientsUniqueId"]`                                                 | Additional arguments to pass to the Jenkins Swarm Client.                                                                                                                                                   |
| `jenkins_swarm_agent__systemd_service_dir`         | `/lib/systemd/system`                                                                                     | The directory where systemd service files are stored.                                                                                                                                                       |
| `jenkins_swarm_agent__download_url`                | `"{{ jenkins_swarm_agent__controller_url }}/jnlpJars/agent.jar"`                                          | The URL to download the Jenkins Swarm Client JAR file.                                                                                                                                                    |
| `jenkins_swarm_agent__validate_certs`              | `false`                                                                                                 | Whether to validate SSL certificates when downloading files.                                                                                                                                              |
| `jenkins_swarm_agent__path`                        | `/var/lib/jenkins-swarm-agent`                                                                          | The base directory for the Jenkins Swarm Agent configuration and data.                                                                                                                                      |
| `jenkins_swarm_agent__config_path`                 | `/etc/jenkins-swarm-agent`                                                                              | The path where configuration files for the Jenkins Swarm Agent are stored.                                                                                                                                  |
| `jenkins_swarm_agent__task_name`                   | `Jenkins Swarm Client`                                                                                  | The name of the task or service used to run the Jenkins Swarm Agent.                                                                                                                                        |
| `jenkins_swarm_agent__systemd_path`                | `/lib/systemd/system`                                                                                     | The directory where systemd service files are stored.                                                                                                                                                       |
| `jenkins_swarm_agent__service_name`                | `swarm-agent`                                                                                           | The name of the systemd service for the Jenkins Swarm Agent.                                                                                                                                              |
| `jenkins_swarm_agent__service_force_update`        | `true`                                                                                                  | Whether to force update the systemd service file.                                                                                                                                                         |
| `jenkins_swarm_agent__remote_fs`                   | `/home/jenkins/agent`                                                                                     | The remote filesystem path where the Jenkins Swarm Agent will operate.                                                                                                                                      |
| `jenkins_swarm_agent__jenkins_user_groups`         | `['docker']`                                                                                            | Additional groups to which the Jenkins user should be added.                                                                                                                                              |
| `jenkins_swarm_agent__jre_packages`                | `['default-jre']`                                                                                       | The JRE packages to install on Debian-based systems.                                                                                                                                                      |
| `jenkins_swarm_agent__java_home`                   | `/etc/alternatives/java`                                                                                | The path to the Java home directory.                                                                                                                                                                      |
| `jenkins_swarm_agent__wrapper_version`             | `2.0.3`                                                                                                 | The version of the Jenkins Service Wrapper to use on Windows systems.                                                                                                                                       |
| `jenkins_swarm_agent__wrapper_download_url`        | `"{{ jenkins_swarm_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_swarm_agent__wrapper_version }}/winsw-{{jenkins_swarm_agent__wrapper_version}}-bin.exe"`  | The URL to download the Jenkins Service Wrapper for Windows.                                                                                                                                                |
| `jenkins_swarm_agent__win_java_version`            | `8.0.144`                                                                                               | The version of Java to install on Windows systems using Chocolatey.                                                                                                                                         |
| `jenkins_swarm_agent__win_base_jenkins_path`       | `"C:\\jenkins"`                                                                                         | The base directory for Jenkins-related files on Windows systems.                                                                                                                                            |
| `jenkins_swarm_agent__win_swarm_agent_jar_path`    | `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar }}"`                    | The path where the Jenkins Swarm Agent JAR file will be stored on Windows systems.                                                                                                                          |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_path`| `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar | replace('.jar', '.exe') }}"`  | The path where the Jenkins Service Wrapper executable will be stored on Windows systems.                                                                                                                    |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_config_path` | `"{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar | replace('.jar', '.xml') }}"`  | The path where the Jenkins Service Wrapper configuration file will be stored on Windows systems.                                                                                                            |
| `jenkins_swarm_agent__register_with_controller`    | `true`                                                                                                  | Whether to register the agent with the Jenkins controller during setup.                                                                                                                                     |

## Usage
To use this role, include it in your Ansible playbook and provide the necessary variables as needed. Here is an example of how to include the role in a playbook:

```yaml
- name: Bootstrap Jenkins Swarm Agent
  hosts: jenkins_agents
  become: yes
  roles:
    - role: bootstrap_jenkins_swarm_agent
      vars:
        jenkins_swarm_agent__controller: "jenkins.example.com"
        jenkins_swarm_agent__username: "admin"
        jenkins_swarm_agent__password: "{{ lookup('file', 'path/to/password.txt') }}"
```

## Dependencies
- `chocolatey.chocolatey` (for Windows systems)

Ensure that the required dependencies are installed in your Ansible environment. For Windows, you need to have Chocolatey installed.

## Best Practices
- **Security**: Ensure that sensitive information such as passwords is stored securely and not hardcoded in playbooks.
- **Testing**: Use Molecule or other testing frameworks to validate the role on different operating systems before deploying it in production.
- **Documentation**: Maintain clear documentation for any customizations or additional configurations required for your environment.

## Molecule Tests
This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test -s <scenario_name>
```

Replace `<scenario_name>` with the appropriate scenario defined in the `molecule` directory.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_jenkins_swarm_agent/defaults/main.yml)
- [tasks/debian.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/debian.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/main.yml)
- [tasks/redhat-7.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat-7.yml)
- [tasks/redhat.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_swarm_agent/handlers/main.yml)