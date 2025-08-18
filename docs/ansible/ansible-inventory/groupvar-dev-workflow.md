
# Group development workflow

## Adding/Removing Group(s)

### Development Process Overview

At a high level, the process of adding/removing inventory groups consists of the following __FIVE STEPS__:

1) add/remove group with _group-parent-child-ancestry_ into `inventory/xenv_groups.yml`.
2) add/remove group variable settings in the respective group's `group_vars` file(s).
3) map hosts into the _child (purpose|environment)-specific group_ in the respective environment `hosts.yml`.
4) run [script to synchronize environment symlinks](../inventory/sync-inventory-xenv-links.sh).
5) run [script to perform inventory validations/tests](../inventory/run-inventory-tests.sh).
6) Commit/Push the inventory groupvars code change(s). 

## Inventory Group Development Process Details/Examples

### STEP 1: ADD/REMOVE group(s) with _group-parent-child-ancestry_ into `inventory/xenv_groups.yml`

Example _group parent-child ancestry_ configuration for `app_abc123` in `inventory/xenv_groups.yml`:
```yaml
all:
  children:
    ...
    app_abc123:
      children:
        app_abc123_dev: {}
        app_abc123_prod: {}
        app_abc123_qa: {}
    ...

```

### STEP 2: ADD/REMOVE group variable settings in the respective group's `group_vars` file(s)

The rule-of-thumb is to:<br>

a) apply all `group_vars` variable settings in the highest level respective purpose group that is child-agnostic group (environment-agnostic in the following example) (e.g. 'inventory/group_vars/[group_name].yml'),<br>
b) for variable settings are specific to any child purpose/environment, apply _ONLY_ those settings to the child/environment-specific group (e.g. 'inventory/group_vars/[group_name]_[purpose|env].yml')

Example `group_vars` configuration for `app_abc123` in `inventory/group_vars/app_abc123.yml`:
```yaml
app_abc123__server_name: "{{ inventory_hostname }}"
app_abc123__servertype: Database
app_abc123__hw_enable: true
app_abc123__mode: apm

# Availability Zone based on server type (Database, OCP, Weblogic) and Environment
app_abc123__hw_zone: "{{ app_abc123__servertype | default('Unknown') }}_{{ env | upper }}"

# PostgreSQL variables
app_abc123__db_type: postgresql
app_abc123__db_driver: org.postgresql.Driver
app_abc123__db_name: app_abc123
app_abc123__db_user: app_abc123
app_abc123__db_url: "jdbc:postgresql://{{ app_abc123__server_name }}:5432/{{ app_abc123__db_name }}"

# Host tags should be defined at a group level
app_abc123__host_tags:
- "{{ env | upper }}"
- "APPSERVICE"
```

Example `group_vars` configuration for `app_abc123` in `inventory/group_vars/app_abc123_dev.yml`:
```yaml
app_abc123__env: DEV
app_abc123__tfs_agent__deploymentpoolname: ABC123-DEV
```

Example `group_vars` configuration for `app_abc123` in `inventory/group_vars/app_abc123_qa.yml`:
```yaml
app_abc123__env: QA
app_abc123__tfs_agent__deploymentpoolname: ABC123-QA
```

Example `group_vars` configuration for `app_abc123` in `inventory/group_vars/app_abc123_prod.yml`:
```yaml
app_abc123__env: PROD
app_abc123__tfs_agent__deploymentpoolname: ABC123-PROD
```

### STEP 3: Map hosts into the _child (purpose|environment)-specific group_ in the respective environment `hosts.yml`.

Map hosts to the respective child purpose-specific group in the respective environment `hosts.yml`.

Example hosts mapped into group `app_abc123_dev` in `inventory/DEV/hosts.yml`:
```yaml
all:
  children:
    ...
    app_abc123_dev:
      hosts:
        abc123-01.dev.example.int: {}
        abc123-02.dev.example.int: {}
    ...

```

### STEP 4: Run [script to synchronize environment symlinks](../inventory/sync-inventory-xenv-links.sh).

