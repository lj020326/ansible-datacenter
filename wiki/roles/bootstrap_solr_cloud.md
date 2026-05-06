---
title: "Bootstrap Solr Cloud Role"
role: roles/bootstrap_solr_cloud
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_solr_cloud]
---

# SolrCloud Ansible Role Documentation

## Overview

The `bootstrap_solr_cloud` role is designed to automate the installation, configuration, and management of Apache Solr Cloud on a Linux system. This role handles tasks such as installing required libraries, setting up user accounts, configuring directories, managing Solr services, and handling collections within SolrCloud.

## Role Variables

### Default Variables

The following variables are defined in `defaults/main.yml`:

- **solr_version**: The version of Solr to install. (Default: `8.1.1`)
- **solrcloud_install**: Whether to install Solr Cloud. (Default: `true`)
- **solr_user**: The user under which Solr will run. (Default: `solr`)
- **solr_group**: The group under which Solr will run. (Default: `solr`)
- **solr_service_enabled**: Whether the Solr service should be enabled on boot. (Default: `true`)
- **solr_service_state**: The desired state of the Solr service (`started` or `stopped`). (Default: `started`)
- **solr_installation_dir**: The directory where Solr will be installed. (Default: `/opt/solr`)
- **solr_templates_dir**: Directory containing configuration templates. (Default: `templates`)
- **solr_log_dir**: Directory for Solr logs. (Default: `/var/log/solr`)
- **solr_home**: Home directory for Solr data and configurations. (Default: `/var/solr`)
- **solr_data_dir**: Directory for Solr data. (Default: `{{ solr_home }}/data`)
- **solr_collections_config_tmp_dir**: Temporary directory for collection configuration files. (Default: `/tmp/collections`)
- **solr_log_root_level**: Root log level for Solr. (Default: `WARN`)
- **solr_log_file_size**: Maximum size of a single log file. (Default: `500MB`)
- **solr_log_max_backup_index**: Number of backup log files to keep. (Default: `9`)
- **solr_log_config_file**: Log configuration file name. (Default: `log4j2.xml`)
- **solr_log_file_name**: Main Solr log file name. (Default: `solr.log`)
- **solr_log_slow_queries_file_name**: Slow queries log file name. (Default: `solr_slow_requests.log`)
- **solr_host**: The host address where Solr will be accessible. (Default: Dynamic based on default IPv4 address)
- **solr_port**: Port number for Solr HTTP service. (Default: `8983`)
- **solr_url**: Full URL to access the Solr instance. (Default: Dynamic based on `solr_host` and `solr_port`)
- **solr_jmx_enabled**: Whether JMX is enabled for Solr. (Default: `"true"`)
- **solr_jmx_port**: Port number for JMX service. (Default: `1099`)
- **solr_gc_tune**: Garbage collection tuning options. (Default: Various settings)
- **solr_stack_size**: Stack size for Java processes. (Default: `256k`)
- **solr_heap**: Heap size for Solr. (Default: `512m`)
- **solr_jetty_threads_min**: Minimum number of Jetty threads. (Default: `10`)
- **solr_jetty_threads_max**: Maximum number of Jetty threads. (Default: `10000`)
- **solr_jetty_threads_idle_timeout**: Idle timeout for Jetty threads. (Default: `5000`)
- **solr_jetty_threads_stop_timeout**: Stop timeout for Jetty threads. (Default: `60000`)
- **solr_jetty_secure_port**: Secure port number for Jetty. (Default: `8443`)
- **solr_jetty_output_buffer_size**: Output buffer size for Jetty. (Default: `32768`)
- **solr_jetty_output_aggregation_size**: Output aggregation size for Jetty. (Default: `8192`)
- **solr_jetty_request_header_size**: Request header size for Jetty. (Default: `8192`)
- **solr_jetty_response_header_size**: Response header size for Jetty. (Default: `8192`)
- **solr_jetty_send_server_version**: Whether to send server version in HTTP headers. (Default: `"false"`)
- **solr_jetty_send_date_header**: Whether to send date header in HTTP responses. (Default: `"false"`)
- **solr_jetty_header_cache_size**: Header cache size for Jetty. (Default: `512`)
- **solr_jetty_delay_dispatch_until_content**: Whether to delay dispatch until content is available. (Default: `"false"`)
- **solr_jetty_http_selectors**: Number of HTTP selectors for Jetty. (Default: `-1` - auto-detect)
- **solr_jetty_http_acceptors**: Number of HTTP acceptors for Jetty. (Default: `-1` - auto-detect)
- **solr_zookeeper_hosts**: ZooKeeper hosts for SolrCloud. (Default: `localhost:2181`)
- **solr_zookeeper_hosts_solr_path**: Path in ZooKeeper for Solr configurations. (Default: `solr`)
- **solr_zk_host**: Full ZooKeeper host path for Solr. (Default: Dynamic based on `solr_zookeeper_hosts` and `solr_zookeeper_hosts_solr_path`)
- **solr_zookeeper_client_path**: Path to the ZooKeeper client scripts. (Default: `{{ solr_installation_dir }}/server/scripts/cloud-scripts`)
- **solr_zookeeper_client_timeout**: Timeout for ZooKeeper client operations. (Default: `15000` milliseconds)
- **solr_collections**: Dictionary of collections to manage in SolrCloud. (Default: `{}`)
- **solr_collections_template_path**: Directory containing collection configuration templates. (Default: `{{ playbook_dir }}/templates/collections/`)
- **solr_collections_transfer_mode**: Method for transferring collection configuration files (`synchronize` or `copy`). (Default: `synchronize`)
- **solr_external_libraries_repository_url**: URL of the Maven repository for external libraries. (Default: `http://repo1.maven.org/maven2`)
- **solr_external_libraries**: Dictionary of external libraries to install. (Default: `{}`)

