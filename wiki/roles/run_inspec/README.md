```markdown
---
title: Run InSpec Ansible Role Documentation
original_path: roles/run_inspec/README.md
category: Ansible Roles
tags: [inspec, ansible, aws, vmware]
---

# run_inspec

An Ansible role to execute multiple InSpec scans simultaneously against an Ansible group.

## Setup

Before you start, ensure that InSpec is installed on the Ansible control node.

### VMware vSphere

No specific setup instructions are provided for VMware vSphere. Ensure your environment is configured accordingly.

### AWS

Before you start, make sure:

- You have AWS CLI configured locally to access your desired AWS account.
- The `aws_ec2` plugin is enabled in your `ansible.cfg` file (usually located at `/etc/ansible/ansible.cfg`).

  ```yaml
  [inventory]
  enable_plugins = aws_ec2
  ```

- You have a group of EC2 instances in AWS that are:
  - Accessible via a single SSH key.
  - Tagged uniquely to target with Ansible (e.g., 'test_group').

### `aws_ec2` Plugin

The role runs on your localhost and loops through the inventory list provided by `aws_ec2`.

The `aws_ec2` plugin groups EC2 instances based on what you specify in the `groups` attribute in `aws_ec2.yml`:

```yaml
groups:
  test_group: "'test' in tags['Name']"
```

You can edit `aws_ec2.yml` to create different groups in the Ansible inventory using any tag of your choice.

To view how `aws_ec2` organizes and groups instances, run:

```bash
$ ansible-inventory -i aws_ec2.yml --graph
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

## Running the Role

Run the following command to execute the role:

```bash
ansible-playbook playbook.yml -i aws_ec2.yml --ask-vault-pass -v
```

You will be prompted for the password set for Ansible Vault. The task will run InSpec against the EC2 instances that are part of `test_group`.

The task uses Ansible's [asynchronous feature](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html) to execute all scans simultaneously. This means Ansible will initiate each scan in the loop without waiting for a result before moving on.

Subsequently, the next task in the role will wait until each asynchronous InSpec scan registered under `inspec_results` has completed before continuing.

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [InSpec Documentation](https://www.inspec.io/docs/)
```

This improved version maintains all original information while adhering to clean, professional Markdown standards suitable for GitHub rendering.