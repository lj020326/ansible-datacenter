---
title: "Bootstrap Zookeeper Role"
role: bootstrap_zookeeper
category: Database
type: Role
tags: [ansible, role, bootstrap_zookeeper]
---

# Bootstrap ZooKeeper Role

## Purpose

The `bootstrap_zookeeper` role is designed to automate the installation, configuration, and management of Apache ZooKeeper on a target system. It ensures that ZooKeeper is installed with the appropriate version, configured correctly, and running as a service with the desired state.

## Variables

| Variable Name                  | Default Value           | Description                                                                 |
|--------------------------------|-------------------------|-----------------------------------------------------------------------------|
| `zookeeper_version`            | `3.4.14`                | The version of ZooKeeper to install.                                        |
| `zookeeper_user`               | `zookeeper`             | The user under which ZooKeeper will run.                                    |
| `zookeeper_group`              | `zookeeper`             | The group under which ZooKeeper will run.                                   |
| `zookeeper_service_enabled`    | `"yes"`                 | Whether the ZooKeeper service should be enabled.                            |
| `zookeeper_service_state`      | `started`               | The desired state of the ZooKeeper service (started, stopped).              |
| `zookeeper_data_dir`           | `/usr/local/zookeeper` | The directory where ZooKeeper data will be stored.                          |
| `zookeeper_log_dir`            | `/var/log/zookeeper`    | The directory where ZooKeeper logs will be stored.                          |
| `zookeeper_install_path`       | `/opt/zookeeper`        | The path where ZooKeeper will be installed.                                 |
| `zookeeper_conf_dir`           | `{{ zookeeper_install_path }}/conf` | The directory where ZooKeeper configuration files will be stored.           |
| `client_port`                  | `2181`                  | The port on which ZooKeeper clients will connect.                           |
| `init_limit`                   | `5`                     | The amount of time in ticks to allow followers to connect to the leader.     |
| `sync_limit`                   | `2`                     | The amount of time in ticks to allow followers to sync with the leader.      |
| `tick_time`                    | `2000`                  | The basic time unit in milliseconds used by ZooKeeper.                      |
| `zookeeper_client_port`        | `{{ client_port }}`    | Alias for `client_port`.                                                    |
| `zookeeper_init_limit`         | `{{ init_limit }}`     | Alias for `init_limit`.                                                     |
| `zookeeper_sync_limit`         | `{{ sync_limit }}`     | Alias for `sync_limit`.                                                     |
| `zookeeper_tick_time`          | `{{ tick_time }}`      | Alias for `tick_time`.                                                      |
| `zookeeper_autopurge_purgeInterval` | `0` | The interval in hours for purging old log files.                            |
| `zookeeper_autopurge_snapRetainCount` | `10` | The number of snapshots to retain.                                          |
| `zookeeper_jmx_enabled`        | `true`                  | Whether JMX monitoring is enabled.                                          |
| `zookeeper_jmx_port`           | `1099`                  | The port on which JMX will be available.                                     |
| `zookeeper_java_opts`          | `-Djava.net.preferIPv4Stack=true` | Additional Java options for ZooKeeper.                                      |
| `zookeeper_rolling_log_file_max_size` | `10MB` | The maximum size of a rolling log file.                                     |
| `zookeeper_max_rolling_log_file_count` | `10` | The maximum number of rolling log files to retain.                          |
| `zookeeper_hosts`              | `[{"host": "{{inventory_hostname}}", "id": 1}]` | List of ZooKeeper hosts.                                                     |
| `zookeeper_env`                | `{}`                    | Environment variables for ZooKeeper.                                        |
| `zookeeper_force_myid`         | `true`                  | Whether to force the creation of the `myid` file.                           |
| `zookeeper_force_reinstall`    | `false`                 | Whether to force the reinstallation of ZooKeeper.                           |

## Usage

To use this role, include it in your playbook and define any necessary variables:

```yaml
- hosts: zookeeper_servers
  roles:
    - role: bootstrap_zookeeper
      vars:
        zookeeper_version: "3.5.6"
        zookeeper_data_dir: "/data/zookeeper"
        zookeeper_log_dir: "/var/log/zookeeper"
        zookeeper_install_path: "/opt/zookeeper"
```

## Dependencies

This role does not have any external dependencies. It assumes that the target system has a package manager capable of installing the required libraries such as `wget`, `tar`, and `java`.

## Best Practices

- Always test the role in a development environment before deploying it to production.
- Ensure that the target system has sufficient resources (CPU, memory, disk space) to run ZooKeeper.
- Regularly back up the ZooKeeper data directory to prevent data loss.
- Monitor the ZooKeeper service and logs to detect and resolve any issues promptly.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_zookeeper/defaults/main.yml)
- [tasks/config.yml](../../roles/bootstrap_zookeeper/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_zookeeper/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_zookeeper/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_zookeeper/tasks/service.yml)
- [handlers/main.yml](../../roles/bootstrap_zookeeper/handlers/main.yml)