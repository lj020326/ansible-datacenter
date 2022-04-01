
Ansible Best Practices
====

Ansible makes simple things simple, but the more complex things might leave you scratching your head when starting your journey with Ansible. Here’s some pointers that might help you dodge some of those things.

For the basics of yaml best practices, the Ansible [documentation](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html) has [the](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) [needed](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html#working-with-playbooks) [information](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#playbooks-reuse-roles). The docs also contain a [best practices section](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#best-practice).

We have quite a bit of ground to cover, so let’s go!

## Getting started

As mentioned in the first part of this blog, you can install Ansible with [pip](https://packaging.python.org/key_projects/#pip) which means you can also control the version pretty well. Python environments can get [messy](https://xkcd.com/1987/) though, so if possible, utilize [pyenv](https://github.com/pyenv/pyenv) and [virtualenv](https://virtualenv.pypa.io/en/latest/) or control your tool versions by other means. I’ve lately taken an approach where I write a wrapper and a Dockerfile to keep the tooling consistent across people’s laptops and CI/CD. It works pretty well. [Visual Studio Code’s Remote Containers](https://code.visualstudio.com/docs/remote/containers) extension is also handy.

The package managers, like apt and yum can be used as well, but then you’re stuck with whatever version is in the distro repositories. Try to get at least version 2.8. 2.7 is now _end-of-life_ as 2.10 is released and you’d be missing on the critical bug fixes and lots of new things. The versions before 2.7 are desperately out-of-date. A massive amount of new stuff has been introduced after [RedHat](https://www.redhat.com/en/about/press-releases/red-hat-acquire-it-automation-and-devops-leader-ansible) acquired the project in 2015.

## Handling dependencies

Store your Ansible playbooks, roles, modules and plugins in version control. This includes any third party dependency roles you pull in with [ansible-galaxy](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html). Otherwise, Ansible will happily use any versions it finds in the [roles\_path](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-roles-path). Which may or may not be the one you have specified in the [requirements.yml](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-roles-and-collections-from-the-same-requirements-yml-file)!

However, this may lead to duplication if you run multiple Ansible projects on the same box, and they depend on the same roles. Tread carefully, as dependency hell is a real concern in this case as well. My main point here is that you should think about how you handle the dependencies. It is infrastructure as code, after all, so many of the things you need to think of with actual _code-code_ apply now to your infrastructure as well. But, you get the same benefits too!

The role dependencies can also be specified in the [meta/main.yml](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#role-dependencies) of the role, but that leads to execution order and variable precedence confusion as those roles are automatically imported during playbook runs. It’s better to make the imports explicitly with [import\_role](https://docs.ansible.com/ansible/latest/modules/import_role_module.html).

### Ansible Galaxy

The [Ansible Galaxy](https://galaxy.ansible.com/) dependency tool works similarly to `pip`, so if you have experience with that you’ll know some of the pain points. It pulls the specified roles directly from version control, GitHub most often. You really want to set those specific versions to use, as the master branch might include changes that break your infrastructure.

If a maintainer decides to delete their repository altogether, you’re pretty much out luck, unless you have a copy stashed somewhere. As mentioned above, storing the dependencies in the same repository as your infrastructure code helps with this.

Now that [Ansible Collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html) are getting traction the importance of managing dependencies and their versions is becoming even more significant as you’ll handle modules and plugins in the same manner.

## Project organization

The directory structure of an Ansible project is somewhat flexible. This is mostly determined by the plugin doing the reading of variables and inventories. If you’re just starting, you’ll most likely be using the default, so check the [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#directory-layout).

Commonly you see a directory for roles, some playbooks, an inventory and directories for variables:

```
├── ansible.cfg
├── group_vars
│   ├── all
│   │   └── our-vault-secrets.yml
│   └── webservers
│       └── apache-configs.yml
├── inventory.ini
├── master-playbook.yml
├── playbook.yml
├── requirements.yml
├── roles
│   ├── apache
│   │   ├── handlers
│   │   │   └── main.yml
│   │   └── tasks
│   │       ├── configure.yml
│   │       ├── install.yml
│   │       ├── main.yml
│   │       └── service.yml
│   ├── example
│   │   └── tasks
│   │       └── main.yml
│   └── yet-another
│       └── tasks
│           └── main.yml
└── webservers.yml
```

As there are as many needs for content and project organization in the world, as there are organizations using Ansible, I can’t give you a ruleset that would apply to everything. Just try to keep it simple. In the future, you will still need to find things in your stack of Ansible playbooks, roles, inventories and variable files, so the simpler it is, the better.

### Inventory management

Depending on your environment, it might be helpful to move inventories into a separate directory along with their respective `group_vars`. You can also run with [multiple inventories](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#using-multiple-inventory-sources) if need be.

Use dynamic inventories where it makes sense. Either the environment is dynamic, or you already have a system that manages your inventory of servers and equipment. However, static inventories in INI or YAML format are totally fine. INI is a bit simpler to read but does not work as well as YAML for the [variables](https://docs.ansible.com/ansible/latest/plugins/inventory/ini.html#notes). But you should keep your variables out of the static inventory in any case. We’ll discuss organizing the variables more in-depth later.

## Diving into the implementation

Starting by writing playbooks to accomplish things is a fast way to start. But be sure to move to roles pretty quickly. Roles bring advantages such as modularity and reusability. Roles can be tested in isolation. Roles are also more easily moved between environments. However, this has changed a bit with the introduction of Ansible Collections. Roles are similar to [Terraform modules](https://www.terraform.io/docs/modules/index.html), or you can think of them as a class or library.

### Benefits of roles

They act as a sort of abstraction layer and will help you in keeping things organized. If a playbook is the command “`apt-get install apache2”`, then the role is the .deb package itself.

Continuing this analogue for managing a web server, imagine a role called `apache`, it manages all things related to it:

-   repository setup
    
-   installation
    
-   configuration file creation
    
-   service startup
    
-   restarting during changes
    

Actual usage is through a playbook called `webservers.yml`, which imports the `apache` role to handle the things above.

We want HTTPS, so let’s make that happen by using a role called `letsencrypt` to fetch a certificate for Apache to use. Firewall rules could be managed with a role called `iptables` to allow HTTP and HTTPS traffic through to the webserver.

Now we have three roles, which come together in one playbook to manage our webservers. The roles are not directly dependent on each other, so `iptables` may well be used for opening ports for the SQL servers and `letsencrypt` can fetch certificates for HAProxy as well.

Reusability for the win!

When using roles from playbooks, use the `import_role` or `include_role` task rather than the older `roles` keyword. The latter will make it painful to handle the order of execution of roles with other tasks such as `set_fact` which you’ll likely have despite having already implemented everything in roles. You’ll also want to keep roles loosely coupled and limit the dependencies from one role to another. Playbooks can be used to pull in many roles to accomplish a whole.

A role should be kept as simple as possible and concentrate on one thing. For a generic role like the above `apache`, follow [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration). You don’t want to expose each and every configuration knob of Apache to the users of your role.

Especially when developing some in-house solution for managing a fleet of servers, you probably have conventions already. Just use Ansible to enforce them rather than creating a hard to manage blob of entangled variables. Automation should make your life easier, not harder. Set sane defaults for the role, as it should be usable without setting any of the variables.

### Selecting third party roles

You might be tempted in the start to pull in lots of third party roles with `ansible-galaxy`, especially if managing a piece of software that you don’t really know by heart. But the quality of available roles is a bit inconsistent. The ratings and download numbers in [Ansible Galaxy](https://galaxy.ansible.com/search?deprecated=false&keywords=&order_by=-download_count&page=1) give some indication, but it’s important to dig a little deeper before chucking a role in the `requirements.yml`. Some of the published roles may work well for their creators but follow conventions that don’t work for you.

For example, an otherwise well-written role that only has one task file `main.yml` is difficult to modify if you want to change the ordering of the tasks. For some added help, Jeff Geerling has [written a post](https://www.jeffgeerling.com/blog/2019/how-evaluate-community-ansible-roles-your-playbooks) on evaluating the community roles.

### Playbooks: includes, imports and tags

Playbooks can be arranged in a variety of ways. They can be group-related, for example, the `webservers.yml` above or lifecycle-related `restart-apache.yml` or for specific situations like `fix-heartbleed.yml`.

With the last one running some one-off tasks that help you ensure that a certain OpenSSL version is deployed across all of the servers. Some might argue that tags can be used for the same effect, but I think having a playbook for an occasion is much clearer.

Tags become hard to manage, especially when used in abundance inside roles. Tags in the role tasks combined with [dynamic includes or static imports](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html#tag-inheritance) lead to hard to grok flows and if using third party roles, you need to start using [include with apply](https://docs.ansible.com/ansible/latest/modules/include_role_module.html#parameter-apply) and it’s just going to end in tears. 

Create explicit playbooks and roles with explicit and separated task files and keep your sanity for the years to come. Grouping sets of tasks inside a role to separate task files adds reusability too. You can execute a set of tasks multiple times with different variables.

As an example, here’s a task file from the `iptables` role used in a few different ways:

```
# roles/example-iptables/tasks/rules.yml
- name: Create iptables rules
  become: true
  iptables:
    comment: "{{ item.comment | default(omit) }}"
    action: "{{ item.action | default(omit) }}"
    rule_num: "{{ item.rule_num | default(omit) }}"
    table: "{{ item.table | default(omit) }}"
    chain: "{{ item.chain | default(omit) }}"
    source: "{{ item.source | default(omit) }}"
...
    protocol: "{{ item.protocol | default(omit) }}"
    match: "{{ item.match | default(omit) }}"
    jump: "{{ item.jump | default(omit) }}"
    policy: "{{ item.policy | default(omit) }}"
  loop: "{{ iptables_rules }}"
  notify: iptables save
```

By default, in the role’s `main.yml` it could install necessary packages, flush some chains and set rules that you don’t want to be overwritten via the task file.

```
- hosts: all
  tasks:
    - name: Install iptables and configure defaults
      import_role:
        name: example-iptables
      vars:
        iptables_rules: "{{ example_default_iptables_rules }}"
---
- hosts: webservers
  tasks:
    - name: Create iptables rules for HTTP
      include_role:
        name: example-iptables
        tasks_from: rules
      vars:
        iptables_rules:
          - chain: INPUT
            protocol: tcp
            destination_port: 80
            jump: ACCEPT
            comment: Accept HTTP
          - chain: INPUT
            protocol: tcp
            destination_port: 443
            jump: ACCEPT
            comment: Accept HTTPS
```

## It’s all in the variables

Variables are essentially global in Ansible. There’s some scoping involved, but mostly you can treat them as such. Variables are also one of the more difficult things to get right. They seem simple enough in the start, but looking at the fairly lengthy documentation on the [matter](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#using-variables), you’ll notice that they might get complicated at some point.

Out of some experience, the variables are simpler than Chef’s attributes and its two-pass execution model, so for the most part, everything is alright. :)

I suggest to namespace your variables. In short, using the same “`version”` variable in both the package version in `apache` role and the OpenSSL version in `fix-heartbleed.yml` set in `group_vars` won’t work.

If mixing and matching third party roles with your own custom ones, adding a company name or some other known prefix will also help distinguish them. `example_apache_package_version` albeit longer, is clearer at a glance than `apache_version`. At the very least, use this latter version. No pun intended.

For [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) encrypted variables, it’s helpful to add a prefix or suffix to identify where the actual value is coming from. So, if a role has an input variable called “`mysql_root_password”`, you’ll want to encrypt and store it as “`vault_mysql_root_password”`.

Then, pass that in among other related variables:

```
mysql_package_version: "5.7.31-0ubuntu0.18.04.1"
mysql_config_file: /etc/mysql/our-special-config.cnf
mysql_root_password: "{{ vault_mysql_root_password }}"
```

### Where to put the variables?

There are various places where you can specify a variable and the list of [variable precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) is pretty long. Try to keep it simple and avoid excessive use of places high in the precedence list.

In other words, don’t spread the variables everywhere. Their end values are hard to debug as it is. Stick to a selected few and only stray from these places when necessary.

I usually try to keep to these (in rising order of precedence):

1.  defaults/ in a role
    
    1.  Read without special tasks automatically
        
    2.  A good place to document the input variables of the role with sane default values
        
2.  group\_vars/
    
    1.  The usual suspect when finding out what a variable’s value is in any given environment and group of servers
        
    2.  Using host\_vars/ only if really necessary
        
3.  vars: set to a task
    
    1.  Mostly for dynamic includes, when calling same include\_task / include\_role multiple times with varying input
        
    2.  Also useful for clarity’s sake on the `template` module, to pass some modified variables to the template file while keeping most of the logic outside of the template
        
4.  set\_fact:
    
    1.  For more dynamic things / variable definitions gathered during runtime
        
    2.  For example a `json_query` on some environment variable that is in the “wrong” format
        

## Writing tasks

Tasks should not be left without a name. This is mostly due to the way the default output of Ansible works. When running `ansible-playbook` you’ll be reading many of these lines, so it’s good that they tell what they are doing. There are some exceptions: `include_role`, `include_tasks` and their import equivalents are usually clear enough in implementation as well as output.

Consider this playbook:

```
- hosts: webservers
  tasks:
    - package:
        name: apache2
```

When reading the task implementation, you can naturally deduce what it is about, even without the task name, but its output is not clear at all:

```
TASK [package] *****************************************************************
changed: [example]
```

Looking at that, you would have no clue what package was managed without turning on an excessive amount of debugging.

Compare it to this:

```
- hosts: webservers
  tasks:
    - name: Install Apache
      package:
        name: apache2
```

```
TASK [Install Apache] **********************************************************
changed: [example]
```

Moving a step further and separating the above tasks to a role with some modifiable variables:

```
roles/apache/
├── defaults
│   └── main.yml
└── tasks
    ├── install.yml
    └── main.yml

```

```
# roles/apache/tasks/install.yml
- name: install | Ensure package state
  package:
    name: "{{ example_apache_package_name }}"
    state: "{{ example_apache_package_state }}"
```

```
TASK [include_role : apache] ***************************************************

TASK [apache : install | Ensure package state] *********************************
changed: [example]
```

Now, in the above, you see the role that is implementing the task. By adding a short prefix, you see the task file name `install` and the task itself which indeed handles the state of the package.

What’s missing from the examples above, is the use of `become`. Become is your sudo-equivalent, but works cross-platform. It is used to specify tasks that need to be run with administrative privileges. A pretty common thing, considering that you usually install, configure and start services with Ansible.

I tend to set `become` explicitly on each task that requires it. That’s clearer, documents the tasks that require root access, doesn’t make the user use `--become` on the command line or a more global `“become”` in the playbooks.

It’s a bit tedious, I admit, but worth it when the security team starts asking why everything is running as root.

### Back to the variables

Additionally, through the use of variables in the task, you suddenly have a distributable role for Apache that can install the correct package on both Debian and RedHat based systems as their package names differ. It can also remove the package by specifying an `“absent”` state for the package.

So, very quickly we have gone from a single-use playbook to a role that is backwards compatible and reusable!

Remember to provide sane defaults for the variables of your role. `example_apache_package_state` would naturally be `present` and the operating system-specific things could be handled through the `vars/` subdirectory and including a file based on a gathered fact:

```
# roles/apache/tasks/variables.yml
- name: variables | Read distribution-specific vars
  include_vars: "{{ ansible_distribution }}.yml"
```

Note that, `include_vars` makes it impossible for the user of your role to override the variable by specifying it “in the normal way”, ie. in `group_vars`, as `include_vars` take precedence. This may lead to some confusion and added complexity to variable handling. For the package name in distribution specific variables, `include_vars` would probably be fine, but the state is something you want the role’s end user to easily control.

The variables themselves should usually be one-dimensional. Ansible supports lists and dictionaries, but deeply nested variables might become problematic. If your configuration is a `dict`, and you want to change one value you have to replace the whole thing. The [hash\_behaviour](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-hash-behaviour) configuration option also affects how `dicts` are handled. By default Ansible will override previous values with any preceding ones it finds.

An example on the lists, when your `group_vars/all/monitoring.yml` specifies things to monitor:

```
example_monitoring_metricbeat_modules:
  - module: apache
    metricsets:
      - status
    period: 1s
    hosts:
      - http://127.0.0.1/
  - module: mysql
    metricsets:
      - status
    period: 2s
    hosts:
      - root@tcp(127.0.0.1:3306)/
```

If for one host or group you need to replace the port number for MySQL, you need to define the entire `example_monitoring_metricbeat_module` again. Also the part involving Apache!

The way to go about this would be to use variables inside variables. Like so:

```
- module: mysql
  metricsets:
    - status
  period: 2s
  hosts:
    - "root@tcp((127.0.0.1:{{ example_monitoring_mysql_port }})/”
```

Which will work until you need to add a whole module in the list of modules to monitor with Metricbeat.

But the benefit from one `dict`, in this case, would be the fact that Metricbeat’s own configuration is [YAML](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration.html) so you can just drop that variable to a filter `{{ example_monitoring_metricbeat_modules | to_nice_yaml }}` and be happy.

So it’s important to find a balance between ease of configuration and ease of variable management.

### Filters

If you choose to go for a multi-dimensional variable, instead of a simpler one, try to go with lists instead of dicts. Most filters and looping just seem to work better with lists.

Speaking of filters, be sure to learn [json\_query](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#json-query-filter). It’s very helpful for modifying data structures to match various module inputs.

As an example, let’s gather all our SQL clients from groups for the `iptables` role:

```
- name: Set iptables rules for SQL clients
  set_fact:
    sql_client_rules: >
      {{ groups.backend | map('extract', hostvars)
         | list | json_query(get_sql_clients) }}
  vars:
    get_sql_clients: >
      [?backend_is_sql_client].{
        comment: join(' ', ['Allow SQL traffic from', inventory_hostname]),
        protocol: 'tcp'
        source: ansible_host,
        destination_port: '3306',
        jump: 'ACCEPT',
        chain: 'INPUT'
      }

- include_role:
    name: example-iptables
    tasks_from: rules
  vars:
    iptables_rules: "{{ sql_client_rules }}"
```

The example is a bit roundabout, but basically just retrieves `hostvars` of all backend servers, selects the ones that use SQL and grabs the needed variables: inventory\_hostname and ansible\_host, and then makes a nice comment string with the jmespath [join()](https://jmespath.org/specification.html#join) [function](https://jmespath.org/specification.html#built-in-functions). You could achieve the same with some other tasks, but I like `json_query` for its power in manipulating data.

If a host is a member of many groups it becomes increasingly difficult to manage the variables. Groups will be handled alphabetically, so unless you want to start prefixing your group names with numbers to handle ordering, you can use [ansible\_group\_priority](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#how-variables-are-merged).

But usually, the correct choice in these cases is to refactor the variables so that you don’t have to worry about merging orders. Michael DeHaan, the original developer of Ansible, has [answered](https://groups.google.com/g/ansible-project/c/ycLMEb5lNJ4/m/eJqvXIBWQJkJ) a related question years ago and suggested to move a list of packages to a role and to use a play to bind a group to a role.

Keep it simple!

### Handlers

As stated earlier, in the role playbooks and roles section, writing explicit and separated task files make the role easier to reuse. Including parts of a role is a powerful tool, and you can use it in handlers too. Handlers are something that trigger when something else has changed, based on a [notify](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#handlers-running-operations-on-change).

Let’s say, you have a service restart and you also want to wait for that service to come up after a restart.

Create a restart.yml task file, include it in the handler! Now this task file could also be used in a “restart-services.yml” playbook.

Here’s an example:

```
# roles/apache/tasks/restart.yml
- name: Restart webserver
  service:
    name: httpd
    state: restarted

- name: Wait for webserver to start
  wait_for:
    port: 80
    delay: 10

```

```
# roles/apache/handlers/main.yml
- name: restart apache
  include_tasks: restart.yml
```


### When to not use 'when:' and avoiding task repetitions

Say you have the need to run a task but an input parameter to task may vary from one type to another.

Here’s a very simple example to illustrate the scenario:

```yaml
  - name: Do something here
    when: type == 'flavorA'
    some_task_here:
      input: A

  - name: Do something here
    when: type == 'flavorB'
    some_task_here:
      input: B
    
  - name: Do something here
    when: type == 'flavorC'
    some_task_here:
      input: C

  - name: Do something here
    when: type == 'flavorD'
    some_task_here:
      input: D

```

This occurs quite frequently in many playbooks and introduces the repitition of the task for each case of 'flavor' in this case.
The multiple repetitions can become especially problematic whenever a change necessitates propagation to all. 

A simple but useful technique to avoid this is by using group vars.

First, make sure the target host is set to the group.
This usually is done by adding the relationship in the inventory hosts file like so.

```ini
[flavorA]
host01

[flavorB]
host02

[flavorC]
host03

[flavorD]
host04

```

Then setup the needed variable(s) as group vars for each flavor as a group.

* group_vars/flavorA.yml:
    ```yml
    ---
    flavor: A
    ```

* group_vars/flavorB.yml:
    ```yml
    ---
    flavor: B
    ```

* group_vars/flavorC.yml:
    ```yml
    ---
    flavor: C
    ```

* group_vars/flavorD.yml:
    ```yml
    ---
    flavor: D
    ```

Now the task can be rewritten as simply:

```yaml
  - name: Do something here
    some_task_here:
      input: "{{ flavor }}"
```

This eliminates the need for the multiple when statements and makes the task far more manageable, readable, enhanceable, and supportable.
This also highlights the power of using groups in ansible. 

To see groups used in a more realistic way, see [the inventory example here](inventory-pets-vs-cattle.md).


### Modules

Always go for Ansible modules, ie. use available tasks rather than “command” or “shell”. Mostly it’s because the modules are idempotent out of the box. Sometimes you can’t avoid doing things without running a command in a separate shell, but for the most part Ansible will have the module for you.

By the way, starting from 2.10 the documentation references to the builtin modules with the [Fully Qualified Collection Name (FQCN)](https://github.com/ansible-collections/overview#terminology), so service above would be ansible.builtin.service in the docs.

You can also [write your own modules](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html) pretty easily and distribute them via a collection.

Additionally, if you have grown accustomed to checking out the [main Ansible repository](https://github.com/ansible/ansible) for implementation details, check [the collections organization](https://github.com/ansible-collections) on GitHub.

## Syntax and YAML

YAML is more complex than it first seems. I’m not going to concentrate on all of the fiddly bits here, there’s more than enough other sources available.

For example, there are tricks like anchors in YAML to avoid repeating yourself, but don’t do that. Ansible has enough methods to help with that.

Basically, write Ansible, not YAML.

Ansible allows for specifying most things as inline strings, instead of passing keys and values to a task. Don’t do that either! :) Syntax highlighting of your editor won’t work, it’s hard to read and diffs from the version control become harder to understand.

Concentrate on readability, the playbooks and roles will become the documentation of your infrastructure. An empty line and a comment here or there helps a lot.

Remember that strings can have multiple different notations in YAML. One without quotes is as functional as the one with quotes. Often, the latter is required in Ansible due to it holding Jinja2 templating denoted by the curly braces. As said in the first part of the series, the integers sometimes cause confusion.

Booleans can also be expressed in many ways, you might see “yes” instead of “true” in some places. Both are syntactically correct, but you should stick to one for clarity. And when I say stick to one, I mean use “true” instead of “yes”.

It’s worthwhile to hone your indentation skills as it is significant in making Ansible understand what you mean. Take note of the difference between a dictionary, which holds key and value pairs and a list which holds one or many objects of varying types.

## Testing your infrastructure

Your infrastructure deserves tests too. We’re trying our best to treat it as code. As with any code, you’ll want to lint it as readability is essential. Tools like [yamllint](https://github.com/adrienverge/yamllint) and [ansible-lint](https://github.com/ansible/ansible-lint) can be plugged into your CI pipeline very easily.

Linters also catch things like repeated keys in your YAML. This is a problem that isn’t that easy to spot otherwise. If you accidentally specify a task parameter twice, only the latter is used.

Using roles instead of bare playbooks really helps with the testing of functionality. It’s a bit of a stretch to call these unit tests, but [Molecule](https://molecule.readthedocs.io/en/latest/) has been designed to converge a role with a certain set of inputs and you can verify the result.

It used to have [Testinfra](https://testinfra.readthedocs.io/) as the default verifier, but starting from 3.0 it uses Ansible to do that. It also uses Ansible to do the provisioning of containers for testing.

At first glance, it may seem a bit redundant to first say “install package foo” and then verify that package “foo” is indeed installed. But this lets you catch regressions easily during role development.

And in the case of a role that supports multiple operating systems, it’s straightforward to run converges for multiple systems. This sort of testing is vital if you plan to publish your role in the Galaxy as you’ll otherwise have trouble to replicate all the user environments.

Molecule is very oriented to testing roles in isolation, which also drives you towards writing that sort of thing. It’s a beneficial approach as I’ve stated many times, but sometimes you want to test a whole playbook. [Test Kitchen](https://kitchen.ci/), which originates from the [Chef](https://docs.chef.io/workstation/kitchen/) world, is also usable with Ansible through a [provisioner](https://github.com/neillturner/kitchen-ansible). Both let you create containers and virtual machines for testing. They have a plugin architecture, so community drivers are available if the defaults do not suit your needs.

For runtime testing, Ansible has a built-in [assert](https://docs.ansible.com/ansible/latest/modules/assert_module.html) task. It helps especially when the input variables come from an external system which you don’t necessarily trust. You can also use assert in a role, to be sure that the user has set up things properly. Assert is nice, but may become too limited quickly. An interesting approach would be to use [JSON Schema](https://json-schema.org/) to implement a custom module that validates the inputs against a specified schema.

## Conclusion

Phew, that’s it!

Hopefully, there was a thing or two that helps you. Either when starting out or if you’ve already hit a situation where your infrastructure automation package is becoming a bit hard to manage.

**TL;DR:**

1.  Use descriptive names and concentrate on the readability of your playbooks and roles
    
2.  Divide your implementation into roles and make them work independently with sane defaults
    
3.  Aim for reusability through roles and separated task files
    
4.  Don’t over-use tags
    
5.  Prefer explicit to implicit, in imports and the use of become
    
6.  Think about how you handle dependencies
    
7.  Ensure third party role quality before pulling it in as a dependency
    
8.  Organize your playbooks in a meaningful way
    
9.  Try to limit the precedence levels in your variables and keep them simple
    
10.  Test your playbooks and roles