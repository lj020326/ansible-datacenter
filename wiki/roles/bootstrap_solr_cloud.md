---
title: Bootstrap Solr Cloud Role Documentation
role: bootstrap_solr_cloud
category: Ansible Roles
type: Configuration Management
tags: solr, solrcloud, ansible, automation
---

## Summary

The `bootstrap_solr_cloud` role is designed to automate the installation, configuration, and management of Apache SolrCloud on a target system. This role handles the setup of required dependencies, user accounts, directories, service management, and collection configurations for SolrCloud.

## Variables

| Variable Name                           | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_solr_cloud__solr_version`                 | `8.1.1`                                                                                             | The version of Solr to be installed.                                                                                                                                                                        |
| `role_bootstrap_solr_cloud__solrcloud_install`            | `true`                                                                                                | Whether to install SolrCloud.                                                                                                                                                                               |
| `role_bootstrap_solr_cloud__solr_user`                    | `solr`                                                                                                | The user under which Solr will run.                                                                                                                                                                         |
| `role_bootstrap_solr_cloud__solr_group`                   | `solr`                                                                                                | The group under which Solr will run.                                                                                                                                                                        |
| `role_bootstrap_solr_cloud__solr_service_enabled`         | `true`                                                                                                | Whether the Solr service should be enabled on boot.                                                                                                                                                         |
| `role_bootstrap_solr_cloud__solr_service_state`           | `started`                                                                                             | The desired state of the Solr service (`started`, `stopped`).                                                                                                                                             |
| `role_bootstrap_solr_cloud__solr_installation_dir`        | `/opt/solr`                                                                                           | The directory where Solr will be installed.                                                                                                                                                                 |
| `role_bootstrap_solr_cloud__solr_templates_dir`           | `templates`                                                                                           | Directory containing configuration templates for Solr.                                                                                                                                                    |
| `role_bootstrap_solr_cloud__solr_log_dir`                 | `/var/log/solr`                                                                                         | The directory where Solr logs will be stored.                                                                                                                                                               |
| `role_bootstrap_solr_cloud__solr_home`                    | `/var/solr`                                                                                           | The home directory for Solr data and configuration files.                                                                                                                                                   |
| `role_bootstrap_solr_cloud__solr_data_dir`                | `"{{ role_bootstrap_solr_cloud__solr_home }}/data"`                                                    | Directory where Solr data will be stored.                                                                                                                                                                   |
| `role_bootstrap_solr_cloud__solr_collections_config_tmp_dir` | `/tmp/collections`                                                                                      | Temporary directory for collection configuration files.                                                                                                                                                     |
| `role_bootstrap_solr_cloud__solr_log_root_level`          | `WARN`                                                                                                | The root logging level for Solr.                                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_log_file_size`           | `500MB`                                                                                               | Maximum size of the log file before it is rotated.                                                                                                                                                          |
| `role_bootstrap_solr_cloud__solr_log_max_backup_index`    | `9`                                                                                                   | The maximum number of backup log files to keep.                                                                                                                                                             |
| `role_bootstrap_solr_cloud__solr_log_config_file`         | `log4j2.xml`                                                                                          | Configuration file for logging settings.                                                                                                                                                                    |
| `role_bootstrap_solr_cloud__solr_log_file_name`           | `solr.log`                                                                                            | The name of the main log file.                                                                                                                                                                              |
| `role_bootstrap_solr_cloud__solr_log_slow_queries_file_name` | `solr_slow_requests.log`                                                                               | The name of the slow queries log file.                                                                                                                                                                      |
| `role_bootstrap_solr_cloud__solr_host`                    | `"{{ hostvars[ansible_nodename]['ansible_' + ansible_facts['default_ipv4']['alias']]['ipv4']['address'] }}"` | The hostname or IP address where Solr will be accessible.                                                                                                                                                |
| `role_bootstrap_solr_cloud__solr_port`                    | `8983`                                                                                                | The port on which Solr will listen for HTTP requests.                                                                                                                                                       |
| `role_bootstrap_solr_cloud__solr_url`                     | `http://{{ role_bootstrap_solr_cloud__solr_host }}:{{ role_bootstrap_solr_cloud__solr_port }}/solr`      | The full URL to access the SolrCloud instance.                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_jmx_enabled`             | `"true"`                                                                                              | Whether JMX is enabled for monitoring Solr.                                                                                                                                                                 |
| `role_bootstrap_solr_cloud__solr_jmx_port`                | `1099`                                                                                                | The port on which JMX will listen.                                                                                                                                                                          |
| `role_bootstrap_solr_cloud__solr_gc_tune`                 | `-XX:NewRatio=3 -XX:SurvivorRatio=4 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=8 -XX:+UseG1GC -XX:ConcGCThreads=4 -XX:ParallelGCThreads=4 -XX:+CMSScavengeBeforeRemark -XX:PretenureSizeThreshold=64m -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=50 -XX:CMSMaxAbortablePrecleanTime=6000 -XX:+CMSParallelRemarkEnabled -XX:+ParallelRefProcEnabled -XX:+UseTLAB` | Garbage collection tuning parameters for Solr.                                                                                                                                                              |
| `role_bootstrap_solr_cloud__solr_stack_size`              | `256k`                                                                                                | The stack size for Java threads.                                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_heap`                    | `512m`                                                                                                | The heap size allocated to Solr.                                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_jetty_threads_min`       | `10`                                                                                                  | Minimum number of threads in Jetty's thread pool.                                                                                                                                                           |
| `role_bootstrap_solr_cloud__solr_jetty_threads_max`       | `10000`                                                                                               | Maximum number of threads in Jetty's thread pool.                                                                                                                                                           |
| `role_bootstrap_solr_cloud__solr_jetty_threads_idle_timeout` | `5000`                                                                                                | Idle timeout for threads in Jetty's thread pool.                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_jetty_threads_stop_timeout` | `60000`                                                                                               | Timeout for stopping threads in Jetty's thread pool.                                                                                                                                                        |
| `role_bootstrap_solr_cloud__solr_jetty_secure_port`       | `8443`                                                                                                | The port on which Jetty will listen for secure HTTPS requests.                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_jetty_output_buffer_size` | `32768`                                                                                               | Size of the output buffer in Jetty.                                                                                                                                                                         |
| `role_bootstrap_solr_cloud__solr_jetty_output_aggregation_size` | `8192`                                                                                              | Aggregation size for output in Jetty.                                                                                                                                                                       |
| `role_bootstrap_solr_cloud__solr_jetty_request_header_size` | `8192`                                                                                                | Size of the request header buffer in Jetty.                                                                                                                                                                 |
| `role_bootstrap_solr_cloud__solr_jetty_response_header_size` | `8192`                                                                                              | Size of the response header buffer in Jetty.                                                                                                                                                                |
| `role_bootstrap_solr_cloud__solr_jetty_send_server_version` | `"false"`                                                                                             | Whether to send the server version in HTTP responses.                                                                                                                                                     |
| `role_bootstrap_solr_cloud__solr_jetty_send_date_header`  | `"false"`                                                                                             | Whether to send the date header in HTTP responses.                                                                                                                                                        |
| `role_bootstrap_solr_cloud__solr_jetty_header_cache_size`   | `512`                                                                                                 | Size of the header cache in Jetty.                                                                                                                                                                          |
| `role_bootstrap_solr_cloud__solr_jetty_delay_dispatch_until_content` | `"false"`                                                                                           | Whether to delay dispatch until content is available.                                                                                                                                                       |
| `role_bootstrap_solr_cloud__solr_jetty_http_selectors`    | `-1`                                                                                                  | Number of HTTP selectors in Jetty. `-1` means auto-detect based on the number of processors.                                                                                                              |
| `role_bootstrap_solr_cloud__solr_jetty_http_acceptors`    | `-1`                                                                                                  | Number of HTTP acceptors in Jetty. `-1` means auto-detect based on the number of processors.                                                                                                              |
| `role_bootstrap_solr_cloud__solr_zookeeper_hosts`         | `localhost:2181`                                                                                      | ZooKeeper hosts for SolrCloud.                                                                                                                                                                            |
| `role_bootstrap_solr_cloud__solr_zookeeper_hosts_solr_path` | `solr`                                                                                                | Path in ZooKeeper where Solr will store its data.                                                                                                                                                           |
| `role_bootstrap_solr_cloud__solr_zk_host`                 | `"{{ role_bootstrap_solr_cloud__solr_zookeeper_hosts }}/{{ role_bootstrap_solr_cloud__solr_zookeeper_hosts_solr_path }}"` | Full ZooKeeper host path for SolrCloud.                                                                                                                                                                   |
| `role_bootstrap_solr_cloud__solr_zookeeper_client_path`   | `"{{ role_bootstrap_solr_cloud__solr_installation_dir }}/server/scripts/cloud-scripts"`              | Path to the ZooKeeper client scripts.                                                                                                                                                                       |
| `role_bootstrap_solr_cloud__solr_zookeeper_client_timeout`  | `15000`                                                                                               | Timeout for ZooKeeper client operations.                                                                                                                                                                    |
| `role_bootstrap_solr_cloud__solr_collections`             | `{}`                                                                                                  | Dictionary of collections to be managed in SolrCloud. Each key is a collection name, and the value is a dictionary with configuration options.                                                             |
| `role_bootstrap_solr_cloud__solr_collections_template_path` | `"{{ playbook_dir }}/templates/collections/"`                                                         | Directory containing templates for collection configurations.                                                                                                                                                 |
| `role_bootstrap_solr_cloud__solr_collections_transfer_mode` | `synchronize`                                                                                         | Method to transfer collection configuration files (`synchronize`, `copy`).                                                                                                                                  |
| `role_bootstrap_solr_cloud__solr_external_libraries_repository_url` | `http://repo1.maven.org/maven2`                                                                   | URL of the Maven repository for external libraries.                                                                                                                                                       |
| `role_bootstrap_solr_cloud__solr_external_libraries`      | `{}`                                                                                                  | Dictionary of external libraries to be installed, with keys as library identifiers and values as configuration options.                                                                                 |

