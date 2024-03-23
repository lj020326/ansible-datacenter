Jenkins Agent
=============

This role sets up a Jenkins agent with the Swarm client on a Windows/Ubuntu/CentOS machine.

Requirements
------------

* Jenkins master with the [Swarm client plugin](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin)
* Ansible 2.2 due to use of some new Windows modules

ref: https://github.com/wurbanski/ansible-jenkins-swarm-agent

Role Variables
--------------

| Variable Name                        | Default                                                                                                                                                 | Description                                                                                       |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| jenkins_swarm_agent__controller            | jenkins.example.int                                                                                                                                          | Host that Jenkins main/controller UI is hosted                                                    |
| jenkins_swarm_agent__controller_port            | 8080                                                                                                                                                    | Port that Jenkins main UI is listening on                                                         |
| jenkins_swarm_agent__controller_protocol        | http                                                                                                                                                    | Protocol that Jenkins main UI is reachable by                                                     |
| jenkins_swarm_agent__controller_url        | "{{ jenkins_swarm_agent__controller_protocol }}://{{ jenkins_swarm_agent__controller }}:{{ jenkins_swarm_agent__controller_port }}" | URL that Jenkins main UI is reachable by                                                     |
| jenkins_swarm_agent__username               | sa_swarm_agent                                                                                                                                          | User account to use while authenticating to                                                       |
| jenkins_swarm_agent__password               | {{ lookup('password', '../credentials/{{ inventory_hostname }}/jenkins-agent/agent-password.txt') }}                                                    | A password to authenticate against the Jenkins Master                                             |
| jenkins_swarm_agent__password_file          | {{ jenkins_swarm_agent__path }}/password.swarm                                                                                                                 | A file to hold the password with which to authenticate against the Jenkins Master                 |
| jenkins_swarm_agent__name                   | {{ inventory_hostname }}                                                                                                                                | How this agent will show up in the UI                                                             |
| jenkins_swarm_agent__num_executors          | {{ ansible_processor_cores\*2 }}                                                                                                                        | Number of executors for running jobs                                                              |
| jenkins_swarm_agent__labels                 | {{ (ansible_os_family\|lower() == 'windows')\|ternary('windows', 'linux') }}                                                                            | A space separated list of labels, for restricting jobs                                            |
| jenkins_swarm_agent__labels_file            | {{ jenkins_swarm_agent__path }}/labels.swarm                                                                                                                   | A file to hold the labels and add/remove dynamically (Swarm agent 3.3 and above)                 |
| jenkins_swarm_agent__log_file               | {{ jenkins_swarm_agent__path }}/swarm.log                                                                                                                      | Where the swarm agent will log to                                                                 |
| jenkins_swarm_agent__additional_args        | [deleteExistingClients, disableClientsUniqueId]                                                                                                         | Additional arguments to send to the Swarm agent jar                                              |
| jenkins_swarm_agent__version         | 3.6                                                                                                                                                     | Version of the Swarm agent to download                                                           |
| jenkins_swarm_agent__plugins_url                  | https://repo.jenkins-ci.org                                                                                                                             | Base URL to download the agent                                                                   |
| jenkins_swarm_agent__plugins_repo_path            | releases/org/jenkins-ci/plugins/swarm-client/{{ jenkins_swarm_agent__version }}                                                                         | URL between the base URL and the jar file name                                                    |
| jenkins_swarm_agent__jar             | swarm-client-{{ jenkins_swarm_agent__version }}.jar                                                                                                     | The file name for the swarm agent jar                                                            |
| jenkins_swarm_agent__download_url           | {{ jenkins_swarm_agent__plugins_url }}/{{ jenkins_swarm_agent__plugins_repo_path }}/{{ jenkins_swarm_agent__jar }}                                                                | Full URL to the Swarm agent jar                                                                  |
| jenkins_swarm_agent__path                   | /var/lib/jenkins-swarm-agent                                                                                                                                        | Path to the swarm agent jar file                                                                 |
| jenkins_swarm_agent__remote_fs                   | /var/tmp/jenkins-swarm-agent                                                                                                                                        | Path for the swarm agent `-fsroot` parameter                                                                 |
| jenkins_swarm_agent__config_path            | /etc/jenkins-swarm-agent                                                                                                                                            | For CentOS while it is using the init.d setup, this is where the swarm-client settings are stored |
| jenkins_swarm_agent__task_name              | Jenkins Swarm Client                                                                                                                                    | Description for systemd                                                                           |
| jenkins_swarm_agent__systemd_path           | /lib/systemd/system                                                                                                                                     | Path to systemd folder                                                                            |
| jenkins_swarm_agent__service_name           | swarm-agent                                                                                                                                            | Name of the systemd service                                                                       |
| jenkins_swarm_agent__wrapper_version | 2.0.3                                                                                                                                                   | Windows Service Wrapper version                                                                   |
| jenkins_swarm_agent__wrapper_download_url   | {{ jenkins_swarm_agent__plugins_url}}/releases/com/sun/winsw/winsw/{{ jenkins_swarm_agent__wrapper_version }}/winsw-{{jenkins_swarm_agent__wrapper_version}}-bin.exe | Full URL to the Windows Service Wrapper exe                                                       |
| win_base_jenkins_path                | C:\\jenkins                                                                                                                                             | Base path for the Jenkins agent                                                                   |
| win_swarm_agent_jar_path            | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar }}                                                                                             | Path to the Swarm agent jar file                                                                 |
| win_swarm_agent_wrapper_path        | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar\|replace('.jar', '.exe') }}                                                                    | Path to the service wrapper exe                                                                   |
| win_swarm_agent_wrapper_config_path | {{ win_base_jenkins_path }}\\{{ jenkins_swarm_agent__jar\|replace('.jar', '.xml') }}                                                                    | Path to the service wrapper config file                                                           |




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
    jenkins_swarm_agent__controller: "{{ hostvars.example_master.ansible_host }}",
    jenkins_swarm_agent__num_executors: 8,
    jenkins_swarm_agent__labels: "Windows dotnet swarm msbuild"

  roles:
    - jenkins-swarm-agent
```

If jenkins service is hosted with a context path prefix (e.g., `/jenkins`), use the `jenkins_swarm_agent__controller_url` variable to specify the endpoint URL:
```yaml
- hosts: jenkins_agents
  vars:
    jenkins_swarm_agent__controller: "{{ hostvars.example_master.ansible_host }}",
    jenkins_swarm_agent__num_executors: 8,
    jenkins_swarm_agent__labels: "Windows dotnet swarm msbuild"
    jenkins_swarm_agent__controller_url: "https://{{ hostvars.example_master.ansible_host }}/jenkins",

  roles:
    - jenkins-swarm-agent
```
