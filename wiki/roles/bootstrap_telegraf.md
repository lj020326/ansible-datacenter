---
title: Bootstrap Telegraf Role Documentation
role: bootstrap_telegraf
category: Monitoring
type: Ansible Role
tags: telegraf, monitoring, influxdb

---

## Summary

The `bootstrap_telegraf` role is designed to automate the installation and configuration of Telegraf on Debian/Ubuntu and RedHat/CentOS systems. It supports customizing various aspects of Telegraf's behavior, including its plugins, InfluxDB output settings, and system-specific configurations such as AWS tags.

## Variables

| Variable Name                          | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_bootstrap_telegraf__install_version`      | `stable`                                                                                      | The version of Telegraf to install. Can be set to a specific version or `stable`.                                                                                                                         |
| `role_bootstrap_telegraf__runas_user`         | `telegraf`                                                                                    | The user under which the Telegraf service should run.                                                                                                                                                         |
| `role_bootstrap_telegraf__runas_group`        | `telegraf`                                                                                    | The group under which the Telegraf service should run.                                                                                                                                                        |
| `role_bootstrap_telegraf__configuration_template` | `telegraf.conf.j2`                                                                          | The Jinja2 template used to generate the Telegraf configuration file.                                                                                                                                       |
| `role_bootstrap_telegraf__tags`               | (empty)                                                                                       | Additional tags to be added to Telegraf metrics.                                                                                                                                                            |
| `role_bootstrap_telegraf__aws_tags`           | `false`                                                                                       | Whether to retrieve and apply AWS EC2 instance tags as Telegraf tags.                                                                                                                                     |
| `role_bootstrap_telegraf__aws_tags_prefix`    | (empty)                                                                                       | Prefix for AWS tags in the Telegraf configuration.                                                                                                                                                          |
| `role_bootstrap_telegraf__agent_interval`     | `10s`                                                                                         | The interval at which to collect metrics.                                                                                                                                                                   |
| `role_bootstrap_telegraf__round_interval`     | `"true"`                                                                                      | Whether to round collection times to the nearest interval.                                                                                                                                                |
| `role_bootstrap_telegraf__metric_batch_size`  | `"1000"`                                                                                      | Maximum number of metrics sent in a single batch.                                                                                                                                                         |
| `role_bootstrap_telegraf__metric_buffer_limit`| `"10000"`                                                                                     | Maximum number of unwritten metrics to buffer.                                                                                                                                                            |
| `role_bootstrap_telegraf__collection_jitter`  | `0s`                                                                                          | Jitter added to the collection interval.                                                                                                                                                                    |
| `role_bootstrap_telegraf__flush_interval`     | `10s`                                                                                         | The interval at which to flush metrics to outputs.                                                                                                                                                        |
| `role_bootstrap_telegraf__flush_jitter`       | `0s`                                                                                          | Jitter added to the flush interval.                                                                                                                                                                         |
| `role_bootstrap_telegraf__debug`              | `"false"`                                                                                     | Whether to enable debug logging.                                                                                                                                                                            |
| `role_bootstrap_telegraf__quiet`              | `"false"`                                                                                     | Whether to suppress all output except error messages.                                                                                                                                                       |
| `role_bootstrap_telegraf__hostname`           | (empty)                                                                                       | The hostname to use in metrics. If empty, the system's hostname will be used.                                                                                                                               |
| `role_bootstrap_telegraf__omit_hostname`      | `"false"`                                                                                     | Whether to omit the hostname from metrics.                                                                                                                                                                  |
| `role_bootstrap_telegraf__install_url`        | (empty)                                                                                       | URL for downloading a specific Telegraf package if not using the default repository.                                                                                                                        |
| `role_bootstrap_telegraf__influxdb_urls`      | `[http://localhost:8086]`                                                                     | List of InfluxDB URLs to which metrics should be sent.                                                                                                                                                      |
| `role_bootstrap_telegraf__influxdb_database`  | `telegraf`                                                                                    | The InfluxDB database where metrics will be stored.                                                                                                                                                         |
| `role_bootstrap_telegraf__influxdb_precision` | `s`                                                                                           | Precision of timestamps in the output (`ns`, `u`, `ms`, `s`).                                                                                                                                             |
| `role_bootstrap_telegraf__influxdb_retention_policy` | `autogen`                                                                                 | The InfluxDB retention policy to use.                                                                                                                                                                       |
| `role_bootstrap_telegraf__influxdb_write_consistency` | `any`                                                                                    | Write consistency level for InfluxDB (`any`, `one`, `quorum`, `all`).                                                                                                                                       |
| `role_bootstrap_telegraf__influxdb_ssl_ca`    | (empty)                                                                                       | Path to the CA certificate file for SSL connections.                                                                                                                                                        |
| `role_bootstrap_telegraf__influxdb_ssl_cert`  | (empty)                                                                                       | Path to the client certificate file for SSL connections.                                                                                                                                                  |
| `role_bootstrap_telegraf__influxdb_ssl_key`   | (empty)                                                                                       | Path to the client key file for SSL connections.                                                                                                                                                            |
| `role_bootstrap_telegraf__influxdb_insecure_skip_verify` | `false`                                                                               | Whether to skip SSL certificate verification.                                                                                                                                                               |
| `role_bootstrap_telegraf__influxdb_timeout`   | `5s`                                                                                          | Timeout for InfluxDB writes.                                                                                                                                                                                |
| `role_bootstrap_telegraf__influxdb_username`  | (empty)                                                                                       | Username for InfluxDB authentication.                                                                                                                                                                       |
| `role_bootstrap_telegraf__influxdb_password`  | (empty)                                                                                       | Password for InfluxDB authentication.                                                                                                                                                                       |
| `role_bootstrap_telegraf__influxdb_user_agent`| (empty)                                                                                       | User agent string to use in HTTP requests to InfluxDB.                                                                                                                                                    |
| `role_bootstrap_telegraf__influxdb_udp_payload`| (empty)                                                                                      | Maximum UDP payload size for InfluxDB writes.                                                                                                                                                               |
| `role_bootstrap_telegraf__influxdb_v2`        | `false`                                                                                       | Whether to use InfluxDB v2 API.                                                                                                                                                                             |
| `role_bootstrap_telegraf__influxdb_token`     | (empty)                                                                                       | Token for authentication with InfluxDB v2.                                                                                                                                                                  |
| `role_bootstrap_telegraf__influxdb_organization` | (empty)                                                                                    | Organization name for InfluxDB v2.                                                                                                                                                                          |
| `role_bootstrap_telegraf__influxdb_bucket`    | (empty)                                                                                       | Bucket name for InfluxDB v2.                                                                                                                                                                                |
| `role_bootstrap_telegraf__plugins_base`       | List of default plugins like mem, system, cpu, disk, diskio, procstat, net                   | Base set of Telegraf plugins to enable and configure.                                                                                                                                                     |
| `role_bootstrap_telegraf__plugins`            | `{{ role_bootstrap_telegraf__plugins_base }} + {{ role_bootstrap_telegraf__plugins_extra \| d([], true) }}` | Full list of Telegraf plugins to enable and configure, including any additional plugins specified in `role_bootstrap_telegraf__plugins_extra`. |
| `role_bootstrap_telegraf__influxdata_base_url`| `https://repos.influxdata.com`                                                                | Base URL for the InfluxData repository.                                                                                                                                                                     |

## Usage

To use this role, include it in your playbook and define any necessary variables as needed. Here is an example of how to include the role in a playbook:

```yaml
- hosts: all
  roles:
    - role: bootstrap_telegraf
      vars:
        role_bootstrap_telegraf__influxdb_urls:
          - http://your-influxdb-server:8086
        role_bootstrap_telegraf__influxdb_database: your-database-name
```

## Dependencies

- `amazon.aws.ec2_metadata_facts` and `amazon.aws.ec2_tag` modules from the `amazon.aws` collection (if using AWS tags).
- The InfluxData repository must be accessible for package installation.

Ensure that the required collections are installed:

```bash
ansible-galaxy collection install amazon.aws
```

## Best Practices

- Always specify a specific version of Telegraf to avoid unexpected changes in behavior.
- Use the `role_bootstrap_telegraf__plugins` variable to customize the set of plugins based on your monitoring needs.
- Securely manage sensitive information such as InfluxDB credentials using Ansible Vault.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_telegraf/defaults/main.yml)
- [tasks/configure.yml](../../roles/bootstrap_telegraf/tasks/configure.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_telegraf/tasks/install-debian.yml)
- [tasks/install-redhat.yml](../../roles/bootstrap_telegraf/tasks/install-redhat.yml)
- [tasks/install.yml](../../roles/bootstrap_telegraf/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_telegraf/tasks/main.yml)
- [tasks/start.yml](../../roles/bootstrap_telegraf/tasks/start.yml)
- [handlers/main.yml](../../roles/bootstrap_telegraf/handlers/main.yml)