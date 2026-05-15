```markdown
---
title: Jenkins Agent Setup Role Documentation
original_path: roles/bootstrap_jenkins_agent/README.md
category: Ansible Roles
tags: jenkins, ansible, swarm-plugin, windows, ubuntu, centos
---

# Jenkins Agent Setup Role

This role sets up a Jenkins agent on Windows, Ubuntu, or CentOS machines using the Jenkins Swarm client plugin.

## Requirements

- **Jenkins Master**: Ensure your Jenkins master is configured with the [Swarm Client Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin).
- **Ansible Version**: Ansible 2.2 or later, due to the use of new Windows modules.

**Reference:** [GitHub Repository](https://github.com/wurbanski/ansible-jenkins-swarm-agent)

## Role Variables

| Variable Name                        | Default                                                                                                                                                | Description                                                                                       |
|--------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `jenkins_agent__controller`          | `jenkins.example.int`                                                                                                                                | Hostname or IP address of the Jenkins master.                                                     |
| `jenkins_agent__controller_port`     | `8080`                                                                                                                                                 | Port on which the Jenkins master is listening.                                                      |
| `jenkins_agent__controller_protocol` | `http`                                                                                                                                                 | Protocol used to access the Jenkins master (e.g., `http`, `https`).                               |
| `jenkins_agent__controller_url`      | `"{{ jenkins_agent__controller_protocol }}://{{ jenkins_agent__controller }}:{{ jenkins_agent__controller_port }}"` | Full URL of the Jenkins master.                                                                   |
| `jenkins_agent__username`            | `sa_jenkins_agent`                                                                                                                                     | Username for authenticating with the Jenkins master.                                              |
| `jenkins_agent__password`            | `"{{ lookup('password', '../credentials/{{ inventory_hostname }}/jenkins-agent/agent-password.txt') }}"`                                                | Password or API token for authentication.                                                         |
| `jenkins_agent__password_file`       | `"{{ jenkins_agent__path }}/password.swarm"`                                                                                                             | File path to store the password/token.                                                            |
| `jenkins_agent__name`                | `"{{ inventory_hostname }}"`                                                                                                                           | Name of the Jenkins agent as it will appear in the UI.                                            |
| `jenkins_agent__num_executors`       | `"{{ ansible_facts['processor_cores'] * 2 }}"`                                                                                                          | Number of executors for running jobs.                                                             |
| `jenkins_agent__labels`              | `"{{ (ansible_os_family | lower() == 'windows') | ternary('windows', 'linux') }}"`                                                                     | Space-separated list of labels to restrict job execution.                                         |
| `jenkins_agent__labels_file`         | `"{{ jenkins_agent__path }}/labels.swarm"`                                                                                                             | File path for dynamic label management (Swarm agent 3.3 and above).                               |
| `jenkins_agent__log_file`            | `"{{ jenkins_agent__path }}/jenkins-agent.log"`                                                                                                          | Log file path for the Swarm agent.                                                                |
| `jenkins_agent__additional_args`     | `[failIfWorkDirIsMissing]`                                                                                                                             | Additional arguments to pass to the Swarm agent JAR.                                              |
| `jenkins_agent__version`             | `3.6`                                                                                                                                                  | Version of the Swarm agent to download.                                                           |
| `jenkins_agent__plugins_url`         | `https://repo.jenkins-ci.org`                                                                                                                          | Base URL for downloading the Swarm agent.                                                         |
| `jenkins_agent__path`                | `/var/lib/jenkins-agent`                                                                                                                               | Path where the Swarm agent JAR will be stored.                                                    |
| `jenkins_agent__work_dir`            | `/var/tmp/jenkins-agent`                                                                                                                               | Working directory for the Swarm agent (`-fsroot`).                                                |
| `jenkins_agent__config_path`         | `/etc/jenkins-agent`                                                                                                                                   | Configuration path for CentOS (init.d setup).                                                     |
| `jenkins_agent__task_name`           | `Jenkins Agent`                                                                                                                                        | Description for systemd service.                                                                  |
| `jenkins_agent__systemd_path`        | `/lib/systemd/system`                                                                                                                                  | Path to the systemd folder.                                                                       |
| `jenkins_agent__service_name`        | `jenkins-agent`                                                                                                                                        | Name of the systemd service.                                                                      |
| `jenkins_agent__wrapper_version`     | `2.0.3`                                                                                                                                                  | Version of the Windows Service Wrapper.                                                           |
| `jenkins_agent__wrapper_download_url`| `"{{ jenkins_agent__plugins_url }}/releases/com/sun/winsw/winsw/{{ jenkins_agent__wrapper_version }}/winsw-{{ jenkins_agent__wrapper_version }}-bin.exe"` | Full URL to download the Windows Service Wrapper executable.                                      |
| `win_base_jenkins_path`              | `C:\\jenkins`                                                                                                                                          | Base path for Jenkins agent on Windows.                                                           |
| `win_jenkins_agent_jar_path`         | `"{{ win_base_jenkins_path }}\\{{ jenkins_agent__jar }}"`                                                                                                | Path to the Swarm agent JAR file on Windows.                                                      |
| `win_jenkins_agent_wrapper_path`     | `"{{ win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.exe') }}"`                                                                     | Path to the service wrapper executable on Windows.                                                |
| `win_jenkins_agent_wrapper_config_path` | `"{{ win_base_jenkins_path }}\\{{ jenkins_agent__jar | replace('.jar', '.xml') }}"`                                                                 | Path to the service wrapper configuration file on Windows.                                        |

## Prerequisite Steps before Running Playbook

### Create Jenkins API Token for Agent Authentication

To use an API token instead of a password, follow these steps:

1. **Log in to Jenkins**.
2. Click your name in the upper-right corner and select **Configure** from the left-side menu.
3. Use the **Add new Token** button to generate a new token and give it a meaningful name.
4. **Copy the token immediately**, as you cannot view it again later.
5. Revoke old tokens when they are no longer needed.

**References:**
- [How to Get Jenkins API Token](https://stackoverflow.com/questions/45466090/how-to-get-the-api-token-for-jenkins)
- [Swarm Plugin Security Documentation](https://github.com/jenkinsci/swarm-plugin/blob/master/docs/security.adoc)

## Example Playbook

### Basic Configuration

```yaml
- hosts: jenkins_agents
  vars:
    jenkins_agent__controller: "{{ hostvars.example_master.ansible_host }}"
    jenkins_agent__num_executors: 8
    jenkins_agent__labels: "Windows dotnet swarm msbuild"

  roles:
    - bootstrap_jenkins_agent
```

### Configuration with Context Path

If your Jenkins service is hosted with a context path prefix (e.g., `/jenkins`), specify the endpoint URL using `jenkins_agent__controller_url`.

```yaml
- hosts: jenkins_agents
  vars:
    jenkins_agent__controller: "{{ hostvars.example_master.ansible_host }}"
    jenkins_agent__num_executors: 8
    jenkins_agent__labels: "Windows dotnet swarm msbuild"
    jenkins_agent__controller_url: "https://{{ hostvars.example_master.ansible_host }}/jenkins"

  roles:
    - bootstrap_jenkins_agent
```

## Backlinks

- [Ansible Roles Documentation](/docs/ansible-roles)
- [Jenkins Integration Guide](/docs/jenkins-integration)

```

This improved Markdown document is structured clearly, uses proper headings, and includes a YAML frontmatter with relevant metadata. It also maintains all the original information while ensuring it renders well on GitHub.