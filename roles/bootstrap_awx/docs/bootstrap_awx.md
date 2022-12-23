# AWX/Automation Controller Installation Instructions

How to install this AWX/Automation Controller setup.


## Provision a Server

Provision a Debian or Ubuntu server with >=8GB RAM and setup SSH access to the root account.


## Setup DNS entry for it:

Map an: 

A/AAAA record for panel.example.org to the servers IP.
A/AAAA record for rancher.example.org to the servers IP, 
    or a CNAME record for it pointing to panel.example.org.


## Install

1) Install the following ansible-galaxy packages on the controller:

```shell
$ ansible-galaxy collection install --force awx.awx:21.9.0
$ ansible-galaxy collection install community.crypto
```


2) Edit host into: [./tests/inventory/hosts](./tests/inventory/hosts)

Create folder for each host at: [./tests/inventory/hosts](./tests/inventory/hosts)

Record these variables into each host's vars.yml:

```yaml
# Your organisations name
bootstrap_awx_org_name: Example
# URL of the AWX instance.
bootstrap_awx_awx_url: awx.example.org
# AWX database password.
bootstrap_awx_pg_password: strong-password
# AWX admin user password.
bootstrap_awx_admin_password: strong-password
# AWX secrets password.
bootstrap_awx_secret_key: strong-password
# Time periods for schedules, eg: 
# 'MINUTELY', 'HOURLY', 'DAILY', 'WEEKLY','MONTHLY'
bootstrap_awx_update_schedule_frequency: 'WEEKLY'
# Number of hours/days/weeks to schedule updates too:
bootstrap_awx_update_schedule_interval: 4
# Project repository URL.
bootstrap_awx_deploy_source: https://github.com/PC-Admin/project-repository.git
# Branch of the project repository.
bootstrap_awx_deploy_branch: testing
# The organisations email for LetsEncrypt.
bootstrap_awx_certbot_email: michael@perthchat.org
```


3) Run the playbook with the following tags:

```shell
$ cd tests
$ ansible-playbook -v -i ./inventory/hosts bootstrap-awx.yml
```

Using tags to run specific actions:
```shell
$ cd tests
$ ansible-playbook -v -i ./inventory/hosts -t "setup,setup-firewall,master-token,configure-awx,setup-rancher" bootstrap-awx.yml
```


4) In AWX, set the base URL

Go into: Settings > Miscellaneous System Settings > Edit

Alter the value of 'Base URL of the Tower host' to your AWX systems URL.
