```markdown
---
title: bootstrap_systemd_service - Ansible Role to Create Systemd Service
original_path: roles/bootstrap_systemd_service/README.md
category: Ansible Roles
tags: [systemd, ansible, service]
---

# bootstrap_systemd_service - Ansible Role to Create Systemd Service

This role registers services with systemd.

## Role Variables

| Name                                             | Type       | Default                | Description                                                                 |
|--------------------------------------------------|------------|------------------------|-----------------------------------------------------------------------------|
| `bootstrap_systemd_service__default_dir`         | String     | `/etc/default`         | Path for environment files.                                                 |
| `bootstrap_systemd_service__systemd_dir`         | String     | `/etc/systemd/system`  | Systemd service file path.                                                  |
| `bootstrap_systemd_service__name` *              | String     |                        | Name of the service.                                                        |
| `bootstrap_systemd_service__envs`                | String/List/MapList | `[]`               | Environment variables (/etc/default/:name).                                 |

> **Note:**  
> `bootstrap_systemd_service__root_dir` is obsolete.

### [Unit]

| Name                                               | Type       | Default                | Description                                                                 |
|----------------------------------------------------|------------|------------------------|-----------------------------------------------------------------------------|
| `bootstrap_systemd_service__Unit_Description`      | String     |                        | [Unit]Description                                                           |
| `bootstrap_systemd_service__Unit_Documentation`    | String     |                        | [Unit]Documentation                                                         |
| `bootstrap_systemd_service__Unit_DefaultDependencies` | String    |                        | [Unit]DefaultDependencies                                                   |
| `bootstrap_systemd_service__Unit_Requires`         | String/List|                        | [Unit]Requires                                                              |
| `bootstrap_systemd_service__Unit_Wants`            | String/List|                        | [Unit]Wants                                                                 |
| `bootstrap_systemd_service__Unit_AssertPathExists` | String     |                        | [Unit]AssertPathExists                                                      |
| `bootstrap_systemd_service__Unit_ConditionPathExists` | String   |                        | [Unit]ConditionPathExists                                                   |
| `bootstrap_systemd_service__Unit_ConditionPathIsMountPoint` | String |                    | [Unit]ConditionPathIsMountPoint                                             |
| `bootstrap_systemd_service__Unit_RequiresMountsFor` | String    |                        | [Unit]RequiresMountsFor                                                     |
| `bootstrap_systemd_service__Unit_After`            | String/List|                        | [Unit]After                                                                 |
| `bootstrap_systemd_service__Unit_Before`           | String/List|                        | [Unit]Before                                                                |

### [Service]

| Name                                               | Type       | Default                | Description                                                                 |
|----------------------------------------------------|------------|------------------------|-----------------------------------------------------------------------------|
| `bootstrap_systemd_service__Service_Type`          | String     | `"simple"`             | [Service]Type                                                               |
| `bootstrap_systemd_service__Service_RemainAfterExit` | String    |                        | [Service]RemainAfterExit                                                    |
| `bootstrap_systemd_service__Service_ExecStartPre`  | String/List|                        | [Service]ExecStartPre                                                       |
| `bootstrap_systemd_service__Service_ExecStart` *   | String     |                        | [Service]ExecStart                                                          |
| `bootstrap_systemd_service__Service_ExecStartPost` | String/List|                        | [Service]ExecStartPost                                                      |
| `bootstrap_systemd_service__Service_ExecReload`    | String/List|                        | [Service]ExecReload                                                         |
| `bootstrap_systemd_service__Service_Restart`       | String     | `"no"`                 | [Service]Restart ("no", "always", "on-success", "on-failure")               |
| `bootstrap_systemd_service__Service_RestartSec`    | Integer    |                        | [Service]RestartSec                                                         |
| `bootstrap_systemd_service__Service_ExecStop`      | String     |                        | [Service]ExecStop                                                           |
| `bootstrap_systemd_service__Service_KillMode`      | String     |                        | [Service]KillMode                                                           |
| `bootstrap_systemd_service__Service_ExecStopPost`  | String/List|                        | [Service]ExecStopPost                                                       |
| `bootstrap_systemd_service__Service_PIDFile`       | String     |                        | [Service]PIDFile                                                            |
| `bootstrap_systemd_service__Service_BusName`       | String     |                        | [Service]BusName                                                            |
| `bootstrap_systemd_service__Service_PrivateTmp`    | String     |                        | [Service]PrivateTmp                                                         |
| `bootstrap_systemd_service__Service_LimitNOFILE`   | String     |                        | [Service]LimitNOFILE                                                        |
| `bootstrap_systemd_service__Service_User`          | String     |                        | [Service]User                                                               |
| `bootstrap_systemd_service__Service_Group`         | String     |                        | [Service]Group                                                              |
| `bootstrap_systemd_service__Service_WorkingDirectory` | String   |                        | [Service]WorkingDirectory                                                   |

### [Install]

| Name                                               | Type       | Default                | Description                                                                 |
|----------------------------------------------------|------------|------------------------|-----------------------------------------------------------------------------|
| `bootstrap_systemd_service__Install_WantedBy`      | String/List| `"multi-user.target"`  | [Install]WantedBy                                                           |
| `bootstrap_systemd_service__Install_RequiredBy`    | String/List|                        | [Install]RequiredBy                                                         |
| `bootstrap_systemd_service__Install_UpheldBy`      | String/List|                        | [Install]UpheldBy                                                           |
| `bootstrap_systemd_service__Install_Also`          | String     |                        | [Install]Also                                                               |
| `bootstrap_systemd_service__Install_Alias`         | String     |                        | [Install]Alias                                                              |

> * Required

## Example Playbook

```yaml
- name: Run bootstrap_systemd_service
  hosts: servers
  roles:
    - role: bootstrap_systemd_service
      vars:
        bootstrap_systemd_service__name: "swarm-manager"
        bootstrap_systemd_service__envs:
          - "DOCKER_HOST=tcp://127.0.0.1:2375"
        bootstrap_systemd_service__Unit_Description: Docker Swarm Manager
        bootstrap_systemd_service__Unit_Requires: docker.service
        bootstrap_systemd_service__Unit_After: docker.service
        bootstrap_systemd_service__Service_ExecStartPre:
          - "/usr/bin/docker stop swarm-manager"
          - "/usr/bin/docker rm swarm-manager"
          - "/usr/bin/docker pull swarm"
        bootstrap_systemd_service__Service_ExecStart: "/usr/bin/docker run -p 2377:2375 --name swarm-manager swarm manage"
```

## Reference

- [systemd.unit](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)

## Backlinks

- [Ansible Roles Documentation](../ansible_roles.md)
```

This improved version includes a standardized YAML frontmatter, clear and structured headings, and a "Backlinks" section for reference.