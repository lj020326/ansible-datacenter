---
title: "Telegraf Bootstrap Role"
role: bootstrap_telegraf
category: Monitoring
type: Role
tags: [ansible, role, bootstrap_telegraf]
---

```yaml
---
title: Telegraf Bootstrap Role
role: bootstrap_telegraf
category: Monitoring
type: Role
summary: |
  The `bootstrap_telegraf` role installs and configures Telegraf, a plugin-driven server agent for collecting and reporting metrics. This role supports both Debian-based and RedHat-based systems, and allows for extensive customization of Telegraf's configuration through Ansible variables.

# Variables
## Table of Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `telegraf_install_version` | `"stable"` | The version of Telegraf to install (stable or a specific version). |
| `telegraf_runas_user` | `"telegraf"` | The user that Telegraf should run as. |
| `telegraf_runas_group` | `"telegraf"` | The group that Telegraf should run as. |
| `telegraf_configuration_template` | `"telegraf.conf.j2"` | The Jinja2 template to use for Telegraf configuration. |
| `telegraf_tags` | | A list of tags to add to Telegraf metrics. |
| `telegraf_aws_tags` | `"false"` | Whether to retrieve AWS EC2 tags for the instance. |
| `telegraf_aws_tags_prefix` | | Prefix to add to AWS EC2 tags. |
| `telegraf_agent_interval` | `"10s"` | The collection interval for Telegraf. |
| `telegraf_round_interval` | `"true"` | Whether to round collection intervals to a specified interval. |
| `telegraf_metric_batch_size` | `"1000"` | The maximum number of metrics to collect in a single batch. |
| `telegraf_metric_buffer_limit` | `"10000"` | The maximum number of metrics to buffer before flushing. |
| `telegraf_collection_jitter` | `"0s"` | The amount of jitter to add to the collection interval. |
| `telegraf_flush_interval` | `"10s"` | The interval at which to flush metrics. |
| `telegraf_flush_jitter` | `"0s"` | The amount of jitter to add to the flush interval. |
| `telegraf_debug` | `"false"` | Whether to run Telegraf in debug mode. |
| `telegraf_quiet` | `"false"` | Whether to run Telegraf in quiet mode. |
| `telegraf_hostname` | | The hostname to use for Telegraf metrics. |
| `telegraf_omit_hostname` | `"false"` | Whether to omit the hostname from metric tags. |
| `telegraf_install_url` | | URL to download Telegraf package from. |
| `telegraf_influxdb_urls` | `[http://localhost:8086]` | URLs of InfluxDB instances to send metrics to. |
| `telegraf_influxdb_database` | `"telegraf"` | The InfluxDB database to write metrics to. |
| `telegraf_influxdb_precision` | `"s"` | The precision for timestamps in InfluxDB. |
| `telegraf_influxdb_retention_policy` | `"autogen"` | The retention policy for InfluxDB. |
| `telegraf_influxdb_write_consistency` | `"any"` | The write consistency level for InfluxDB. |
| `telegraf_influxdb_ssl_ca` | | Path to the SSL CA certificate for InfluxDB. |
| `telegraf_influxdb_ssl_cert` | | Path to the SSL certificate for InfluxDB. |
| `telegraf_influxdb_ssl_key` | | Path to the SSL key for InfluxDB. |
| `telegraf_influxdb_insecure_skip_verify` | `"false"` | Whether to skip SSL verification for InfluxDB. |
| `telegraf_influxdb_timeout` | `"5s"` | The timeout for InfluxDB requests. |
| `telegraf_influxdb_username` | | The username for InfluxDB authentication. |
| `telegraf_influxdb_password` | | The password for InfluxDB authentication. |
| `telegraf_influxdb_user_agent` | | The user agent string for InfluxDB requests. |
| `telegraf_influxdb_udp_payload` | | The maximum UDP payload size for InfluxDB. |
| `telegraf_influxdb_v2` | `"false"` | Whether to use InfluxDB v2 API. |
| `telegraf_influxdb_token` | | The token for InfluxDB v2 authentication. |
| `telegraf_influxdb_organization` | | The organization for InfluxDB v2. |
| `telegraf_influxdb_bucket` | | The bucket for InfluxDB v2. |
| `telegraf_plugins_base` | `[{"name": "mem"}, {"name": "system"}, {"name": "cpu", "options": {"percpu": "true", "totalcpu": "true", "fielddrop": ["time_*"]}}, {"name": "disk", "options": {"mountpoints": ["/"]}}, {"name": "diskio", "options": {"skip_serial_number": "true"}}, {"name": "procstat", "options": {"exe": "influxd", "prefix": "influxdb"}}, {"name": "net", "options": {"interfaces": ["eth0"]}}]` | The base set of plugins to enable in Telegraf. |
| `telegraf_plugins` | `{{ telegraf_plugins_base }} + {{ telegraf_plugins_extra \| d([], true) }}` | The combined set of plugins to enable in Telegraf. |
| `telegraf_influxdata_base_url` | `"https://repos.influxdata.com"` | The base URL for InfluxData repositories. |

# Usage
To use this role, include it in your playbook and set the desired variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_telegraf
      vars:
        telegraf_install_version: "1.21.1"
        telegraf_influxdb_urls:
          - "http://my-influxdb-server:8086"
        telegraf_influxdb_database: "my_database"
```

# Dependencies
This role requires the `amazon.aws` collection for retrieving EC2 metadata and tags. You can install it using:

```bash
ansible-galaxy collection install amazon.aws
```

# Best Practices
- Always test the role in a staging environment before deploying to production.
- Regularly update the Telegraf version to benefit from the latest features and security patches.
- Customize the Telegraf configuration to match your monitoring requirements.
- Ensure that the Telegraf service is enabled and started after installation.

# Verification
To verify that Telegraf is installed and running correctly, you can check the status of the service:

```bash
sudo systemctl status telegraf
```

You can also check the Telegraf logs for any errors or warnings:

```bash
sudo journalctl -u telegraf
```

# Troubleshooting
If you encounter issues with the role, here are some common troubleshooting steps:

1. Check the Telegraf service status and logs as mentioned in the Verification section.
2. Ensure that all required dependencies are installed.
3. Verify that the Telegraf configuration is valid and that there are no syntax errors.
4. Check network connectivity to the InfluxDB instances.
5. If using AWS EC2 tags, ensure that the `amazon.aws` collection is installed and configured correctly.

# Known Issues and Limitations
- The role does not support Windows systems.
- The role assumes that the target system has access to the internet to download the Telegraf package from the InfluxData repository.

# Extending the Role
To extend the role for custom use cases, you can:

1. Create a new Jinja2 template for the Telegraf configuration and set the `telegraf_configuration_template` variable to the path of your template.
2. Add custom plugins to the `telegraf_plugins_extra` variable.
3. Override any other variables as needed to customize the Telegraf configuration.

# Backlinks
- [defaults/main.yml](../../roles/bootstrap_telegraf/defaults/main.yml)
- [tasks/configure.yml](../../roles/bootstrap_telegraf/tasks/configure.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_telegraf/tasks/install-debian.yml)
- [tasks/install-redhat.yml](../../roles/bootstrap_telegraf/tasks/install-redhat.yml)
- [tasks/install.yml](../../roles/bootstrap_telegraf/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_telegraf/tasks/main.yml)
- [tasks/start.yml](../../roles/bootstrap_telegraf/tasks/start.yml)
- [handlers/main.yml](../../roles/bootstrap_telegraf/handlers/main.yml)