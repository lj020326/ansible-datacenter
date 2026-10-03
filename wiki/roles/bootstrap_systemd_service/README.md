---
harvested_date: '2023-08-07T18:07:09.430180+00:00'
original_path: roles/bootstrap_systemd_service/README.md
source_type: legacy_markdown
title: Bootstrap Systemd Service - Ansible Role
category: Ansible
tags:
  - Ansible
  - Systemd
  - Service Management
---

# Bootstrap Systemd Service - Ansible Role

This Ansible role registers services to systemd.

## Role Variables

| Name                                        | Type                | Default               | Description                          |
|---------------------------------------------|---------------------|-----------------------|--------------------------------------|
| `bootstrap_systemd_service__default_dir`    | String              | `/etc/default`        | Path for environment files           |
| `bootstrap_systemd_service__systemd_dir`    | String              | `/etc/systemd/system` | Path for systemd service files       |
| `bootstrap_systemd_service__name` *         | String              |                       | Name of the service                  |
| `bootstrap_systemd_service__envs`           | String, List, Map   | `[]`                  | Environment variables for the service|

> **Note**: `bootstrap_systemd_service__root_dir` is obsolete.

### [Unit]

| Name                                        | Type                | Default | Description                          |
|---------------------------------------------|---------------------|---------|--------------------------------------|
| `bootstrap_systemd_service__unit_description` | String              |         | [Unit] Description                   |
| `bootstrap_systemd_service__unit_documentation` | String |         | [Unit] Documentation                |
| `bootstrap_systemd_service__unit_defaultdependencies` | String |         | [Unit] DefaultDependencies          |
| `bootstrap_systemd_service__unit_requires`  | String, List        |         | [Unit] Requires                      |
| `bootstrap_systemd_service__unit_wants`     | String, List        |         | [Unit] Wants                         |
| `bootstrap_systemd_service__unit_assertpathexists` | String |         | [Unit] AssertPathExists              |
| `bootstrap_systemd_service__unit_conditionpathexists` | String |         | [Unit] ConditionPathExists           |
| `bootstrap_systemd_service__unit_conditionpathismountpoint` | String |         | [Unit] ConditionPathIsMountPoint     |
| `bootstrap_systemd_service__unit_requiresmountsfor` | String |         | [Unit] RequiresMountsFor             |
| `bootstrap_systemd_service__unit_after`     | String, List        |         | [Unit] After                         |
| `bootstrap_systemd_service__unit_before`    | String, List        |         | [Unit] Before                        |

### [Service]

| Name                                        | Type                | Default | Description                          |
|---------------------------------------------|---------------------|---------|--------------------------------------|
| `bootstrap_systemd_service__service_type`   | String              | `simple`| [Service] Type                       |
| `bootstrap_systemd_service__service_remainafterexit` | String |         | [Service] RemainAfterExit            |
| `bootstrap_systemd_service__service_execstartpre` | String, List |         | [Service] ExecStartPre               |
| `bootstrap_systemd_service__service_execstart` * | String |         | [Service] ExecStart                  |
| `bootstrap_systemd_service__service_execstartpost` | String, List |         | [Service] ExecStartPost              |
| `bootstrap_systemd_service__service_execreload` | String, List |         | [Service] ExecReload                 |
| `bootstrap_systemd_service__service_restart` | String | `no`    | [Service] Restart (no, always, on-success, on-failure) |
| `bootstrap_systemd_service__service_restartsec` | Integer |         | [Service] RestartSec                 |
| `bootstrap_systemd_service__service_execstop` | String |         | [Service] ExecStop                   |
| `bootstrap_systemd_service__service_killmode` | String |         | [Service] KillMode                   |
| `bootstrap_systemd_service__service_execstoppost` | String, List |         | [Service] ExecStopPost               |
| `bootstrap_systemd_service__service_pidfile` | String |         | [Service] PIDFile                    |
| `bootstrap_systemd_service__service_busname` | String |         | [Service] BusName                    |
| `bootstrap_systemd_service__service_privatetmp` | String |         | [Service] PrivateTmp                 |
| `bootstrap_systemd_service__service_limitnofile` | String |         | [Service] LimitNOFILE                |
| `bootstrap_systemd_service__service_user`    | String |         | [Service] User                       |
| `bootstrap_systemd_service__service_group`   | String |         | [Service] Group                      |
| `bootstrap_systemd_service__service_workingdirectory` | String |         | [Service] WorkingDirectory           |

### [Install]

| Name                                        | Type                | Default | Description                          |
|---------------------------------------------|---------------------|---------|--------------------------------------|
| `bootstrap_systemd_service__install_wantedby` | String, List | [Install] WantedBy "multi-user.target" | [Install] WantedBy                   |
| `bootstrap_systemd_service__install_requiredby` | String, List |         | [Install] RequiredBy                 |
| `bootstrap_systemd_service__install_upheldby` | String, List |         | [Install] UpheldBy                   |
| `bootstrap_systemd_service__install_also`    | String              |         | [Install] Also                       |
| `bootstrap_systemd_service__install_alias`   | String              |         | [Install] Alias                      |

> * Required

## Example Playbook

```yaml
- name: Run bootstrap_systemd_service
  hosts: servers
  roles:
    - role: bootstrap_systemd_service
      bootstrap_systemd_service__name: "swarm-manager"
      bootstrap_systemd_service__envs:
        - "DOCKER_HOST=tcp://127.0.0.1:2375"
      bootstrap_systemd_service__unit_description: Docker Swarm Manager
      bootstrap_systemd_service__unit_requires: docker.service
      bootstrap_systemd_service__unit_after: docker.service
      bootstrap_systemd_service__service_execstartpre:
        - -/usr/bin/docker stop swarm-manager
        - -/usr/bin/docker rm swarm-manager
        - /usr/bin/docker pull swarm
      bootstrap_systemd_service__service_execstart: /usr/bin/docker run -p 2377:2375 --name swarm-manager swarm manage
```

## Reference

- [Systemd Unit Documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)

## Backlinks

<!-- Add backlinks here if applicable -->