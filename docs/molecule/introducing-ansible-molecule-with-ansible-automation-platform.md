
# Introducing Ansible Molecule with Ansible Automation Platform

Ansible Molecule is a tool designed to aid in developing and testing Ansible playbooks, roles, and collections. It provides support for functional testing of Ansible content across multiple instances, operating systems and distributions, virtualization providers, test frameworks, and testing scenarios. Molecule helps Ansible content creators ([automation](https://developers.redhat.com/topics/automation) specialists) consistently deliver automation content that is scalable, repeatable, and compatible with the latest Ansible versions.

Ansible Molecule 6 is now available as a [developer preview](https://access.redhat.com/support/offerings/devpreview) with [Red Hat Ansible Automation Platform](https://developers.redhat.com/products/ansible/overview). This version will refocus and redefine the project as a tool for testing Ansible content with Ansible Automation Platform.

The developer preview enables us to collect feedback from our users as we work towards making it an integral and supported part of the Ansible Automation Platform developer experience. This release is part of our broader strategy to reduce the learning curve required for IT professionals and Ansible specialists with little to no coding skills to build, test, and deploy their automation content.

**Note to current Molecule users:** If you are already familiar with the Molecule project and are using it to test your automation content, there might be breaking changes that will require updates to your test scenarios. Please see the conclusion section of this blog to find out how to provide feedback to us.

## An automation testing framework built for the enterprise

The latest Ansible Molecule developer preview is designed with Ansible Automation Platform and organizational level testing in mind. While it retains its core goal of providing a reliable way to make sure your automation is up to scratch, it's got some new tricks up its sleeve. Now, you can also test roles and playbooks within [Ansible Content Collections](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html), making it even easier to develop and validate your automation content.

This update comes thanks to valuable feedback from our community of Molecule users. We've listened and made Molecule more user-friendly, especially for those who create and specialize in Ansible automation.

Here's a rundown of what's new and improved.

## Testing framework for content inside Ansible Content Collections

Ansible Content Collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plug-ins. They are used to distribute reusable Ansible content, enabling users to share, version, and distribute the building blocks of their automation.

Recognizing the complexity and interdependence of today's automation tasks, we have extended the capabilities of Molecule to test not just individual roles and playbooks but entire collections. This enhancement is particularly significant as we prepare for a seamless integration of Molecule into the Ansible Automation Platform.

The integration with Ansible Automation Platform positions Molecule as a future-ready tool. More importantly, it aligns with a user-friendly strategy for content testing within the platform. This approach aims to simplify the user experience, enabling both customers and community users to conduct comprehensive tests on their automation content in a manner that is consistent with the Ansible Automation Platform.

## Keeping it simple with one driver

Ansible is now the default provisioner with this Molecule release. Molecule uses drivers as provisioners to create the infrastructure to run your tests on. Prior to the release of version 6, Molecule supported multiple drivers to provision testing instances using different technologies, including [Linux](https://developers.redhat.com/topics/linux/) containers, virtual machines, and cloud providers. By default, it came with three pre-installed drivers: Docker and Podman drivers to manage [containers](https://developers.redhat.com/topics/containers) and a delegated driver allowing you to customize your integration using Ansible. Drivers for other providers were available through the open source community.

The default and the only driver present with Ansible Molecule in Ansible Automation Platform is the delegated driver (aliased as "default" driver), which allows you to use Ansible itself to create and modify how Molecule provisions its test environments.

Ansible can automate various environments using the Ansible collections available through the community and Ansible Automation Platform. Because the delegated ("default") driver uses Ansible, we believe that it will help the adoption of Molecule as the testing framework for the enterprise.

Although using other drivers was a powerful approach that allowed customizations, this approach had its disadvantages. For instance, if you want to customize a driver's provisioning/de-provisioning mechanism, you will need to change the driver's source code, which means that you will need to go through the learning curve of writing Python code even if you are an Ansible playbook writer.

## Making the testinfra verifier optional

In the context of Ansible Molecule, a "verifier" is a component responsible for running tests against the infrastructure or instances created during the testing process. The verifier is used to validate whether the Ansible role or playbook being tested has successfully achieved the desired state on the test instances. The verifier you choose determines the testing framework and syntax you use to write your tests.

Ansible is a powerful verifier and has been made the default verifier with Molecule 6. Testinfra is another popular verifier with Molecule, which has been made optional with Molecule 6. The testinfra library requires Molecule users to be proficient with [Python](https://developers.redhat.com/topics/python), which limits its usability for many non-programmer IT practitioners. Making the Testinfra library optional with Molecule 6 is part of our efforts to refocus Molecule as a tool for functional testing of Ansible roles, collections, and playbooks using Ansible itself. Writing verifications can be done with native Ansible playbooks and tasks rather than using/learning a third-party tool with respect to Python.

What we mean by optional is that the testinfra Python library is not packaged as part of Molecule 6 for the downstream release. Rather, the testing "glue" is still available for testinfra in Molecule. For those IT practitioners who may be comfortable with Python and wish to use testinfra, it remains an installable option.

## Installing Molecule developer preview

Molecule is packaged as part of the Ansible Automation Platform. You can [download the bundled installer](https://developers.redhat.com/products/ansible/download) or [subscribe to the Ansible Automation Platform repos](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html/red_hat_ansible_automation_platform_planning_guide/proc-attaching-subscriptions_planning) to get access to the supported packages.

You can install Molecule using the following command:

```
dnf install \
--enablerepo=ansible-automation-platform-2.4-for-rhel-8-x86_64-rpms molecule
```

Copy snippet

## Getting started with Molecule developer preview

Let's take a look at how Molecule developer preview aligns more closely with Ansible content collection development and testing. All the examples here are available in the upstream Molecule [project documentation](https://ansible.readthedocs.io/projects/molecule/getting-started/).

1.  One of the recommended ways to create a collection is to place it under the `collections/ansible_collections` directory:
    
    ```
    ansible-galaxy collection init foo.bar
    ```
    
    Copy snippet
    
2.  Navigate to the `roles` directory in your new collection:
    
    ```
    cd <path to your collection>/foo.bar/roles/
    ```
    
    Copy snippet
    
3.  Initialize a new role for this collection:
    
    ```
    ansible-galaxy role init my_role
    ```
    
    Copy snippet
    
4.  Add a task under `my_role/tasks/main.yml`:
    
    ```
    ---
    - name: Task is running from within the role
      ansible.builtin.debug:
        msg: "This is a task from my_role."
    ```
    
    Copy snippet
    
5.  Add Molecule to the content collection:
    
    -   Create a new directory in your collection called `extensions`.
        
    -   `cd` to the new `extensions` directory:
        
        ```
        cd <path to your collection>/extensions/
        ```
        
        Copy snippet
        
6.  Initialize the default Molecule scenario:
    
    ```
    molecule init scenario
    ```
    
    Copy snippet
    
7.  Edit the `molecule.yml` file to use your local collection development environment as described. Add the following entry to your `<path_to_your_collection>/extensions/molecule/default/molecule.yml` file:
    
    ```
    provisioner:
      name: ansible
      config_options:
        defaults:
          collections_path: ${ANSIBLE_COLLECTIONS_PATH}
    ```
    
    Copy snippet
    
8.  Then, set the `ANSIBLE_COLLECTIONS_PATH` environment variable at the command line before running Molecule:
    
    ```
    export ANSIBLE_COLLECTIONS_PATH=/home/user/working/collections
    ```
    
    Copy snippet
    
    Note that the path should reflect the location up to the `collections` directory and not the `ansible_collections` directory.
    

## Molecule scenarios

Scenarios are the starting point for a lot of powerful functionality that Molecule offers. Think of a scenario as a test suite for roles or playbooks within a collection. You can have as many scenarios as you like, and Molecule will run them sequentially.

### The scenario layout

Within the `molecule/default` folder, we find several files:

```
$ ls
create.yml destroy.yml molecule.yml converge.yml
```

Copy snippet

-   `create.yml` is a playbook file used for creating the instances and storing data in `instance-config`.
-   `destroy.yml` has the Ansible code for destroying the instances and removing them from `instance-config`.
-   `molecule.yml` is the central configuration entry point for Molecule per scenario. With this file, you can configure each tool that Molecule will employ when testing your role.
-   `converge.yml` is the playbook file that contains the call for your role. Molecule will invoke this playbook with `ansible-playbook` and run it against an instance created by the driver.

### Inspecting the molecule.yml

The `molecule.yml` is for configuring Molecule. It is a [YAML](https://yaml.org/) file with keys that represent the high-level components that Molecule provides. These are:

-   **The [dependency](https://ansible.readthedocs.io/projects/molecule/configuration/#dependency) manager:** Molecule uses [galaxy development guide](https://docs.ansible.com/ansible/latest/galaxy/dev_guide.html) by default to resolve your role dependencies.
-   **The [platforms](https://ansible.readthedocs.io/projects/molecule/configuration/#platforms) definitions:** Molecule relies on this to know which instances to create and name and which group each instance belongs to. If you need to test your role against multiple popular distributions ([CentOS](https://developers.redhat.com/products/rhel/centos-and-rhel), Fedora, Debian, [Red Hat Enterprise Linux](https://developers.redhat.com/products/rhel/overview)), you can specify that in this section.
-   **The [provisioner](https://ansible.readthedocs.io/projects/molecule/configuration/#provisioner):** Molecule only provides an Ansible provisioner. Ansible manages the life cycle of the instance based on this configuration.
-   **The [scenario](https://ansible.readthedocs.io/projects/molecule/configuration/#scenario) definition:** Molecule relies on this configuration to control the scenario sequence order.
-   **The [verifier](https://ansible.readthedocs.io/projects/molecule/configuration/#verifier) framework:** Molecule uses Ansible by default to provide a way to write specific state-checking tests (such as deployment smoke tests) on the target instance.

### Running a full test sequence

Molecule provides commands to manually manage the lifecycle of the instance, scenario, development, and testing tools. However, we can also tell Molecule to manage this automatically within a scenario sequence.

`cd` to the extensions directory:

```
cd <path to your collection>/extensions/
```

Copy snippet

The full life cycle sequence can be invoked with `molecule test`:

```
Molecule full lifecycle sequence

└── default
├── dependency
├── cleanup
├── destroy
├── syntax
├── create
├── prepare
├── converge
├── idempotence
├── side_effect
├── verify
├── cleanup
└── destroy
```

Copy snippet

### Testing the collection role

One of the default files created as part of the initialization is the `converge.yml` file. This file is a playbook created to run your role from start to finish. This can be modified if needed, but is a good place to start if you have never used Molecule before.

You now have an isolated test environment and can also use it for live development by running `molecule converge`. It will run through the same steps as above but will stop after the `converge` action. Then, you can make changes to your collection or the converge play, and then run `molecule converge` again (and again) until you're done with your development work.

We can test the role by adding the following code to `converge.yml`:

```
---
- name: Include a role from a collection
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Testing role
      ansible.builtin.include_role:
        name: foo.bar.my_role
        tasks_from: main.yml
```

Copy snippet

`cd` to the extensions directory:

```
cd <path to your collection>/extensions/
```

Copy snippet

Run the following command:

```
molecule converge
```

Copy snippet

The above command runs the same steps as the molecule test for the default scenario but will stop after the converge action. This is beneficial if you want to keep the infrastructure up while you are doing your collections development work and testing.

## Conclusion

By introducing Ansible Molecule as a developer preview as part of an Ansible Automation Platform subscription, we are working towards ensuring the project is stable, supported, and maintainable in an enterprise environment.

If you have any questions or feedback on the changes, please reach out to the [Ansible Molecule project on Github](https://github.com/ansible/molecule/issues/new/choose). The project's maintainers will be happy to answer any questions on this topic.

As the project matures and evolves, we will keep you updated with more use cases for Ansible Molecule, including deep dives on testing with multiple operating systems, integrating Molecule with your [CI/CD](https://developers.redhat.com/topics/ci-cd/) pipelines, and more.

## Where to go next

-   [Molecule project documentation](https://ansible.readthedocs.io/projects/molecule/): Check out the detailed documentation on the upstream molecule project that has a lot of getting started use cases with Molecule.
-   [Get hands-on with on-demand Ansible Automation Platform self-paced exercises](https://developers.redhat.com/products/ansible/getting-started). We have a variety of interactive in-browser exercises to experience Ansible Automation Platform in action.
-   [Trial subscription](https://developers.redhat.com/products/ansible/download): Are you ready to install on-premises? Get your own trial subscription for unlimited access to all the components of Ansible Automation Platform.
-   [Subscribe](https://www.youtube.com/ansibleautomation) to the Red Hat Ansible Automation Platform YouTube channel.

_Last updated: September 19, 2023_

## Reference

- https://developers.redhat.com/articles/2023/09/13/introducing-ansible-molecule-ansible-automation-platform
- 