Run the [sync-inventory-xenv-links.sh](../inventory/sync-inventory-xenv-links.sh) shell script to synchronize symlinks for each new/removed group(s) into each environment directory.

Example:
```shell
ljohnson@Lees-MacBook-Pro:[tests](main)$ git switch develop-lj
Switched to branch 'develop-lj'
Your branch is up to date with 'origin/develop-lj'.
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ sync-inventory-xenv-links.sh 
[INFO ]: ==> PROJECT_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter
[INFO ]: ==> INVENTORY_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter/inventory
[INFO ]: ==> SYNC_FUNCTIONS[@]=all
[INFO ]: ==> run_sync_function(create_host_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(create_groupvars_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(create_hostvars_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(sort_xenv_files): SUCCESS
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$
```

Running the synchronization will only need to be done upon adding or removing a `group_vars` file. 

The `group_vars` synchronization script enforces:

1) highly efficient `group_vars` development workflow 
2) maintaining all `group_vars` in a _DRY_/_deduplicated_ method
3) consolidated env-specific `group_vars` files available across all inventory child directories

### STEP 5: Run [script to perform inventory validations/tests](../inventory/run-inventory-tests.sh).

Run the [run-inventory-tests.sh](../inventory/run-inventory-tests.sh) shell script to perform inventory validations/tests.

After synchronization, perform all the inventory quality checks by running the [run-inventory-tests.sh](../inventory/run-inventory-tests.sh) script.
This script will run a series of validation checks/tests and report any exceptions found.

This same script is invoked by the jenkins test pipeline for `aap-inventory PR requests` enabling the developer to resolve any issues before submitting the PR.

Example run of the script with ideal validation results:

```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ run-inventory-tests.sh 
[INFO ]: ==> PROJECT_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter
[INFO ]: ==> TEST_CASES=ALL
[INFO ]: ==> run_tests(): TEST_CASES[@]=ALL
[INFO ]: ==> run_test_case(01): validate_yamllint: SUCCESS
[INFO ]: ==> run_test_case(02): validate_file_extensions: SUCCESS
[INFO ]: ==> run_test_case(03): validate_yml_sortorder: SUCCESS
[INFO ]: ==> run_test_case(04): validate_xenv_group_hierarchy: SUCCESS
[INFO ]: ==> run_test_case(05): validate_child_inventories: SUCCESS
[INFO ]: ==> run_test_case(06): validate_child_groupvars: SUCCESS
[INFO ]: ==> run_tests(): ERROR_COUNT=0
[INFO ]: ==> *********************** 
[INFO ]: ==> OVERALL INVENTORY TEST RESULTS
[INFO ]: ==> TOTAL TOTAL_FAILED=0
[INFO ]: ==> TEST SUCCEEDED!
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ 
```

__Resolve any/all reported inventory issue(s) if any exist and repeat this step until none exist.__

### Step 6: Commit/Push the inventory groupvars code change(s)

After successful test, then add, commit, and push the inventory groupvars code change(s) for the developer's branch.

E.g., given a example feature branch named "feature/INFRA-1234", the git code commit/push process is accomplished with:
```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ git add . 
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ git commit -m "AIM-1234 - inventory group enhancements" 
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ git push origin develop-lj
```

After the code commit/push, the inventory repo pipeline will automatically execute for the developer's branch.

The inventory test pipeline will execute the same inventory test script (run-inventory-tests.sh) mentioned above to confirm that the code successfully passes all validation criteria for the developer's branch.

#### Create feature branch and copy developer branch changes into the feature branch

Make sure to pull in the latest default upstream branch ('development') code changes and switch to the upstream branch ('development'):

```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ git fetch origin development:development 
## or if older git version, use 'git checkout development'
ljohnson@ansible01.dev.dettonville.int[aap-inventory](develop-lj)$ git switch development  
ljohnson@ansible01.dev.dettonville.int[aap-inventory](development)$ 
```

Create the feature branch locally or using the equivalent branch create button from the Jira UI:

```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](development)$ git checkout -b feature/AIM-1234
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$  
```

Make sure to set/push the feature upstream branch to same origin feature branch:

```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git push -u origin feature/AIM-1234 
```

