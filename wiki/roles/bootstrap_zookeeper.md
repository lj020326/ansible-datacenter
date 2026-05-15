---
title: Bootstrap ZooKeeper Role Documentation
role: bootstrap_zookeeper
category: Ansible Roles
type: Configuration Management
tags: zookeeper, ansible, configuration, automation

---

## Summary

The `bootstrap_zookeeper` role is designed to automate the installation, configuration, and management of Apache ZooKeeper on target hosts. This role handles tasks such as installing dependencies, creating necessary directories, configuring ZooKeeper settings, setting up systemd services, and managing the service state.

## Variables

| Variable Name                             | Default Value                                      | Description                                                                 |
|-------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `role_bootstrap_zookeeper__version`       | `3.4.14`                                           | The version of ZooKeeper to install.                                        |
| `role_bootstrap_zookeeper__user`          | `zookeeper`                                        | The user under which ZooKeeper will run.                                    |
| `role_bootstrap_zookeeper__group`         | `zookeeper`                                        | The group under which ZooKeeper will run.                                   |
| `role_bootstrap_zookeeper__service_enabled` | `"yes"`                                            | Whether the ZooKeeper service should be enabled at boot.                    |
| `role_bootstrap_zookeeper__service_state`   | `started`                                          | The desired state of the ZooKeeper service (e.g., started, stopped).        |
| `role_bootstrap_zookeeper__data_dir`      | `/usr/local/zookeeper`                             | Directory where ZooKeeper stores its data.                                  |
| `role_bootstrap_zookeeper__log_dir`       | `/var/log/zookeeper`                               | Directory for ZooKeeper logs.                                               |
| `role_bootstrap_zookeeper__install_path`  | `/opt/zookeeper`                                   | Installation path for ZooKeeper binaries and configuration files.         |
| `role_bootstrap_zookeeper__conf_dir`      | `"{{ role_bootstrap_zookeeper__install_path }}/conf"` | Configuration directory for ZooKeeper.                                      |
| `role_bootstrap_zookeeper__client_port`   | `2181`                                             | Port on which ZooKeeper will listen for client connections.                 |
| `role_bootstrap_zookeeper__init_limit`    | `5`                                                | Limit on the number of ticks that the initial synchronization phase can take. |
| `role_bootstrap_zookeeper__sync_limit`    | `2`                                                | Limit on the number of ticks that can pass between sending a request and getting an acknowledgment. |
| `role_bootstrap_zookeeper__tick_time`     | `2000`                                             | Basic time unit in milliseconds used by ZooKeeper for heartbeats and timeouts.|
| `role_bootstrap_zookeeper__autopurge_purgeInterval` | `0`                                            | The interval (in hours) for which the purge task has to be triggered.       |
| `role_bootstrap_zookeeper__autopurge_snapRetainCount` | `10`                                         | Number of snapshots to retain while purging old ones.                       |
| `role_bootstrap_zookeeper__jmx_enabled`   | `true`                                             | Whether JMX is enabled for ZooKeeper.                                       |
| `role_bootstrap_zookeeper__jmx_port`      | `1099`                                             | Port on which JMX will listen.                                              |
| `role_bootstrap_zookeeper__java_opts`     | `-Djava.net.preferIPv4Stack=true`                  | Java options to be passed to ZooKeeper.                                     |
| `role_bootstrap_zookeeper__rolling_log_file_max_size` | `10MB`                                      | Maximum size of a rolling log file.                                         |
| `role_bootstrap_zookeeper__max_rolling_log_file_count` | `10`                                       | Maximum number of rolling log files to retain.                              |
| `role_bootstrap_zookeeper__hosts`         | `[{"host": "{{inventory_hostname}}", "id": 1}]`     | List of ZooKeeper hosts and their IDs.                                      |
| `role_bootstrap_zookeeper__env`           | `{}`                                               | Environment variables for ZooKeeper.                                        |
| `role_bootstrap_zookeeper__force_myid`    | `true`                                             | Whether to force overwrite the myid file.                                   |
| `role_bootstrap_zookeeper__force_reinstall` | `false`                                            | Whether to force reinstall ZooKeeper even if it's already installed.        |

## Usage

To use the `bootstrap_zookeeper` role, include it in your playbook and set any necessary variables as required:

```yaml
- hosts: zookeeper_servers
  roles:
    - role: bootstrap_zookeeper
      vars:
        role_bootstrap_zookeeper__version: "3.7.0"
        role_bootstrap_zookeeper__client_port: 2182
```

## Dependencies

This role does not have any external dependencies other than the default Ansible modules.

## Best Practices

- Ensure that the `role_bootstrap_zookeeper__hosts` variable is correctly configured with all ZooKeeper nodes and their respective IDs.
- Adjust `role_bootstrap_zookeeper__java_opts` according to your environment's requirements for optimal performance.
- Monitor logs in `role_bootstrap_zookeeper__log_dir` for any issues during installation or operation.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_zookeeper/defaults/main.yml)
- [tasks/config.yml](../../roles/bootstrap_zookeeper/tasks/config.yml)
- [tasks/install.yml](../../roles/bootstrap_zookeeper/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_zookeeper/tasks/main.yml)
- [tasks/service.yml](../../roles/bootstrap_zookeeper/tasks/service.yml)
- [handlers/main.yml](../../roles/bootstrap_zookeeper/handlers/main.yml)