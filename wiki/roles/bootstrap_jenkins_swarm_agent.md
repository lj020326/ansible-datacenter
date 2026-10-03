---
title: "Bootstrap Jenkins Swarm Agent Role"
role: roles/bootstrap_jenkins_swarm_agent
category: Roles
type: ansible-role
summary: "The `bootstrap_jenkins_swarm_agent` role automates the setup and configuration of Jenkins Swarm Agents on various operating systems."
tags: [ansible, role, bootstrap_jenkins_swarm_agent]
---

## Jenkins Swarm Agent Bootstrap Role

The `bootstrap_jenkins_swarm_agent` role is designed to automate the setup and configuration of Jenkins Swarm Agents on various operating systems. It handles the creation of necessary user accounts, installation of required packages, downloading and configuring the Swarm Client, and registering the agent with a Jenkins controller. This role supports both Linux and Windows environments, with specific configurations for Debian, RedHat, and Windows systems.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `jenkins_swarm_agent__controller` | `jenkins.example.int` | The hostname or IP address of the Jenkins controller. |
| `jenkins_swarm_agent__controller_port` | `8080` | The port on which the Jenkins controller is accessible. |
| `jenkins_swarm_agent__controller_protocol` | `http` | The protocol used to communicate with the Jenkins controller. |
| `jenkins_swarm_agent__controller_url` | `{{ jenkins_swarm_agent__controller_protocol }}://{{ jenkins_swarm_agent__controller }}:{{ jenkins_swarm_agent__controller_port }}` | The full URL of the Jenkins controller. |
| `jenkins_swarm_agent__tunnel` | `{{ jenkins_swarm_agent__controller }}:9000` | The tunnel address for the Jenkins agent. |
| `jenkins_swarm_agent__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | The architecture of the system. |
| `jenkins_swarm_agent__username` | `sa_swarm_agent` | The username for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__password_file` | `{{ jenkins_swarm_agent__path }}/password.swarm` | The path to the password file for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__name` | `{{ ansible_facts['hostname'] }}` | The name of the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__num_executors` | `{{ ansible_facts['processor_cores'] \| d(1)*2 }}` | The number of executors for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__labels` | `{{ (ansible_os_family \| lower() == 'windows') \| ternary(['windows'], ['linux']) \| list }}` | The labels assigned to the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__label` | `{{ jenkins_swarm_agent__labels \| join(' ' ) }}` | The concatenated labels for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__labels_file` | `{{ jenkins_swarm_agent__path }}/labels.swarm` | The path to the labels file for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__log_file` | `{{ jenkins_swarm_agent__path }}/swarm.log` | The path to the log file for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__additional_args` | `["-deleteExistingClients", "-disableClientsUniqueId"]` | Additional arguments for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__systemd_service_dir` | `/lib/systemd/system` | The directory for systemd service files. |
| `jenkins_swarm_agent__conf` | `None` | Configuration for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__download_url` | `{{ jenkins_swarm_agent__controller_url }}/jnlpJars/agent.jar` | The URL to download the Jenkins Swarm Client JAR file. |
| `jenkins_swarm_agent__validate_certs` | `false` | Whether to validate SSL certificates when downloading the Swarm Client. |
| `jenkins_swarm_agent__path` | `/var/lib/jenkins-swarm-agent` | The base directory for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__config_path` | `/etc/jenkins-swarm-agent` | The configuration directory for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__task_name` | `Jenkins Swarm Client` | The name of the task for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__systemd_path` | `/lib/systemd/system` | The directory for systemd service files. |
| `jenkins_swarm_agent__service_name` | `swarm-agent` | The name of the systemd service for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__service_force_update` | `true` | Whether to force an update of the systemd service file. |
| `jenkins_swarm_agent__remote_fs` | `/home/jenkins/agent` | The remote filesystem path for the Jenkins Swarm Agent. |
| `jenkins_swarm_agent__jenkins_user_groups` | `["docker"]` | The groups to which the Jenkins user should belong. |
| `jenkins_swarm_agent__jre_packages` | `["default-jre"]` | The JRE packages to install. |
| `jenkins_swarm_agent__java_home` | `/etc/alternatives/java` | The path to the Java installation. |
| `jenkins_swarm_agent__wrapper_version` | `2.0.3` | The version of the Windows Service Wrapper. |
| `jenkins_swarm_agent__wrapper_download_url` | `{{ jenkins_swarm_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_swarm_agent__wrapper_version }}/winsw-{{jenkins_swarm_agent__wrapper_version}}-bin.exe` | The URL to download the Windows Service Wrapper. |
| `jenkins_swarm_agent__win_java_version` | `8.0.144` | The version of Java to install on Windows. |
| `jenkins_swarm_agent__win_base_jenkins_path` | `C:\\jenkins` | The base directory for Jenkins on Windows. |
| `jenkins_swarm_agent__win_swarm_agent_jar_path` | `{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar }}` | The path to the Swarm Agent JAR file on Windows. |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_path` | `{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar \| replace('.jar', '.exe') }}` | The path to the Windows Service Wrapper executable. |
| `jenkins_swarm_agent__win_swarm_agent_wrapper_config_path` | `{{ jenkins_swarm_agent__win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar \| replace('.jar', '.xml') }}` | The path to the Windows Service Wrapper configuration file. |
| `jenkins_swarm_agent__register_with_controller` | `true` | Whether to register the agent with the Jenkins controller. |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: jenkins_agents
  roles:
    - role: bootstrap_jenkins_swarm_agent
      vars:
        jenkins_swarm_agent__controller: "jenkins.example.int"
        jenkins_swarm_agent__username: "admin"
        jenkins_swarm_agent__password: "password"  # Required
```

## Dependencies

This role does not have any external dependencies, but it assumes that the Jenkins controller is already set up and accessible. It requires the following Ansible modules:
- `ansible.builtin.user`
- `ansible.builtin.group`
- `ansible.builtin.package`
- `ansible.builtin.copy`
- `ansible.builtin.template`
- `ansible.builtin.service`
- `ansible.windows.win_user`
- `ansible.windows.win_group`
- `ansible.windows.win_package`
- `ansible.windows.win_service`

## Best Practices

1. **Security**: Ensure that the Jenkins controller is secured with proper authentication and authorization mechanisms. Use strong passwords and consider using API tokens instead of plaintext passwords.
2. **Resource Allocation**: Adjust the `jenkins_swarm_agent__num_executors` variable based on the available resources on the agent machine. Monitor the agent's performance and adjust this value as needed.
3. **Labels**: Use meaningful labels to categorize agents for better job scheduling. For example, you might label agents based on their operating system, available tools, or specific hardware capabilities.
4. **Monitoring**: Regularly monitor the Jenkins Swarm Agents to ensure they are running smoothly and are properly connected to the Jenkins controller. Set up alerts for agents that disconnect or fail to report in.
5. **Testing**: Before deploying the role in production, test it in a development environment to ensure it works as expected with your specific Jenkins setup.

## Testing

To test this role, you can use Molecule with Docker or Vagrant. The role includes a Molecule scenario that sets up a Jenkins controller and agent, then runs tests to verify the agent's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_jenkins_swarm_agent/defaults/main.yml)
- [tasks/debian.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/debian.yml)
- [tasks/main.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/main.yml)
- [tasks/redhat-7.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat-7.yml)
- [tasks/redhat.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/redhat.yml)
- [tasks/register_agent.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/register_agent.yml)
- [tasks/windows.yml](../../roles/bootstrap_jenkins_swarm_agent/tasks/windows.yml)
- [handlers/main.yml](../../roles/bootstrap_jenkins_swarm_agent/handlers/main.yml)