## Usage

To use this role in your Ansible playbook, include it in the roles section:

```yaml
- hosts: solr_servers
  become: yes
  roles:
    - bootstrap_solr_cloud
```

### Example Playbook

Here is an example playbook that demonstrates how to configure SolrCloud with specific settings and collections:

```yaml
---
- name: Configure SolrCloud on target servers
  hosts: solr_servers
  become: yes
  vars:
    role_bootstrap_solr_cloud__solr_version: "8.1.1"
    role_bootstrap_solr_cloud__solr_collections:
      collection1:
        shards: 2
        replicas: 2
        shards_per_node: 1
  roles:
    - bootstrap_solr_cloud
```

## Dependencies

This role does not have any external dependencies other than the packages required for Solr installation and operation. Ensure that your target systems have access to the necessary package repositories.

## Best Practices

- **Backup Configurations:** Always back up existing configurations before applying changes.
- **Test Changes:** Use a staging environment to test changes before deploying them to production.
- **Monitor Logs:** Monitor Solr logs for any issues or warnings after installation and configuration.
- **Security Considerations:** Ensure that Solr is properly secured, especially if exposed over the network.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_solr_cloud/defaults/main.yml)
- [tasks/collections.yml](../../roles/bootstrap_solr_cloud/tasks/collections.yml)
- [tasks/config.yml](../../roles/bootstrap_solr_cloud/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_solr_cloud/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_solr_cloud/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_solr_cloud/tasks/service.yml)
- [handlers/main.yml](../../roles/bootstrap_solr_cloud/handlers/main.yml)