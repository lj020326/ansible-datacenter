
# AWX git-based Inventory Deployment Strategy

## Prerequisite

The following sections assume that we will use the convention/method as described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md) to manage multi-stage inventory deployments into an AWX inventory.

## Setup test inventory repo

Assuming you have an inventory according to the method described in the article on [How to manage multistage environments with ansible](./how-to-manage-multistage-environments-with-ansible.md), the following sections will demonstrate how to use git release branch based deployment for inventory group configuraiton variables.

### Clone demo/test inventory

First clone the demo/test inventory repo [here]().

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
            source_path: "DEV"
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
            source_path: "QA"
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
            source_path: "PROD"
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








