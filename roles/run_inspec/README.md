# run_inspec

Ansible role to execute multiple InSpec scans simultaneously against an ansible group.

## Setup

Before you start, make sure inspec is installed on the ansible control node.

### VMware vSphere

### AWS
Before you start, make sure:
- You have AWS CLI configured locally to access your desired AWS account.
- You have aws_ec2 plugin enabled in ansible.cfg (usually in /etc/ansible/ansible.cfg).
```yaml
[inventory]
enable_plugins = aws_ec2
```
- You have a group of EC2s in AWS which are:
    - accessible via a single SSH key
    - tagged with something unique to target with Ansible (ex. 'test_group')

### aws_ec2 plugin

The role runs on your localhost and loops through the inventory list given by aws_ec2.

`aws_ec2` groups EC2s depending on what you specify in the `groups` attribute in `aws_ec2.yml`:
```
groups:
  test_group: "'test' in tags['Name']"
``` 

You can edit `aws_ec2.yml` to create different groups in the Ansible inventory by whatever tag you like.

You can see what aws_ec2 can see and how it is grouped by running:
```
$> ansible-inventory -i aws_ec2.yml --graph

@all:
  |--@aws_ec2:
  |  |--ec2-3-145-176-61.us-east-2.compute.amazonaws.com
  |  |--ec2-3-15-31-155.us-east-2.compute.amazonaws.com
  |--@test_group:
  |  |--ec2-3-145-176-61.us-east-2.compute.amazonaws.com
  |  |--ec2-3-15-31-155.us-east-2.compute.amazonaws.com
  |--@ungrouped:
```

## Running the role

Run:
`ansible-playbook playbook.yml -i aws_ec2.yml --ask-vault-pass -v`

You'll be prompted for the password you set for the Ansible Vault. The task will run InSpec against the EC2s that are part of `test_group`. 

The task will execute all the scans simultaneously using Ansible's [asynchronous feature](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html). This means Ansible will execute each scan in the loop and not wait for a result before moving on.

As such, the next task in the role will wait until each asynchronous InSpec scan registered to `inspec_results` has completed before continuing.
