```markdown
---
title: bootstrap_linux_cron Role Documentation
original_path: roles/bootstrap_linux_cron/README.md
category: Ansible Roles
tags: [ansible, cron, linux]
---

# bootstrap_linux_cron Role

Use this role to configure cron jobs on Linux systems.

## Role Variables

| Variable                      | Description                                                                                                                                                                                                                                                                                                                                           | Default Value |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `bootstrap_linux_cron__list`  | List of crons **(see cron dict details in next section)**                                                                                                                                                                                                                                                                                             | `[]`          |
| `bootstrap_linux_cron__list__*` | Variables with the prefix `bootstrap_linux_cron_list__` are dereferenced and merged into a single cron list. Each list should contain a list of `dicts`. Each `dict` defines/specifies the cron configuration to modify. Options include user variables mentioned in the next section titled `bootstrap_linux_cron__list` details. | `[]`          |

### `bootstrap_linux_cron__list` Details

Variables with the prefix `bootstrap_linux_cron_list__*` are merged when running the role.

The cron list allows you to define users. Each item in the list can have the following attributes:

| Variable     | Type               | Default | Required |
|--------------|--------------------|---------|----------|
| `name`       | str                |         | yes      |
| `state`      | C(present, absent) | present | no       |
| `disabled`   | C(true, false)     | false   | no       |
| `backup`     | C(true, false)     | false   | no       |
| `job`        | str                |         | no       |
| `minute`     | str                |         | no       |
| `hour`       | str                |         | no       |
| `day`        | str                |         | no       |
| `month`      | str                |         | no       |
| `weekday`    | str                |         | no       |
| `cron_file`  | str                |         | no       |
| `special_time` | str              |         | no       |
| `user`       | str                |         | no       |
| `ssh_key_file` | filepath         |         | no       |

## Examples

### Playbook Example

```yaml
- hosts: os_linux
  become: true
  roles:
    - role: bootstrap_linux_cron
      bootstrap_linux_cron__list:
        - name: "daily fw backups job using schedule format"
          job: "{{ bootstrap_linux_backup_script_dir }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"
          schedule: ["0", "0", "*", "*", "*"]
        - name: "daily fw backups job using special time format"
          job: "{{ bootstrap_linux_backup_script_dir }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"
          special_time: daily
        - name: "e2scrub"
          job: "test -e /run/systemd/system || SERVICE_MODE=1 /usr/lib/x86_64-linux-gnu/e2fsprogs/e2scrub_all_cron"
          schedule: ["30", "3", "*", "*", "0"]  # run 3:30AM every Sunday
        - name: "e2scrub sbin"
          job: "test -e /run/systemd/system || SERVICE_MODE=1 /sbin/e2scrub_all -A -r"
          schedule: ["30", "3", "*", "*", "*"]  # run 3:30AM every day
```

### Inventory `group_vars/` Example

**inventory/group_vars/control_node.yml:**
```yaml
bootstrap_linux_cron__list:
  - name: "daily fw backups job"
    special_time: daily
    job: "{{ bootstrap_linux_backup_script_dir }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"

  - name: "daily backups job"
    minute: "5"
    hour: "18"
    job: "python3 {{ bootstrap_linux_backup_script_dir }}/run-backups.py daily"

  - name: "monthly backups job"
    special_time: monthly
    job: "python3 {{ bootstrap_linux_backup_script_dir }}/run-backups.py monthly"
```

### Variable Lookup Example

The role will lookup and dereference all lists with the variable name prefix `bootstrap_linux_cron__list__` and merge them together for each target host at runtime.

**inventory/group_vars/docker_stack.yml:**
```yaml
# List of CRONs to be setup for docker_stack machines.
bootstrap_linux_cron__list__docker_stack:
  - name: "Docker disk clean up"
    job: "docker system prune -{{ bootstrap_docker__cron_jobs_prune_flags }} 2>&1"
    schedule: ["0", "0", "*", "*", "0"]
    cron_file: "docker-disk-clean-up"

  - name: "Docker large log file clean up"
    job: "{{ bootstrap_docker__script_dir }}/docker-cleanup-large-logfiles.sh -y 2>&1"
    schedule: ["0", "0", "*", "*", "0"]  # run 12:00AM every Sunday
    cron_file: "docker-large-logfile-clean-up"

  - name: "Restart the docker stack"
    job: "cd /home/{{ docker_stack__user_username }}/docker && docker-compose up -d"
    schedule: ["10", "1", "*", "*", "*"]  # run 1:10AM every day
    cron_file: "docker-stack-restart"
```

**inventory/group_vars/zfs_host.yml:**
```yaml
bootstrap_linux_cron__list__mergerfs:
  - name: "zfs trim"
    job: "if [ $(date +%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/trim ]; then /usr/lib/zfs-linux/trim; fi"
    schedule: ["0", "0", "*", "*", "*"]

  - name: "zfs scrub"
    job: "if [ $(date +%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ]; then /usr/lib/zfs-linux/scrub; fi"
    schedule: ["0", "0", "*", "*", "*"]  # every Sunday
```

## Backlinks

- [Ansible Roles Documentation](../ansible_roles.md)
- [Linux Configuration Playbooks](../linux_config_playbooks.md)
```