## Tasks

### Install (`tasks/install.yml`)

This task file handles the installation of Solr Cloud:

- Installs required system packages.
- Ensures the `solr` group and user are created.
- Creates necessary directories for Solr logs, data, and temporary collection configurations.
- Checks if Solr is already installed and running. If not, downloads and installs the specified version of Solr.

### Configure (`tasks/config.yml`)

This task file configures various aspects of Solr Cloud:

- Ensures the `zkcli.sh` script has execution permissions.
- Checks and creates the root path (znode) in ZooKeeper if it doesn't exist.
- Configures Jetty server settings using templates.
- Configures the SolrCloud init script and properties.
- Sets up logging configuration.
- Installs required packages for external libraries and copies them to the appropriate directory.
- Waits for Solr Cloud to fully start before continuing.

### Service (`tasks/service.yml`)

This task file manages the Solr service:

- Configures the Solr service using systemd, setting its state and enabling it on boot if specified.

### Collections (`tasks/collections.yml`)

This task file manages collections within SolrCloud:

- Checks if collection configurations exist.
- Copies or synchronizes collection configuration files to a temporary directory.
- Uploads initial configurations to ZooKeeper.
- Lists existing collections in SolrCloud.
- Creates new collections, modifies existing ones, and reloads them as necessary.
- Deletes collections that are no longer specified in the configuration.

### Main (`tasks/main.yml`)

This task file imports other tasks:

- **Install**: Runs installation tasks.
- **Configure**: Runs configuration tasks.
- **Service**: Manages the Solr service.
- **Manage Collections**: Manages collections within SolrCloud, but only if `solr_collections` is defined and not empty.

## Handlers

### Restart SolrCloud (`handlers/main.yml`)

This handler restarts the Solr service when changes are made that require a restart.

## Usage Example

Below is an example of how to use this role in an Ansible playbook:

```yaml
---
- name: Deploy Solr Cloud
  hosts: solr_servers
  become: yes
  vars:
    solr_collections:
      collection1:
        shards: 2
        replicas: 2
        shards_per_node: 1
      collection2:
        shards: 3
        replicas: 2
        shards_per_node: 1
  roles:
    - role: bootstrap_solr_cloud
```

In this example, the playbook deploys Solr Cloud on hosts specified in the `solr_servers` group and manages two collections (`collection1` and `collection2`) with specified shard and replica configurations.

## Notes

- Double-underscore variables are internal only.
- This role does not invent related roles; it handles all necessary tasks for setting up Solr Cloud.
- The documentation is formatted using standard GitHub Markdown.