---
title: "SolrCloud Bootstrap Role"
role: bootstrap_solr_cloud
category: Ansible Roles
type: Infrastructure as Code
tags: solrcloud, ansible, automation, deployment

---

## Summary

The `bootstrap_solr_cloud` role is designed to automate the installation, configuration, and management of Apache SolrCloud on a target system. This role handles the setup of necessary directories, user accounts, service configurations, Jetty server settings, logging, external libraries, and collection management within a SolrCloud environment.

## Variables

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `solr_version`                            | `8.1.1`                                                                                                 | The version of Solr to be installed.                                                                                                                                                                        |
| `solrcloud_install`                       | `true`                                                                                                  | Whether to install SolrCloud.                                                                                                                                                                               |
| `solr_user`                               | `solr`                                                                                                  | The user under which Solr will run.                                                                                                                                                                         |
| `solr_group`                              | `solr`                                                                                                  | The group under which Solr will run.                                                                                                                                                                        |
| `solr_service_enabled`                    | `true`                                                                                                  | Whether the Solr service should be enabled to start on boot.                                                                                                                                                |
| `solr_service_state`                      | `started`                                                                                               | The desired state of the Solr service (`started`, `stopped`).                                                                                                                                               |
| `solr_installation_dir`                   | `/opt/solr`                                                                                             | The directory where Solr will be installed.                                                                                                                                                                 |
| `solr_templates_dir`                      | `templates`                                                                                             | Directory containing template files for configuration.                                                                                                                                                      |
| `solr_log_dir`                            | `/var/log/solr`                                                                                         | Directory for Solr logs.                                                                                                                                                                                    |
| `solr_home`                               | `/var/solr`                                                                                             | Home directory for Solr data and configurations.                                                                                                                                                            |
| `solr_data_dir`                           | `"{{ solr_home }}/data"`                                                                                  | Directory for Solr data storage.                                                                                                                                                                            |
| `solr_collections_config_tmp_dir`         | `/tmp/collections`                                                                                        | Temporary directory for collection configuration files.                                                                                                                                                     |
| `solr_log_root_level`                     | `WARN`                                                                                                  | Root logging level for Solr.                                                                                                                                                                                |
| `solr_log_file_size`                      | `500MB`                                                                                                 | Maximum size of the log file before it rolls over.                                                                                                                                                          |
| `solr_log_max_backup_index`               | `9`                                                                                                     | Number of backup log files to keep.                                                                                                                                                                         |
| `solr_log_config_file`                    | `log4j2.xml`                                                                                            | Log configuration file name.                                                                                                                                                                                |
| `solr_log_file_name`                      | `solr.log`                                                                                              | Main log file name.                                                                                                                                                                                         |
| `solr_log_slow_queries_file_name`         | `solr_slow_requests.log`                                                                                | Slow query log file name.                                                                                                                                                                                   |
| `solr_host`                               | `"{{ hostvars[ansible_facts.nodename]['ansible_' + ansible_facts['default_ipv4']['alias']]['ipv4']['address'] }}"` | Host address for Solr. Defaults to the default IPv4 address of the node.                                                                                                                                    |
| `solr_port`                               | `8983`                                                                                                  | Port on which Solr will listen.                                                                                                                                                                             |
| `solr_url`                                | `http://{{ solr_host }}:{{ solr_port }}/solr`                                                            | URL for accessing SolrCloud.                                                                                                                                                                                |
| `solr_jmx_enabled`                        | `"true"`                                                                                                | Whether JMX is enabled for Solr.                                                                                                                                                                            |
| `solr_jmx_port`                           | `1099`                                                                                                  | Port for JMX communication.                                                                                                                                                                                 |
| `solr_gc_tune`                            | `-XX:NewRatio=3 \| -XX:SurvivorRatio=4 \| ...`                                                          | Garbage collection tuning options.                                                                                                                                                                          |
| `solr_stack_size`                         | `256k`                                                                                                  | Stack size for Solr JVM.                                                                                                                                                                                    |
| `solr_heap`                               | `512m`                                                                                                  | Heap size for Solr JVM.                                                                                                                                                                                     |
| `solr_jetty_threads_min`                  | `10`                                                                                                    | Minimum number of Jetty threads.                                                                                                                                                                            |
| `solr_jetty_threads_max`                  | `10000`                                                                                                 | Maximum number of Jetty threads.                                                                                                                                                                            |
| `solr_jetty_threads_idle_timeout`         | `5000`                                                                                                  | Idle timeout for Jetty threads in milliseconds.                                                                                                                                                             |
| `solr_jetty_threads_stop_timeout`         | `60000`                                                                                                 | Stop timeout for Jetty threads in milliseconds.                                                                                                                                                             |
| `solr_jetty_secure_port`                  | `8443`                                                                                                  | Secure port for Jetty.                                                                                                                                                                                      |
| `solr_jetty_output_buffer_size`           | `32768`                                                                                                 | Output buffer size for Jetty.                                                                                                                                                                               |
| `solr_jetty_output_aggregation_size`      | `8192`                                                                                                  | Output aggregation size for Jetty.                                                                                                                                                                          |
| `solr_jetty_request_header_size`          | `8192`                                                                                                  | Request header size for Jetty.                                                                                                                                                                              |
| `solr_jetty_response_header_size`         | `8192`                                                                                                  | Response header size for Jetty.                                                                                                                                                                             |
| `solr_jetty_send_server_version`          | `"false"`                                                                                               | Whether to send the server version in HTTP headers.                                                                                                                                                         |
| `solr_jetty_send_date_header`             | `"false"`                                                                                               | Whether to send the date header in HTTP responses.                                                                                                                                                          |
| `solr_jetty_header_cache_size`            | `512`                                                                                                   | Header cache size for Jetty.                                                                                                                                                                                |
| `solr_jetty_delay_dispatch_until_content` | `"false"`                                                                                               | Whether to delay dispatch until content is available.                                                                                                                                                       |
| `solr_jetty_http_selectors`               | `-1`                                                                                                    | Number of HTTP selectors for Jetty. `-1` means use the default value.                                                                                                                                       |
| `solr_jetty_http_acceptors`               | `-1`                                                                                                    | Number of HTTP acceptors for Jetty. `-1` means use the default value.                                                                                                                                       |
| `solr_zookeeper_hosts`                    | `localhost:2181`                                                                                        | ZooKeeper hosts used by SolrCloud.                                                                                                                                                                          |
| `solr_zookeeper_hosts_solr_path`          | `solr`                                                                                                  | Path in ZooKeeper for Solr configurations.                                                                                                                                                                |
| `solr_zk_host`                            | `"{{ solr_zookeeper_hosts }}/{{ solr_zookeeper_hosts_solr_path }}"`                                     | Full ZooKeeper host path for Solr.                                                                                                                                                                          |
| `solr_zookeeper_client_path`              | `"{{ solr_installation_dir }}/server/scripts/cloud-scripts"`                                            | Path to the ZooKeeper client scripts.                                                                                                                                                                       |
| `solr_zookeeper_client_timeout`           | `15000`                                                                                                 | Timeout for ZooKeeper client operations in milliseconds.                                                                                                                                                  |
| `solr_collections`                        | `{}`                                                                                                    | Dictionary defining Solr collections and their configurations.                                                                                                                                            |
| `solr_collections_template_path`          | `"{{ playbook_dir }}/templates/collections/"`                                                           | Path to templates for collection configurations.                                                                                                                                                            |
| `solr_collections_transfer_mode`          | `synchronize`                                                                                           | Method for transferring collection configuration files (`synchronize`, `copy`).                                                                                                                             |
| `solr_external_libraries_repository_url`  | `http://repo1.maven.org/maven2`                                                                         | URL of the Maven repository for external libraries.                                                                                                                                                         |
| `solr_external_libraries`                 | `{}`                                                                                                    | Dictionary defining external libraries to be installed. Each library should have `group_id`, `artifact_id`, and `version`.                                                                               |