Copy the changes made in the developer's branch in the 'inventory/' directory to the feature branch:

```shell
## NOTE: if desirable run git diff first to validate changes to be copied from the developer's branch into the feature branch:
## ref: https://stackoverflow.com/questions/8382019/how-do-i-git-diff-on-a-certain-directory
## ref: https://devconnected.com/how-to-compare-two-git-branches/
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git diff develop-lj..feature/AIM-1234 inventory/
## now copy changes from the developer's branch to the feature branch
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git checkout develop-lj -- inventory/
```

Make sure all symlinks are synchronized in feature branch.

The symlinks should copy over with prior checkout but redundantly running the sync script is simple way to validate:
```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ sync-inventory-xenv-links.sh 
[INFO ]: ==> PROJECT_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter
[INFO ]: ==> INVENTORY_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter/inventory
[INFO ]: ==> SYNC_FUNCTIONS[@]=all
[INFO ]: ==> run_sync_function(create_host_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(create_groupvars_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(create_hostvars_links_yml): SUCCESS
[INFO ]: ==> run_sync_function(sort_xenv_files): SUCCESS
```

Test/Validate the feature branch changes:
```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ run-inventory-tests.sh 
[INFO ]: ==> PROJECT_DIR=/Users/ljohnson/repos/ansible/ansible-datacenter
[INFO ]: ==> TEST_CASES=ALL
[INFO ]: ==> run_tests(): TEST_CASES[@]=ALL
[INFO ]: ==> run_test_case(01): validate_yamllint: SUCCESS
[INFO ]: ==> run_test_case(02): validate_file_extensions: SUCCESS
[INFO ]: ==> run_test_case(03): validate_yml_sortorder: SUCCESS
[INFO ]: ==> run_test_case(04): validate_xenv_group_hierarchy: SUCCESS
[INFO ]: ==> run_test_case(05): validate_child_inventories: SUCCESS
[INFO ]: ==> run_test_case(06): validate_child_groupvars: SUCCESS
[INFO ]: ==> run_tests(): ERROR_COUNT=0
[INFO ]: ==> *********************** 
[INFO ]: ==> OVERALL INVENTORY TEST RESULTS
[INFO ]: ==> TOTAL TOTAL_FAILED=0
[INFO ]: ==> TEST SUCCEEDED! 
```

Add, commit and push the feature branch changes:
```shell
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git add .
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git commit -m "AIM-1234 - inventory group enhancements" 
ljohnson@ansible01.dev.dettonville.int[aap-inventory](feature/AIM-1234)$ git push origin feature/AIM-1234
```

After the code commit/push, the inventory repo pipeline will automatically execute for the feature branch.

The inventory test pipeline will execute the same inventory test script (run-inventory-tests.sh) mentioned above to confirm that the code successfully passes all validation criteria for the feature branch.


## Other useful notes/considerations

### Environment Development and Validation Testing

Upon functional validation with a test group, the developer should confirm that the _host-to-group configuration_ is valid given the intended set of hosts to be mapped to the group.

#### NTP Client Example TEST group

For this example, assume there is role to set up an `ntp client` configuration for linux hosts.

`inventory/DEV/TEST/testgroup_ntp.yml`:
```yaml
---

testgroup:
  children:
    ## TEST GROUP
    testgroup_ntp:
      children:
        ## TEST GROUP
        testgroup_ntp_network_mem:
          children:
            testgroup_lnx_site1: {}
        ## TEST GROUP
        testgroup_ntp_network_dfw:
          children:
            testgroup_lnx_site4: {}
        ## TEST GROUP
        testgroup_ntp_server:
          children:
            testgroup_ntp_server_mem:
              hosts:
                ntpq1s1.example.int: {}
            testgroup_ntp_server_dfw:
              hosts:
                ntpq1s4.example.int: {}

#####################
##
## NOTES:
##   The following `testgroup_*` mappings must be placed directly under the root/all node
##   and peers to the `testgroup` group above.
##
#####################

## ROLE GROUP to TEST GROUP mapping
ntp_server:
  children:
    testgroup_ntp_server: {}

## ROLE GROUP to TEST GROUP mapping
ntp_network_mem:
  children:
    testgroup_ntp_network_mem: {}

## ROLE GROUP to TEST GROUP mapping
ntp_network_dfw:
  children:
    testgroup_ntp_network_dfw: {}

```

