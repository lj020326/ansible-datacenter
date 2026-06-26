
# bootstrap_linux_cron

This Ansible role manages system cron jobs and coordinates sequential daily maintenance workflows using structured execution hooks. It provides a modular framework for managing both standard recurring tasks and complex multi-stage maintenance batches (pre-update, update, post-update).

## Role Variables

### Core Configuration

| Variable                                    | Description                                                                                                                                                                                                           | Default value |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `bootstrap_linux_cron__list`                | List of crons **(see cron dict details in next section)**                                                                                                                                                             | `[]`          |
| `bootstrap_linux_cron__list__*`             | Variables with prefix `bootstrap_linux_cron__list__` are dereferenced and merged into a single cron list. Each list should contain a list of `dicts`. Each `dict` defines/specifies the cron configuration to modify. | `[]`          |
| `bootstrap_linux_cron__setup_daily_scripts` | Boolean flag to enable or disable the deployment of the primary daily maintenance framework and hooks.                                                                                                                | `false`       |
| `bootstrap_linux_cron__reset_daily_scripts` | Boolean flag to determine if daily script dirs should get reset before deployment.                                                                                                                                    | `true`        |
| `bootstrap_linux_cron__os_update_hooks`     | List of custom maintenance hook dictionaries to register globally.                                                                                                                                                    | `[]`          |
| `bootstrap_linux_cron__os_update_hooks__*`  | Variables with prefix `bootstrap_linux_cron__os_update_hooks__` are automatically gathered across inventory groups and merged into a structured script directory scheme.                                              | `[]`          |


### Cron Definition Attributes

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

### Daily Batch Hook Attributes

#### `bootstrap_linux_cron__os_update_hooks` details

When `bootstrap_linux_cron__setup_daily_scripts` is set to `true`, the role sets up an alphanumeric execution frame under `/etc/run-os-update/`. Hook files are deployed dynamically into target lifecycle stages using the keys below:

| Attribute | Type | Description | Required |
| :--- | :--- | :--- | :--- |
| `name` | str | Descriptive identifier for the hook. | Yes |
| `hook_type` | str | Lifecycle stage: `pre-update.d`, `update.d`, or `post-update.d`. | Yes |
| `filename` | str | Target filename (e.g., `10-docker-stop`). Use prefix integers for sort order. | Yes |
| `content` | str | The multi-line script body to execute. | Yes |

---

## Usage Examples

### 1. Simple Playbook Integration
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

### 2. Group-Specific Variable Merging
The role automatically merges lists sharing the `bootstrap_linux_cron__list__` prefix. 

**`inventory/group_vars/docker_stack.yml`:**
```yaml
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

### 3. OS Update Processing & Lifecycle Hooks
The `run-os-update.sh` script executes hooks sequentially via `run-parts`. Use `bootstrap_linux_cron__os_update_hooks__*` to decouple business logic from code.

The OS update framework sets up a central runner script (`/usr/local/bin/run-os-update.sh`) which loops across step phases (`pre-update.d` $\rightarrow$ `update.d` $\rightarrow$ `post-update.d`) sequentially using `run-parts`.

**Defining Hooks in Inventory:**
```yaml
bootstrap_linux_cron__os_update_hooks__docker_stack:
  - name: "Stop Docker Stack"
    hook_type: "pre-update.d"
    filename: "10-docker-stop.sh"
    content: |
      #!/usr/bin/env bash
      echo "Stopping Docker services..."
      docker stack rm my_stack

  - name: "Start Docker Stack"
    hook_type: "post-update.d"
    filename: "90-docker-start.sh"
    content: |
      #!/usr/bin/env bash
      echo "Redeploying Docker services..."
      docker stack deploy -c /home/user/docker-compose.yml my_stack
```

### 4. Wave-Based Execution Strategy
To avoid overloading infrastructure (e.g., network bandwidth or CPU spikes), use inventory group hierarchy to stagger maintenance execution windows.

**Inventory Structure (`xenv_groups.yml`):**
```yaml
all:
  children:
    os_linux_cron_wave:
      children:
        os_linux_cron_wave_01:
          children:
            os_linux_cron_wave_02: {} # Wave 02 inherits Wave 01 group vars
```

**Wave Configuration:**
* `inventory/group_vars/os_linux_cron_wave_01.yml`:
  ```yaml
  ## Executed at 01:00 AM
  bootstrap_linux_cron__list__os_update:
    - name: "OS Update Batch - Wave 01"
      job: "/usr/local/bin/run-os-update.sh 2>&1 | tee -a /var/log/run-os-update.log"
      schedule: ["0", "1", "*", "*", "*"]
  ```

* `inventory/group_vars/os_linux_cron_wave_02.yml`:
  ```yaml
  ## Executed at 02:00 AM
  bootstrap_linux_cron__list__os_update:
    - name: "OS Update Batch - Wave 02"
      job: "/usr/local/bin/run-os-update.sh 2>&1 | tee -a /var/log/run-os-update.log"
      schedule: ["0", "2", "*", "*", "*"]
  ```
