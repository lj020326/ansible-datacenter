
# bootstrap_linux_cron

Use this role to configure cron jobs.

## Role Variables

| Variable                      | Description                                                                                                                                                                                                                                                                                                                                           | Default value |
|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| bootstrap_linux_cron__list    | List of crons **(see cron dict details in next section)**                                                                                                                                                                                                                                                                                             | `[]`          |
| bootstrap_linux_cron__list__* | Variables with prefix `bootstrap_linux_cron_list__` are dereferenced and merged into a single cron list.  Each list should contain a list of `dicts`.  Each `dict` defines/specifies the cron configuration to modify.  `Dict` options include the user variables mentioned in the next section titled `bootstrap_linux_cron__list` details. | []            |


#### `bootstrap_linux_cron__list` details

`bootstrap_linux_cron__list__*` vars are merged when running the role. 

The cron list allows you to define users. Each item in the list can have the following attributes:

| Variable     | Type               | Default | Required |
|--------------|--------------------|---------|----------|
| name         | str                |         | yes      |                                   
| state        | C(present, absent) | present | no       |
| disabled     | C(true, false)     | false   | no       |
| backup       | C(true, false)     | false   | no       |
| job          | str                |         | no       |        
| minute       | str                |         | no       |         
| hour         | str                |         | no       | 
| day          | str                |         | no       |         
| month        | str                |         | no       |   
| weekday      | str                |         | no       |   
| cron_file    | str                |         | no       |                                                 
| special_time | str                |         | no       |         
| user         | str                |         | no       | 
| ssh_key_file | filepath           |         | no       |         

## Examples

### Playbook Example

```yaml
- hosts: os_linux
  become: true
  roles:
    - role: bootstrap_linux_cron
      bootstrap_linux_cron__list:
        - name: "daily fw backups job using schedule format"
          job: "{{ bootstrap_linux_backup_script_dir 
            }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"
          schedule: ["0", "0", "*", "*", "*"]
        - name: "daily fw backups job using special time format"
          job: "{{ bootstrap_linux_backup_script_dir 
            }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"
          special_time: daily
        - name: "e2scrub"
          job: "test -e /run/systemd/system || SERVICE_MODE=1 /usr/lib/x86_64-linux-gnu/e2fsprogs/e2scrub_all_cron"
          ## run 3:30AM every sunday
          schedule: ["30", "3", "*", "*", "0"]
        - name: "e2scrub sbin"
          job: "test -e /run/systemd/system || SERVICE_MODE=1 /sbin/e2scrub_all -A -r"
          ## run 3:30AM every day
          schedule: ["30", "3", "*", "*", "*"]

```

### Inventory group_vars/ Example

inventory/group_vars/control_node.yml:
```yaml
bootstrap_linux_cron__list:
  - name: "daily fw backups job"
    special_time: daily
    job: "{{ bootstrap_linux_backup_script_dir }}/fwbackup.sh 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/fwbackup_daily.log"

  - name: "daily backups job"
#    special_time: daily
#    schedule: ["0", "0", "*", "*", "0"]
#    job: "{{ bootstrap_linux_backup_script_dir }}/job-backup-incremental.sh DAILY /data/Records {{ docker_stack__backups_dir }}/records/daily 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/backup_records_daily.log"
    minute: "5"
    hour: "18"
#    job: "bash -x {{ bootstrap_linux_backup_script_dir }}/run-daily-backup.sh"
    job: "python3 {{ bootstrap_linux_backup_script_dir }}/run-backups.py daily"

  - name: "monthly backups job"
    special_time: monthly
#    job: "{{ bootstrap_linux_backup_script_dir }}/job-backup-incremental.sh  MONTHLY /data/Records {{ docker_stack__backups_dir }}/records/monthly 2>&1 | tee -a {{ bootstrap_linux_backups_log_dir }}/backup_records_monthly.log"
#    job: "bash -x {{ bootstrap_linux_backup_script_dir }}//run-monthly-backup.sh"
    job: "python3 {{ bootstrap_linux_backup_script_dir }}/run-backups.py monthly"

```

### Variable Lookup Example

The role will lookup/dereference all lists with variable name prefix of 'bootstrap_linux_cron__list__' and merge together all lists for each target host at runtime.

In the example below, all hosts belonging to the 'docker_stack' group will automatically have the crons setup as specified in the inventory group_vars.

inventory/group_vars/docker_stack.yml:
```yaml
# list of CRONs to be setup for docker_stack machines.
bootstrap_linux_cron__list__docker_stack:
  - name: "Docker disk clean up"
    job: "docker system prune -{{ bootstrap_docker__cron_jobs_prune_flags }} 2>&1"
    schedule: ["0", "0", "*", "*", "0"]
    cron_file: "docker-disk-clean-up"
#    user: "{{ docker_stack__user_username }}"

  - name: "Docker large log file clean up"
    job: "{{ bootstrap_docker__script_dir }}/docker-cleanup-large-logfiles.sh -y 2>&1"
    ## run 12:00AM every sunday
    schedule: ["0", "0", "*", "*", "0"]
    cron_file: "docker-large-logfile-clean-up"
#    user: "{{ docker_stack__user_username }}"

  - name: "Restart the docker stack"
    job: "cd /home/{{ docker_stack__user_username }}/docker && /usr/local/bin/docker-compose up -d"
    ## run 1:10AM every day
    schedule: ["10", "1", "*", "*", "*"]
    cron_file: "docker-stack-restart"
#    user: "{{ docker_stack__user_username }}"
```


inventory/group_vars/zfs_host.yml:
```yaml
bootstrap_linux_cron__list__mergerfs:
  - name: "zfs trim"
    job: "if [ $(date +%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/trim ]; then /usr/lib/zfs-linux/trim; fi"
    schedule: ["0", "0", "*", "*", "*"]
  - name: "zfs scrub"
    job: "if [ $(date +%w) -eq 0 ] && [ -x /usr/lib/zfs-linux/scrub ]; then /usr/lib/zfs-linux/scrub; fi"
    ## every sunday
    schedule: ["0", "0", "*", "*", "0"]

```
