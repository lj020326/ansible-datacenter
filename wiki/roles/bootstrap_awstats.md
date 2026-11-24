---
title: "Bootstrap Awstats Role"
role: roles/bootstrap_awstats
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_awstats]
---

# Ansible Role - bootstrap_awstats

The `bootstrap_awstats` role is designed to install, configure, and manage AWStats for monitoring Apache web servers. It provides a comprehensive setup for AWStats, including package installation, configuration file management, Apache module enabling, and virtual host configuration. This role also handles the removal of AWStats if needed.

## Variables

| Variable Name                       | Default Value                                                                 | Description                                                                                     |
|-------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| `awstats_enabled`                   | `true`                                                                       | Enable or disable the AWStats module.                                                           |
| `awstats_pkg_state`                 | `present`                                                                      | State of the AWStats package (present or absent).                                               |
| `apache_directory`                  | `"apache2"`                                                                    | Directory name for Apache configuration.                                                        |
| `apache_conf_path`                  | `"/etc/{{ apache_directory }}"`                                                | Path to the Apache configuration directory.                                                     |
| `apache_log_path`                   | `"/var/log/{{ apache_directory }}"`                                            | Path to the Apache log directory.                                                               |
| `awstats_conf_path`                 | `"/etc/awstats"`                                                              | Path to the AWStats configuration directory.                                                    |
| `awstats_domain`                    | `"home.nabla.mobi"`                                                            | Domain name for AWStats configuration.                                                          |
| `awstats_conf_file`                 | `"awstats.{{ awstats_sitedomain }}.conf"`                                      | AWStats configuration file name.                                                               |
| `awstats_logfile`                   | `"zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"`                    | Command to extract log files for AWStats processing.                                           |
| `awstats_sitedomain`                | `{{ awstats_domain }}`                                                         | Site domain for AWStats configuration.                                                          |
| `apache_awstats_enabled`            | `true`                                                                       | Enable or disable AWStats in Apache.                                                            |
| `apache_create_vhosts`              | `true`                                                                       | Create Apache virtual hosts for AWStats.                                                        |
| `apache_vhosts_awstats`             | `[{"servername": "localhost", "serveradmin": "alban.andrieu@nabla.mobi", "documentroot": "/usr/lib/cgi-bin"}]` | List of virtual hosts for AWStats.                                                              |

## Usage

To use this role, include it in your playbook and configure the variables as needed:

```yaml
---
- hosts: webservers
  roles:
    - role: bootstrap_awstats
      vars:
        awstats_domain: "example.com"
        apache_vhosts_awstats:
          - servername: "example.com"
            serveradmin: "admin@example.com"
            documentroot: "/var/www/example.com"
```

## Dependencies

This role does not have any external dependencies. It assumes that Apache is already installed and configured on the target system.

## Best Practices

1. **Customization**: Customize the `awstats_domain` and `apache_vhosts_awstats` variables to match your specific requirements.
2. **Security**: Ensure that the AWStats configuration files are secured and not accessible from the web.
3. **Monitoring**: Regularly monitor the AWStats reports to gain insights into your web server's performance and usage.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awstats/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_awstats/tasks/main.yml)
- [tasks/remove.yml](../../roles/bootstrap_awstats/tasks/remove.yml)
- [tasks/setup.yml](../../roles/bootstrap_awstats/tasks/setup.yml)
- [handlers/main.yml](../../roles/bootstrap_awstats/handlers/main.yml)