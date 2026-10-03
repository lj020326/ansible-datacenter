---
title: run_inspec
original_path: roles/run_inspec/README.md
category: Ansible Roles
tags:
  - InSpec
  - Ansible
  - AWS
  - VMware vSphere
harvested_date: '2026-08-07T18:07:09.534030+00:00'
source_type: legacy_markdown
---

# run_inspec

An Ansible role to execute multiple InSpec scans simultaneously against an Ansible group.

## Introduction

InSpec is an open-source testing framework for infrastructure with a human- and machine-readable language to specify compliance, security, and policy requirements. This role allows you to run InSpec scans against multiple servers simultaneously.

## Setup

Before you start, ensure InSpec is installed on the Ansible control node.

### VMware vSphere

[Provide setup instructions for VMware vSphere here]

### AWS

Before you start, ensure the following:

- The AWS CLI is configured locally to access your desired AWS account.
- The `aws_ec2` plugin is enabled in `ansible.cfg` (usually located in `/etc/ansible/ansible.cfg`):

  ```yaml
  [inventory]
  enable_plugins = aws_ec2
  ```

- You have a group of EC2 instances in AWS that are:
  - Accessible via a single SSH key
  - Tagged with a unique identifier for targeting with Ansible (e.g., 'test_group')

### aws_ec2 Plugin

The role runs on your localhost and loops through the inventory list provided by the `aws_ec2` plugin.

The `aws_ec2` plugin groups EC2 instances based on the `groups` attribute specified in `aws_ec2.yml`:

```yaml
groups:
  test_group: "'test' in tags['Name']"
```

You can edit `aws_ec2.yml` to create different groups in the Ansible inventory based on your preferred tags.

To view the inventory and grouping as seen by `aws_ec2`, run:

```sh
$> ansible-inventory -i aws_ec2.yml --graph
```

Example output:

```
@all:
  |--@aws_ec2:
  |  |--ec2-3-145-176-61.us-east-2.compute.amazonaws.com
  |  |--ec2-3-15-31-155.us-east-2.compute.amazonaws.com
  |--@test_group:
  |  |--ec2-3-145-176-61.us-east-2.compute.amazonaws.com
  |  |--ec2-3-15-31-155.us-east-2.compute.amazonaws.com
  |--@ungrouped:
```

## Variables

[List and describe configurable variables here]

## Running the Role

To run the role, execute the following command:

```sh
ansible-playbook playbook.yml -i aws_ec2.yml --ask-vault-pass -v
```

You will be prompted for the password you set for the Ansible Vault. The task will run InSpec against the EC2 instances that are part of the `test_group`.

The task will execute all the scans simultaneously using Ansible's [asynchronous feature](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html). This means Ansible will execute each scan in the loop and not wait for a result before moving on.

The next task in the role will wait until each asynchronous InSpec scan registered to `inspec_results` has completed before continuing.

## Handling Results

[Explain how to handle and interpret the results of the InSpec scans]

## Examples

[Provide examples of using different InSpec profiles]

## Dependencies

- InSpec
- AWS CLI (for AWS setups)
- [List any other dependencies]

## Backlinks

[Add any relevant backlinks here]