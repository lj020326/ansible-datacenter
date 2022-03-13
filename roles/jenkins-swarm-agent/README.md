Jenkins Agent
=============

[![Build Status](https://travis-ci.org/wurbanski/ansible-jenkins-swarm-agent.svg?branch=master)](https://travis-ci.org/wurbanski/ansible-jenkins-swarm-agent)

This role sets up a Jenkins agent with the Swarm client on a Windows/Ubuntu/CentOS machine.

Requirements
------------

* Jenkins master with the [Swarm client](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin)
* Ansible 2.2 due to use of some new Windows modules

ref: https://github.com/wurbanski/ansible-jenkins-swarm-agent

Role Variables
--------------

| Variable Name                        | Default                                                                                                                                                 | Description                                                                                       |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| jenkins_agent_master_port            | 8080                                                                                                                                                    | Port that Jenkins main UI is listening on                                                         |
| jenkins_agent_master_protocol        | http                                                                                                                                                    | Protocol that Jenkins main UI is reachable by                                                     |
| jenkins_agent_username               | sa_swarm_agent                                                                                                                                          | User account to use while authenticating to                                                       |
| jenkins_agent_password               | {{ lookup('password', '../credentials/{{ inventory_hostname }}/jenkins-agent/agent-password.txt') }}                                                    | A password to authenticate against the Jenkins Master                                             |
| jenkins_agent_password_file          | {{ jenkins_swarm_path }}/password.swarm                                                                                                                 | A file to hold the password with which to authenticate against the Jenkins Master                 |
| jenkins_agent_name                   | {{ inventory_hostname }}                                                                                                                                | How this agent will show up in the UI                                                             |
| jenkins_agent_num_executors          | {{ ansible_processor_cores\*2 }}                                                                                                                        | Number of executors for running jobs                                                              |
| jenkins_agent_labels                 | {{ (ansible_os_family\|lower() == 'windows')\|ternary('windows', 'linux') }}                                                                            | A space separated list of labels, for restricting jobs                                            |
| jenkins_agent_labels_file            | {{ jenkins_swarm_path }}/labels.swarm                                                                                                                   | A file to hold the labels and add/remove dynamically (Swarm client 3.3 and above)                 |
| jenkins_agent_log_file               | {{ jenkins_swarm_path }}/swarm.log                                                                                                                      | Where the swarm agent will log to                                                                 |
| jenkins_agent_additional_args        | [deleteExistingClients, disableClientsUniqueId]                                                                                                         | Additional arguments to send to the Swarm client jar                                              |
| jenkins_swarm_client_version         | 3.6                                                                                                                                                     | Version of the Swarm client to download                                                           |
| jenkins_plugins_url                  | https://repo.jenkins-ci.org                                                                                                                             | Base URL to download the client                                                                   |
| jenkins_plugins_repo_path            | releases/org/jenkins-ci/plugins/swarm-client/{{ jenkins_swarm_client_version }}                                                                         | URL between the base URL and the jar file name                                                    |
| jenkins_swarm_client_jar             | swarm-client-{{ jenkins_swarm_client_version }}.jar                                                                                                     | The file name for the swarm client jar                                                            |
| jenkins_swarm_download_url           | {{ jenkins_plugins_url }}/{{ jenkins_plugins_repo_path }}/{{ jenkins_swarm_client_jar }}                                                                | Full URL to the Swarm client jar                                                                  |
| jenkins_swarm_path                   | /var/lib/jenkins                                                                                                                                        | Path to the swarm client jar file                                                                 |
| jenkins_swarm_config_path            | /etc/jenkins                                                                                                                                            | For CentOS while it is using the init.d setup, this is where the swarm-client settings are stored |
| jenkins_swarm_task_name              | Jenkins Swarm Client                                                                                                                                    | Description for systemd                                                                           |
| jenkins_swarm_systemd_path           | /lib/systemd/system                                                                                                                                     | Path to systemd folder                                                                            |
| jenkins_swarm_service_name           | swarm-client                                                                                                                                            | Name of the systemd service                                                                       |
| jenkins_swarm_client_wrapper_version | 2.0.3                                                                                                                                                   | Windows Service Wrapper version                                                                   |
| jenkins_swarm_wrapper_download_url   | {{ jenkins_plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_swarm_client_wrapper_version }}/winsw-{{jenkins_swarm_client_wrapper_version}}-bin.exe | Full URL to the Windows Service Wrapper exe                                                       |
| win_base_jenkins_path                | C:\\jenkins                                                                                                                                             | Base path for the Jenkins agent                                                                   |
| win_swarm_client_jar_path            | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_client_jar }}                                                                                             | Path to the Swarm client jar file                                                                 |
| win_swarm_client_wrapper_path        | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_client_jar\|replace('.jar', '.exe') }}                                                                    | Path to the service wrapper exe                                                                   |
| win_swarm_client_wrapper_config_path | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_client_jar\|replace('.jar', '.xml') }}                                                                    | Path to the service wrapper config file                                                           |

Prerequisite Steps before Running playbook
------------------------------------------

Create jenkins api token for agent to use as password:

    https://stackoverflow.com/questions/45466090/how-to-get-the-api-token-for-jenkins
    https://github.com/jenkinsci/swarm-plugin/blob/master/docs/security.adoc

        - Log in to Jenkins.
        - Click your name in upper-right corner.
        - Click Configure (left-side menu).
        - Use "Add new Token" button to generate a new one then name it.
        - You must copy the token when you generate it as you cannot view the token afterwards.
        - Revoke old tokens when no longer needed.

Example Playbook
----------------

```yaml
- hosts: jenkins_agents
  vars:
    jenkins_agent_master: "{{ hostvars.example_master.ansible_host }}",
    jenkins_agent_num_executors: 8,
    jenkins_agent_labels: "Windows dotnet swarm msbuild"

  roles:
    - jenkins-swarm-agent
```
