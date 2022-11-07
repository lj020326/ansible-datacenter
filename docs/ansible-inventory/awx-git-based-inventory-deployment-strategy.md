
# AWX Git-based Inventory Deployment Strategy

## Motivation

### AWX Inventory Environment Based approach to CICD based automation code testing/deployment 

Limiting the AWX/tower plays to specific environments works to enable a proper DEV/QA/PROD CICD git based PRs toolchain to:

1) enable validation testing to develop and validate any plays/roles/collections/modules before promoting to the upper environments.
2) enable integration testing in a QA environment to validate that any component/platform updates/upgrade/patches work as expected before applying to upper environment 
3) enable a QA environment for a full/robust set of "quality gate checks" upon PR request:
   1) runs lint based code quality checks
   2) run automated regression and new feature testing
4) Validate any inventory group-based configurations before applying to upper environment


## Prerequisite

The following sections assume that we will use the convention/method as described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md) to manage multi-stage inventory deployments into an AWX inventory.

## Setup test inventory repo

Assuming you have an inventory according to the method described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md), the following sections will demonstrate how to use git release branch based deployment for inventory group configuration variables.

### Clone demo/test inventory

First clone the demo/test inventory repo [here](https://github.com/lj020326/ansible-inventory-file-examples/tree/develop-lj/tests/ansible-multistage-environments).

Copy and commit the demo inventory directory to your AWX inventory repo.

Create a release branch.

Use the bootstrap-tower-resource role to apply the following AWX configuration setup for DEMO inventory projects for DEV, QA, and PROD as seen in the awx.yml.

awx.yml
```yaml
---

tower_resources:

  organizations:
    - name: "TEST - DEMO ORG"
      description: "demo org"
      state: present

      inventories:
        - name: "DEMO-INVENTORY-DEV"
          description: "Demo DEV inventory"
          state: present
          source:
            name: "DEMO-INVENTORY-DEV"
            description: Project Source for DEV Inventory
            source: scm
            source_path: "ENV_DEV"
            credential: git-tower-credential
            overwrite: True
            update_on_launch: True
        - name: "DEMO-INVENTORY-QA"
          description: "Demo QA inventory"
          state: present
          source:
            name: "DEMO-INVENTORY-QA"
            description: Project Source for QA Inventory
            source: scm
            source_path: "ENV_QA"
            credential: git-tower-credential
            overwrite: True
            update_on_launch: True
        - name: "DEMO-INVENTORY-PROD"
          description: "Demo PROD inventory"
          state: present
          source:
            name: "DEMO-INVENTORY-PROD"
            description: Project Source for PROD Inventory
            source: scm
            source_path: "ENV_PROD"
            credential: git-tower-credential
            overwrite: True
            update_on_launch: True

      projects:
        - name: "DEMO-INVENTORY-DEV"
          scm_url: https://github.com/userspace/demo-inventory-repo.git
          scm_type: git
          scm_branch: develop
        - name: "DEMO-INVENTORY-QA"
          scm_url: https://github.com/userspace/demo-inventory-repo.git
          scm_type: git
          scm_branch: release-2022-10-11
        - name: "DEMO-INVENTORY-PROD"
          scm_url: https://github.com/userspace/demo-inventory-repo.git
          scm_type: git
          scm_branch: master

```


## Git based commit to update the QA release branch

The update of a release branch into the QA inventory then can be done using a single git commit followed by re-running the bootstrap-tower-resource to apply the new release branch as the newly updated/defined QA inventory scm project branch.

## TODO: Demonstrate env agnostic groups and env specific groups

The remaining PoCs would then demonstrate how to enable a single set of env-agnostic groups such that the release branch configuration is exactly what gets tested in QA.

Upon successful validation testing, can then the release branch can be PR'd into the project inventory SCM master branch to then become the updated PROD configuration using the same exact env-agnostic group configurations.

To enable the env-agnostic groups, there will need to be a root/base dir that sets the env-agnostic groups mapped into each of the respective env directories via symbolic link.  

Then each env directory can have env-specific groups added to map to the specific set of hosts in the hosts.yml located in each of the env dirs.  

Note that each environment directory has its own hosts.yml to manage the environment specific set of hosts.

The root level 'all.yml' specifies all the env-agnostic groups that are available across all environments which gets symlinked into each of the environment directories.  

Using this approach, testing any group can be done with the same exact group configuration for all environments.  The specific hosts targeted by the groups are then specified in the env-specific 'hosts.yml' file. 

## Root Level Inventory Use Case

For supervisor level events that require a total view across environments, a 'root.yml', or  'all-envs.yml', can be created at the inventory root/base directory with a corresponding "Root" level AWX project inventory to composite each of the environments together but with the inventory directory set as the root.

Since each environment should be managed/changed within the scope of the environment, the "Root" inventory should only be used for limited use cases.

The root inventory should only apply to AWX 'job templates' that meet the following requirements and/or characteristics:

- The job is 'non-mutable' such that it does not make any change to any host target. 
  * inventory scans and related use-cases usually fit into this case.
  * company audits/compliance checks (e.g., info-security related)
- The job risk level is minimal such that it can run across multiple environments independent from CICD infosec/requirements
- The job must run across multiple environments for a specific reason/purpose. Jobs usually fitting this use case are:
  * migration related - e.g., job to migrate/synchronize configuration from env1 to env2
  * promotion related - e.g., job to promote configuration from env1 to env2
- provisioning new machines into lower environments 
  * Preferred/Better approach would be to perform this from the environment and not at the "Root" level

Basically, limit 'Root' inventory use cases, to the extent possible, to non-mutable plays.

