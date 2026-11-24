---
title: "Bootstrap Solr Cloud Role"
role: roles/bootstrap_solr_cloud
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_solr_cloud]
---

# Bootstrap Solr Cloud Role

The `bootstrap_solr_cloud` role is designed to automate the installation, configuration, and management of Apache SolrCloud on a server. This role handles the setup of SolrCloud, including the installation of required packages, user and group creation, directory setup, and configuration of SolrCloud properties. It also manages SolrCloud collections, ensuring that the specified collections are created, modified, or deleted as needed.

## Table of Contents
- [Variables](#variables)
- [Dependencies](#dependencies)
- [Example Usage](#example-usage)

## Variables

| Variable Name                              | Default Value                                 | Description                                                                 |
|--------------------------------------------|-----------------------------------------------|-----------------------------------------------------------------------------|
| `solr_version`                             | `8.1.1`                                       | The version of Solr to install.                                             |
| `solrcloud_install`                        | `true`                                        | Whether to install SolrCloud.                                               |
| `solr_user`                                | `solr`                                        | The user under which Solr will run.                                         |
| `solr_group`                               | `solr`                                        | The group under which Solr will run.                                        |
| `solr_service_enabled`                     | `true`                                        | Whether the Solr service should be enabled.                                 |
| `solr_service_state`                       | `started`                                     | The desired state of the Solr service (started, stopped).                   |
| `solr_installation_dir`                    | `/opt/solr`                                   | The directory where Solr will be installed.                                 |
| `solr_templates_dir`                       | `templates`                                   | The directory containing Solr configuration templates.                      |
| `solr_log_dir`                             | `/var/log/solr`                               | The directory where Solr logs will be stored.                               |
| `solr_home`                                | `/var/solr`                                   | The home directory for Solr.                                                |
| `solr_data_dir`                            | `{{ solr_home }}/data`                        | The directory where Solr data will be stored.                               |
| `solr_collections_config_tmp_dir`          | `/tmp/collections`                            | Temporary directory for Solr collection configurations.                     |
| `solr_log_root_level`                      | `WARN`                                        | The root log level for Solr.                                                |
| `solr_log_file_size`                       | `500MB`                                       | The maximum size of Solr log files before rotation.                        |
| `solr_log_max_backup_index`                | `9`                                           | The maximum number of backup log files to keep.                            |
| `solr_log_config_file`                     | `log4j2.xml`                                  | The Solr logging configuration file.                                        |
| `solr_log_file_name`                       | `solr.log`                                    | The name of the Solr log file.                                              |
| `solr_log_slow_queries_file_name`          | `solr_slow_requests.log`                      | The name of the Solr slow queries log file.                                 |
| `solr_host`                                | `{{ hostvars[ansible_facts.nodename]['ansible_' + ansible_facts['default_ipv4']['alias']]['ipv4']['address'] }}` | The hostname or IP address of the Solr server. This uses Ansible facts to determine the appropriate IP address. |
| `solr_port`                                | `8983`                                        | The port on which Solr will listen.                                         |
| `solr_url`                                 | `http://{{ solr_host }}:{{ solr_port }}/solr` | The URL of the Solr server.                                                  |
| `solr_jmx_enabled`                         | `"true"`                                      | Whether JMX is enabled for Solr.                                            |
| `solr_jmx_port`                            | `1099`                                        | The port for JMX.                                                          |
| `solr_gc_tune`                             | `-XX:NewRatio=3 -XX:SurvivorRatio=4 -XX:MaxTenuringThreshold=6 -XX:+UseParallelGC -XX:+UseParallelOldGC -XX:+UseTLAB` | Garbage collection tuning parameters for Solr.                              |
| `solr_stack_size`                          | `256k`                                        | The stack size for Solr.                                                    |
| `solr_heap`                                | `512m`                                        | The heap size for Solr.                                                     |
| `solr_jetty_threads_min`                   | `10`                                          | The minimum number of Jetty threads.                                        |
| `solr_jetty_threads_max`                   | `10000`                                       | The maximum number of Jetty threads.                                        |

## Dependencies
This role does not have any dependencies.

## Example Usage
```yaml
- hosts: solr_servers
  roles:
    - role: bootstrap_solr_cloud
      vars:
        solr_version: "8.5.1"
        solr_heap: "1g"
```