## Usage

To use this role, include it in your playbook with the necessary variables defined. Here is an example:

```yaml
- hosts: solrcloud_servers
  roles:
    - role: bootstrap_solr_cloud
      vars:
        solr_version: 8.1.1
        solr_collections:
          mycollection:
            shards: 2
            replicas: 2
            shards_per_node: 1
```

## Dependencies

- `ansible.posix.synchronize` module for file synchronization.
- `community.general.maven_artifact` module for downloading external libraries.

Ensure these modules are available in your Ansible environment. You can install the `community.general` collection using:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Backup Configurations**: Always back up existing Solr configurations before applying new ones.
2. **Test Changes**: Use a staging environment to test changes before deploying them to production.
3. **Monitor Logs**: Regularly monitor Solr logs for any errors or warnings.
4. **Resource Allocation**: Adjust JVM heap size and other resource settings based on your system's capabilities and requirements.

## Molecule Tests

This role includes Molecule tests to ensure its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed and configured in your environment.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_solr_cloud/defaults/main.yml)
- [tasks/collections.yml](../../roles/bootstrap_solr_cloud/tasks/collections.yml)
- [tasks/config.yml](../../roles/bootstrap_solr_cloud/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_solr_cloud/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_solr_cloud/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_solr_cloud/tasks/service.yml)
- [handlers/main.yml](../../roles/bootstrap_solr_cloud/handlers/main.yml)