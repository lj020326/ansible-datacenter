---
title: Bootstrap AWStats Role Documentation
original_path: roles/bootstrap_awstats/README.md
category: Ansible Roles
tags: [ansible, awstats, apache]
---

# Bootstrap AWStats Role

This role ensures that mod_awstats is installed (using apt) on Apache.

## Role Variables

Below is a list of default variables available in the inventory:

```yaml
awstats_enabled: yes                       # Enable module

# Package states: present or installed or latest
awstats_pkg_state: present
# Repository states: present or absent
# awstats_repository_state: present

apache_directory: "apache2"
apache_conf_path: "/etc/{{ apache_directory }}"
apache_log_path: "/var/log/{{ apache_directory }}"
# apache_log_path: "${APACHE_LOG_DIR}"

awstats_conf_path: "/etc/awstats"
# awstats_conf_file: "awstats.conf.local"
awstats_domain: "home.nabla.mobi"
awstats_conf_file: "awstats.{{ awstats_sitedomain }}.conf"
# awstats_logfile: "{{ apache_log_path }}/other_vhosts_access.log"
# awstats_logfile: "zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"
awstats_logfile: "zip -cd {{ apache_log_path }}/other_vhosts_access.log.*.gz |"
awstats_sitedomain: "{{ awstats_domain }}"

apache_awstats_enabled: yes
apache_create_vhosts: yes

apache_vhosts_awstats:
  - servername: "localhost"
    serveradmin: "alban.andrieu@nabla.mobi"
    documentroot: "/usr/lib/cgi-bin"
```

## Detailed Usage Guide

Describe how to use this role in more detail...

## Testing

To test the role, follow these steps:

```shell
$ ansible-galaxy install bootstrap_awstats
$ vagrant up
```

## Backlinks

- [Ansible Roles](/ansible-roles)
- [AWStats Integration](/awstats-integration)

---

This documentation provides a clear and professional structure for the GitHub rendering of the Bootstrap AWStats role.