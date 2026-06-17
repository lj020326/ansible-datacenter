
# bootstrap_linux_cron

Use this role to configure cron jobs and manage sequential daily maintenance batch workflows using structured hooks.

## Role Variables

| Variable                                     | Description                                                                                                                                                                                                           | Default value |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `bootstrap_linux_cron__list`                 | List of crons **(see cron dict details in next section)**                                                                                                                                                             | `[]`          |
| `bootstrap_linux_cron__list__*`              | Variables with prefix `bootstrap_linux_cron__list__` are dereferenced and merged into a single cron list. Each list should contain a list of `dicts`. Each `dict` defines/specifies the cron configuration to modify. | `[]`          |
| `bootstrap_linux_cron__setup_daily_scripts`  | Boolean flag to enable or disable the deployment of the master daily maintenance framework and hooks.                                                                                                                 | `false`       |
| `bootstrap_linux_cron__daily_batch_hooks`    | List of custom maintenance hook dictionaries to register globally.                                                                                                                                                    | `[]`          |
| `bootstrap_linux_cron__daily_batch_hooks__*` | Variables with prefix `bootstrap_linux_cron__daily_batch_hooks__` are automatically gathered across inventory groups and merged into a structured script directory scheme.                                            | `[]`          |

#### `bootstrap_linux_cron__list` details

`bootstrap_linux_cron__list__*` vars are merged when running the role. 

The cron list allows you to define a list of jobs. Each item in the list can have the following attributes:

| Variable | Type | Default | Required |
|---|---|---|---|
| `name` | str | | yes |
| `state` | C(present, absent) | present | no |
| `disabled` | C(true, false) | false | no |
| `backup` | C(true, false) | false | no |
| `job` | str | | no |
| `minute` | str | | no |
| `hour` | str | | no |
| `day` | str | | no |
| `month` | str | | no |
| `weekday` | str | | no |
| `cron_file` | str | | no |
| `special_time`| str | | no |
| `user` | str | root | no |

---

#### `bootstrap_linux_cron__daily_batch_hooks` details

When `bootstrap_linux_cron__setup_daily_scripts` is set to `true`, the role sets up an alphanumeric execution frame under `/etc/daily-maintenance/`. Hook files are deployed dynamically into target lifecycle stages using the keys below:

| Attribute | Type | Description | Required |
|---|---|---|---|
| `name` | str | Descriptive identifier for the lifecycle hook. | yes |
| `state` | C(present, absent) | Dictates if the hook file should be created or deleted. Defaults to `present`. | no |
| `hook_type` | str | Targeted lifecycle stage directory: `pre-update.d`, `update.d`, or `post-update.d`. | yes |
| `filename` | str | The target filename (e.g., `10-docker-stop.sh`). Prepended integers ensure predictable sorting order. | yes |
| `content` | str | The exact multi-line script body to inject inside the deployed script. | yes |

---

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
          ## run 3:30AM every sunday
          schedule: ["30", "3", "*", "*", "0"]
        - name: "e2scrub sbin"
          job: "test -e /run/systemd/system || SERVICE_MODE=1 /sbin/e2scrub_all -A -r"
          ## run 3:30AM every day
          schedule: ["30", "3", "*", "*", "*"]
```

### Inventory group_vars/ Example

#### Standard Cron Definitions (`inventory/group_vars/control_node.yml`)
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

The role evaluates lists sharing the prefix `bootstrap_linux_cron__list__` and merges them together seamlessly for target hosts at runtime.

#### Group-Specific Crons (`inventory/group_vars/docker_stack.yml`)
```yaml
# list of CRONs to be setup for docker_stack machines.
bootstrap_linux_cron__list__docker_stack:
  - name: "Docker disk clean up"
    job: "docker system prune -{{ bootstrap_docker__cron_jobs_prune_flags }} 2>&1"
    schedule: ["0", "0", "*", "*", "0"]
    cron_file: "docker-disk-clean-up"

  - name: "Docker large log file clean up"
    job: "{{ bootstrap_docker__script_dir }}/docker-cleanup-large-logfiles.sh -y 2>&1"
    schedule: ["0", "0", "*", "*", "0"]
    cron_file: "docker-large-logfile-clean-up"
```

---

### Daily Batch Processing & Lifecycle Hooks Example

To move business logic entirely out of code and into inventory configuration, use the `bootstrap_linux_cron__daily_batch_hooks__*` pattern. The master framework sets up a central runner script (`/usr/local/bin/daily-maintenance.sh`) which loops across step phases (`pre-update.d` $\rightarrow$ `update.d` $\rightarrow$ `post-update.d`) sequentially using `run-parts`.

#### 1. Baseline Linux Updates (`inventory/group_vars/common_groups_os_linux.yml`)
Configure a generic update baseline across all Linux endpoints utilizing the cross-platform platform execution script deployed by the role:
```yaml
bootstrap_linux_cron__daily_batch_hooks__linux_common:
  - name: "Perform OS Updates"
    state: present
    hook_type: "update.d"
    filename: "50-os-update.sh"
    content: |
      #!/usr/bin/env bash
      echo "Running OS Updates via core platform script..."
      /usr/local/bin/perform-os-updates.sh
```

#### 2. Service Orchestration Overrides (`inventory/group_vars/docker_stack.yml`)
Safely decouple state dependencies by wrapping the core update tier with environment specific actions using lower or higher execution sorting weights (`10-` vs `90-`):
```yaml
bootstrap_linux_cron__daily_batch_hooks__docker_stack:
  - name: "Stop Docker Stack Pre-Update"
    state: present
    hook_type: "pre-update.d"
    filename: "10-docker-stop.sh"
    content: |
      #!/usr/bin/env bash
      echo "Stopping active workloads on Docker Stack..."
      /usr/local/bin/recreate-stack.sh -sr

  - name: "Start Docker Stack Post-Update"
    state: present
    hook_type: "post-update.d"
    filename: "90-docker-start.sh"
    content: |
      #!/usr/bin/env bash
      echo "Starting workloads and restarting Docker service..."
      systemctl restart docker
```

#### 3. Wave-Based Execution Triggers
Map different timing offsets across targeted logical segments using the cron structure to trigger the consolidated maintenance frame safely without overloading shared network or virtualization resources.

* `inventory/group_vars/os_linux_cron_wave_01.yml`:
  ```yaml
  ## Executed at 01:00 AM
  bootstrap_linux_cron__list__wave_01:
    - name: "Daily Maintenance Batch - Wave 01"
      job: "/usr/local/bin/daily-maintenance.sh >> /var/log/daily-maintenance.log 2>&1"
      schedule: ["0", "1", "*", "*", "*"]
  ```

* `inventory/group_vars/os_linux_cron_wave_02.yml`:
  ```yaml
  ## Executed at 02:00 AM
  bootstrap_linux_cron__list__wave_02:
    - name: "Daily Maintenance Batch - Wave 02"
      job: "/usr/local/bin/daily-maintenance.sh >> /var/log/daily-maintenance.log 2>&1"
      schedule: ["0", "2", "*", "*", "*"]
  ```