The inventory group are hosts mapped in a group called `ntp_network` that will have 500+ hosts.

`inventory/xenv_groups.yml`:
```yaml
---
all:
  children:
    ...
    ntp_network:
      children:
        ntp_network_dfw:
          children:
            linux_dfw:
        ntp_network_mem:
          children:
            linux_mem:
        ntp_server:
          children:
            ntp_server_dfw: {}
            ntp_server_mem: {}
    ...

```

For ntp clients, the developer then sets up the `hosts:` key in the playbook expected to be deployed to run against the end-state group `ntp_network`.

`site.yml`:
```yaml
---

...

- name: "Setup ntp servers"
  hosts: ntp_server,!node_offline
  become: yes
  tags:
    - bootstrap-ntp
    - bootstrap-ntp-server
  roles:
    - role: bootstrap_ntp

- name: "Setup ntp clients"
  hosts: ntp_network,!ntp_server,!node_offline
  become: yes
  tags:
    - bootstrap-ntp
    - bootstrap-ntp-client
  roles:
    - role: bootstrap_ntp

...

```

Initially for functional validation, a small set of test hosts are used and mapped to a respective group called `testgroup_ntp`.

The developer sets up the end-state playbook with the `hosts:` key defined with the end-state' group `ntp_network`.

For playbook validation testing, the developer runs the playbook specifying a limit directive using the test group `testgroup_ntp`.

After succeeding functional validation testing, the developer then seeks to validate that the playbook works for the ultimate/intended group to be used in the end-state inventory.

### Post-Change Validation Testing

Upon promotion into any upper environment, the developer/operator can use the same aforementioned playbook run `limit` method specifying the test group `testgroup_*` in order to perform post-deployment validation to confirm that the end-state configuration group and group_vars work as intended/expected for the playbook by running with limit directives to isolate small sample sets of hosts.

The assumption is that the same test groups exist across all environment but with environment-specific hosts mapped into the test groups for each environment.

For example, for the ntp playbook mentioned earlier, in all environments, the test group `testgroup_ntp` should exist.  
Then the test group hosts yaml (e.g., `TEST/testgroup_lnx.yml`) specifies the environment-specific hosts that belong to the test group `testgroup_ntp`.

### TEST group configuration across environments

Ansible developers should have __inventory test group(s)__ defined for each environment to perform post-deployment validation(s) for playbooks/roles.

Upon deployment to each environment, the post-deployment validation/checks should be run using the playbook and the defined __inventory test group__.
The ansible `limit` directive is then used to isolate the __inventory test group__ set of hosts in order to validate that the playbook works as intended without running across the entire inventory for the end-state group.

### Test group configuration scenarios

The __inventory test group(s)__ should seek to adequately span all the major variations that are expected in the end-state inventory.

E.g., Say the linux hosts that are to have ntp configured for the following scenarios:
1) Two datacenter sites. E.g., `DFW` and `MEM`
2) Two networks exist at each site. E.g., internal (`INT`) vs external (`DMZ`).

To further illustrate, the ntp servers for each of the 4 settings:
1) site `DFW`, network `internal` has ntp server host `ntp.dfw.example.int`
2) site `DFW`, network `DMZ` has ntp server host `ntp.dfw.example.dmz`
3) site `MEM`, network `internal` has ntp server host `ntp.mem.example.int`
4) site `MEM`, network `DMZ` has ntp server host `ntp.mem.example.dmz`

Assuming hosts can exist in any of these 4 settings and require the respective ntp-server to be configured, then there would be 4 configuration scenarios that ideally would be under test and reflected in the test group host configuration.

The benefit of testing each of the four configuration settings will allow validation that the ansible environment works successfully for each.
This can be very helpful to resolve possible setting-specific issues that may/can occur (E.g., firewall settings, site-specific settings, etc).
