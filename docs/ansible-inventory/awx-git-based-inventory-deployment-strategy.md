
# AWX git-based Inventory Deployment Strategy

## Prerequisite

The following sections assume that we will use the convention/method as described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md) to manage multi-stage inventory deployments into an AWX inventory.

## Setup test inventory repo

Assuming you have an inventory according to the method described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md), the following sections will demonstrate how to use git release branch based deployment for inventory group configuraiton variables.

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

The "Root" inventory should only be used for inventory monitoring/surveillance purposes and not for management/ change / impactful plays since each environment should only be managed/changed within the scope of the environment.

