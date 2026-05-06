---
title: Bootstrap AWStats Role Documentation
role: bootstrap_awstats
category: Monitoring
type: Ansible Role
tags: awstats, apache, monitoring, setup, removal

## Summary
The `bootstrap_awstats` role is designed to automate the installation and configuration of AWStats for web server log analysis. It handles both the setup and removal of AWStats along with its Apache virtual host configurations. The role supports enabling or disabling AWStats based on user-defined variables.

## Variables

| Variable Name                      | Default Value                                      | Description                                                                 |
|------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `awstats_enabled`                  | `true`                                             | Enable or disable the AWStats module.                                       |
| `awstats_pkg_state`                | `present`                                          | Desired state of the AWStats package (present/absent).                      |
| `apache_directory`                 | `"apache2"`                                        | Directory name for Apache configuration files.                              |
| `apache_conf_path`                 | `"/etc/{{ apache_directory }}"`                    | Path to the Apache configuration directory.                                 |
| `apache_log_path`                  | `"/var/log/{{ apache_directory }}"`                | Path to the Apache log directory.                                           |
| `awstats_conf_path`                | `"/etc/awstats"`                                   | Path to the AWStats configuration files.                                    |
| `awstats_domain`                   | `"home.nabla.mobi"`                                | Domain name for which AWStats will be configured.                           |
| `awstats_conf_file`                | `"awstats.{{ awstats_sitedomain }}.conf"`          | Name of the AWStats configuration file.                                     |
| `awstats_logfile`                  | `"zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"` | Command to extract log files for AWStats processing.                      |
| `awstats_sitedomain`               | `"{{ awstats_domain }}"`                           | Site domain used in the AWStats configuration file name.                    |
| `apache_awstats_enabled`           | `true`                                             | Enable or disable Apache configurations related to AWStats.                 |
| `apache_create_vhosts`             | `true`                                             | Create virtual hosts for AWStats if enabled.                                |
| `apache_vhosts_awstats`            | List of dictionaries with servername, serveradmin, documentroot | Configuration details for the AWStats virtual host.                       |

## Usage
To use this role, include it in your playbook and optionally override any default variables as needed:

```yaml
- hosts: webservers
  roles:
    - role: bootstrap_awstats
      vars:
        awstats_enabled: true
        awstats_domain: "example.com"
```

## Dependencies
This role does not have external dependencies on other Ansible roles. However, it assumes that the target system has Apache installed and configured.

## Tags
- `awstats` - Applies to tasks related to AWStats installation and configuration.
- `apache` - Applies to tasks related to Apache configurations for AWStats.
- `setup` - Applies to setup tasks.
- `remove` - Applies to removal tasks.

## Best Practices
- Ensure that the target system has the necessary permissions to install packages and modify configuration files.
- Verify that the specified log paths exist and are accessible by the web server.
- Regularly review AWStats configurations for security and performance considerations.

## Molecule Tests
This role does not include Molecule tests at this time. Consider adding Molecule scenarios to ensure the role functions as expected in different environments.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_awstats/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_awstats/tasks/main.yml)
- [tasks/remove.yml](../../roles/bootstrap_awstats/tasks/remove.yml)
- [tasks/setup.yml](../../roles/bootstrap_awstats/tasks/setup.yml)
- [handlers/main.yml](../../roles/bootstrap_awstats/handlers/main.yml)