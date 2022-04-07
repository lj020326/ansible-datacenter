
Ansible Questions and Answers
---

A set of more experiential questions can be found [here](./ansible-experiential-questions.md)

[Basic-level Ansible Questions](#basic)

* [Q1. What are Ansible tasks?](#Q1)

* [Q2. Explain a few of the basic terminologies or concepts in Ansible](#Q2)

* [Q3. What is a playbook?](#Q3)

* [Q4. State the differences between variable names and environment variables](#Q4)

* [Q5. Where are tags used?](#Q5)

* [Q6. Which protocol does Ansible use to communicate with Linux and Windows?](#Q6)

* [Q7. What are ad hoc commands? Give an example](#Q7)

* [Q8. What is a YAML file and how do we use it in Ansible?](#Q8)

* [Q9. Code difference between JSON and YAML](#Q9)

[Intermediate-level Ansible Questions](#intermediate)

* [Q10. Explain modules in ansible.](#Q10)

* [Q11. What is Ansible-doc?](#Q11)

* [Q12. What is the code you need to write for accessing a variable value for a specific host?](#Q12)

* [Q13. What is a method to check the inventory vars defined for the host by using the ansible CLI?](#Q13)

* [Q14. Explain Ansible facts](#Q14)

* [Q15. Discuss the method to create an empty file with Ansible](#Q15)

* [Q16. Explain Ansible modules in detail](#Q16)

* [Q17. What are callback plug-ins in Ansible?](#Q17)

* [Q18. What is Ansible inventory and its types?](#Q18)

* [Q19. What is an Ansible vault?](#Q19)

* [Q20. How do we write an Ansible handler with multiple tasks?](#Q20)

* [Q21. How to generate encrypted passwords for a user module?](#Q21)

* [Q22. Explain the concept of blocks under Ansible?](#Q22)

* [Q23. Do you have any idea of how to turn off the facts in Ansible?](#Q23)

* [Q24. What are the registered variables under Ansible?](#Q24)

* [Q25. By default, the Ansible reboot module waits for how many seconds. Is there any way to increase it?](#Q25)

* [Q26. What do you understand by the term idempotent? Why is it important?](#Q26)

* [Q27. Can you copy files recursively onto a target host? If yes, how?](#Q27)

* [Q28. Can you keep data secret in the playbook?](#Q28)

* [Q29. Can docker modules be implemented in Ansible? If so, how can you use it?](#Q29)

* [Q30. How do you test Ansible projects?](#Q30)

* [Q31. What is the recommended method/practice to make ansible play content reusable/redistributable?](#Q31)

* [Q32. How do you see all variables for a host?](#Q32)

* [Q33. How to continue execution on failed task after fixing error in playbook?](#Q33)

* [Q34. How to define a task to fail only when the following 2 conditions exist in the registered task results:  (1) result is failed and (2) the pattern "ALREADY_ENABLED" is not found in result.msg?](#Q34)





# <a id="basic"></a>Basic-level Ansible Interview Questions


## <a id="Q1"></a>Q1. What are Ansible tasks?

The task is a unit action of Ansible. It helps by breaking a configuration policy into smaller files or blocks of code. These blocks can be used in automating a process. For example, to install a package or update a software:

```
Command: Install <package_name>

Command: update <software_name>

```

## <a id="Q2"></a>Q2. Explain a few of the basic terminologies or concepts in Ansible

A few of the basic terms that are commonly used while operating on Ansible are:

-   **Controller machine:** The controller machine is responsible for provisioning servers that are being managed. It is the machine where Ansible is installed.
-   **Inventory:** An inventory is an initialization file that has details about the different servers that you are managing.
-   **Playbook:** It is a code file written in the YAML format. A playbook basically contains the tasks that need to be executed or automated.
-   **Task:** Each task represents a single procedure that needs to be executed, e.g., installing a library.
-   **Module:** A module is a set of tasks that can be executed. Ansible has hundreds of built-in modules but you can also create custom ones.
-   **Role:** An Ansible role is a predefined way for organizing playbooks and other files in order to facilitate sharing and reusing portions of provisioning.
-   **Play:** A task executed from start to finish or the execution of a playbook is called a play.
-   **Facts:** Facts are global variables that store details about the system such as network interfaces or operating systems.
-   **Handlers:** Handlers are used to trigger the status of a service such as restarting or stopping a service.

## <a id="Q3"></a>Q3. What is a playbook?

A playbook has a series of YAML-based files that send commands to remote computers via scripts. Developers can configure complete complex environments by passing a script to the required systems rather than using individual commands to configure computers from the command line remotely. Playbooks are one of Ansible’s strongest selling points and are often referred to as Ansible’s building blocks.

## <a id="Q4"></a>Q4. State the differences between variable names and environment variables

<table><tbody><tr><td><b>Variable Names</b></td><td><b>Environment Variables</b></td></tr><tr><td><span>It can be built by adding strings.</span></td><td><span>To access the environment variable, the existing variables need to be accessed.</span></td></tr><tr><td><span>{{ hostvars[inventory_hostname][‘ansible_’ + which_interface][‘ipv4’][‘address’] }}</span></td><td><span># … vars: local_home: “{{ lookup(‘env’,’HOME’) }}”</span></td></tr><tr><td><span>You can easily create multiple variable names by adding strings.</span></td><td><span>To set environment variables, you need to see the advanced playbooks section.</span></td></tr><tr><td><span>Ipv4 address type is used for variable names.</span></td><td><span>For remote environment variables, use {{ ansible_env.SOME_VARIABLE }}.</span></td></tr></tbody></table>

## <a id="Q5"></a>Q5. Where are tags used?

A tag is an attribute that sets the Ansible structure, plays, tasks, and roles. When an extensive playbook is needed, it is more useful to run just a part of it as opposed to the entire thing. That is where tags are used.

## <a id="Q6"></a>Q6. Which protocol does Ansible use to communicate with Linux and Windows?

For Linux, the protocol used is SSH.

For Windows, the protocol often used is WinRM but can also be SSH (if using openssh or equivalent in windows).

## <a id="Q7"></a>Q7. What are ad hoc commands? Give an example

Ad hoc commands are simple one-line commands used to perform a certain task. You can think of ad hoc commands as an alternative to writing playbooks. An example of an ad hoc command is as follows:

```
Command: ansible host -m netscaler -a "nsc_host=nsc.example.com user=apiuser password=apipass"
```

## <a id="Q8"></a>Q8. What is a YAML file and how do we use it in Ansible?

YAML files are like any formatted text file with a few sets of rules similar to that of JSON or XML. Ansible uses this syntax for playbooks as it is more readable than other formats.

## <a id="Q9"></a>Q9. Code difference between JSON and YAML:

**JSON:

```
{
  "object": {
  "key": "value",
  "array": [
     {
         "null_value": null
     },
     {
         "boolean": true
     },
     {
         "integer": 1
     },
     {
         "alias": "aliases are like variables"
     }
  ]
  }
}

```

**YAML:

```
---
object:
   key: value
   array:
   - null_value:
   - boolean: true
   - integer: 1
   - alias: aliases are like variables

```


# <a id="intermediate"></a>Intermediate-level Ansible Interview Questions

Stepping up the level, let us now look into some intermediate-level Ansible interview questions and answers for experienced professionals:


## <a id="Q10"></a>Q10. Explain modules in ansible.

Modules in Ansible are idempotent. From a RESTful service standpoint, for the operation to be idempotent, clients can perform the same result by using modules in Ansible. Multiple identical requests become a single request.

There are two different types of modules in Ansible:

-   **Core modules**
-   **Extras modules**

**Core Modules**

The Ansible team maintains these types of modules, and they will always ship with Ansible software. They will also give higher priority for all requests than those in the “extras” repos.

**Extras Modules:**

These modules currently is bundled with Ansible but might available separately in the future. They are also mostly maintained by the Ansible community. These modules are still usable, but it can receive a lower rate of response to issues and pull requests.



## <a id="Q11"></a>Q11. What is Ansible-doc?

Ansible-doc displays information on modules installed in Ansible libraries. It displays a listing of plug-ins and their short descriptions, provides a printout of their documentation strings, and creates a short snippet that can be pasted in a playbook.

## <a id="Q12"></a>Q12. What is the code you need to write for accessing a variable value for a specific host?

The following command will do the job:

```
{{ hostvars[inventory_hostname]['ansible_' + which_interface]['ipv4']['address'] }}

```

The method of using hostvars is important because it is a dictionary of the entire namespace of variables. ‘inventory\_hostname’ variable specifies the current host you are looking over in the host loop.

## <a id="Q13"></a>Q13. What is a method to check the inventory vars defined for the host by using the ansible CLI?

One way this can be done by using the following command:

```
ansible -m debug -a "var=hostvars['hostname']" localhost
```

## <a id="Q14"></a>Q14. Explain Ansible facts

Ansible facts can be thought of as a way for Ansible to get information about a host and store it in variables for easy access. This information stored in predefined variables is available to use in the playbook. To generate facts, Ansible runs the set-up module.

## <a id="Q15"></a>Q15. Discuss a method to create an empty file with Ansible

To create an empty file you need to follow the steps given below:

-   **Step 1:** Save an empty file into the files directory
-   **Step 2:** Use the ansible ['copy module'](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html) to copy it to the remote host

## <a id="Q16"></a>Q16. Explain Ansible modules in detail

Ansible modules are small pieces of code that perform a specific task. Modules can be used to automate a wide range of tasks. Ansible modules are like functions or standalone scripts that run specific tasks idempotently. Their return value is JSON strings in stdout and its input depends on the type of module.

There are two types of modules:

-   **Core modules:** These are modules that the core Ansible team maintains and will always ship with Ansible itself. The issues reported are fixed on priority than those in the extras repo. The source of these modules is hosted by Ansible on GitHub in Ansible-modules-core.
-   **Extras Modules:** The Ansible community maintains these modules; so, for now, these are being shipped with Ansible but they might get discontinued in the future. Popular extras modules may be promoted to core modules over time. The source for these modules is hosted by Ansible on GitHub in Ansible-modules-extras.

## <a id="Q17"></a>Q17. What are callback plug-ins in Ansible?

Callback plug-ins mostly control the output we see while running CMD programs. Apart from this, it can also be used for adding additional output or multiple outputs. For example, log\_plays callback is used to record playbook events into a log file and mail callback is used to send an email on playbook failures.

You can also add custom callback plug-ins by dropping them into a callback\_plugins directory adjacent to play, inside a role, or by putting it in one of the callback directory sources configured in ansible.cfg.

## <a id="Q18"></a>Q18. What is Ansible inventory and its types?

An Ansible inventory file is used to define hosts and groups of hosts upon which the tasks, commands, and modules in a playbook will operate.

In Ansible, there are two types of inventory files, static and dynamic.

-   **Static inventory:** Static inventory file is a list of managed hosts declared under a host group using either hostnames or IP addresses in a plain text file. The managed host entries are listed below the group name in each line.
-   **Dynamic inventory:** Dynamic inventory is generated by a script written in Python or any other programming language or, preferably, by using plug-ins. In a cloud set-up, static inventory file configuration will fail since IP addresses change once a virtual server is stopped and started again.

## <a id="Q19"></a>Q19. What is an Ansible vault?

Ansible vault is used to keep sensitive data, such as passwords, instead of placing it as plain text in playbooks or roles. Any structured data file or single value inside a YAML file can be encrypted by Ansible.

**To encrypt the data:

```
Command: ansible-vault encrypt foo.yml bar.yml baz.yml

```

**To decrypt the data:

```
Command: ansible-vault decrypt foo.yml bar.yml baz.yml
```

## <a id="Q20"></a>Q20. How do we write an Ansible handler with multiple tasks?

Suppose you want to create a handler that restarts a service only if it is already running.

Handlers can understand generic topics, and tasks can notify those topics as shown below. This functionality makes it much easier to trigger multiple handlers. It also decouples handlers from their names, making it easier to share handlers among playbooks and roles.

```
- name: Check if restarted
shell: check_is_started.sh
register: result
listen: Restart processes

- name: Restart conditionally step 2
service: name=service state=restarted
when: result
listen: Restart processes

```

## <a id="Q21"></a>Q21. How to generate encrypted passwords for a user module?

We can do this by using a small code:

```
ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512', 'mysecretsalt') }}"
```

We can also use the Passlib library of Python.

```
Command: python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
```

## <a id="Q22"></a>Q22. Explain the concept of blocks under Ansible?

Blocks allow for logical grouping of tasks and in-play error-handling. Most of what you can apply to a single task can be applied at the block level, which also makes it much easier to set data or directives common to the tasks. This does not mean that the directive affects the block itself but is inherited by the tasks enclosed by a block, i.e., it will be applied to the tasks, not the block itself.

## <a id="Q23"></a>Q23. Do you have any idea of how to turn off the facts in Ansible?

If you do not need any factual data about the hosts and know everything about the systems centrally, we can turn off fact gathering. This has advantages in scaling Ansible in push mode with very large numbers of systems, mainly, or if we are using Ansible on experimental platforms.

```
Command:
- hosts: whatever
gather_facts: no
```

## <a id="Q24"></a>Q24. What are the registered variables under Ansible?

Registered variables are valid on the host for the remainder of the playbook run, which is the same as the lifetime of facts in Ansible. Effectively registered variables are very similar to facts. While using register with a loop, the data structure placed in the variable during the loop will contain a results attribute, which is a list of all responses from the module.

## <a id="Q25"></a>Q25. By default, the Ansible reboot module waits for how many seconds. Is there any way to increase it?

By default, the Ansible reboot module waits 600 seconds. Yes, it is possible to increase Ansible reboot to certain values. The syntax given-below can be used for the same:

```
- name: Reboot a Linux system  
reboot:
reboot_timeout: 1200


```

## <a id="Q26"></a>26\. What do you understand by the term idempotency? Why is it important?

Idempotency is an important Ansible feature. It prevents unnecessary changes in managed hosts. With idempotency, we can execute one or more tasks on a server as many times as we need to, but it will not change anything that has already been modified and is working correctly.

To put it simply, the only changes added are the ones needed and not already in place.
When re-running idempotent play/role using the same inputs, the same end-state will be achieved.

## <a id="Q27"></a>Q27. Can you copy files recursively onto a target host? If yes, how?

We can copy files recursively onto a target host by using the copy module. It has a recursive parameter that copies files from a directory. There is another module called synchronize, which is specifically made for this.

```
- synchronize:
        src: /first/absolute/path
        dest: /second/absolute/path
        delegate_to: "{{ inventory_hostname }}"
```

## <a id="Q28"></a>Q28. Can you keep data secret in the playbook?

The following playbook might come in handy if you want to keep secret any task in the playbook when using -v (verbose) mode:

```
- name: secret task
    shell: /usr/bin/do_something --value={{ secret_value }}
    no_log: True

```

It hides sensitive information from others and provides the verbose output.

## <a id="Q29"></a>Q29. Can docker modules be implemented in Ansible? If so, how can you use it?

Yes, you can implement docker modules in Ansible.

Ansible requires you to install docker-py on the host.

```
Command: $ pip install 'docker-py>=1.7.0'
```

The docker\_service module also requires docker-compose.

```
Command: $ pip install 'docker-compose>=1.7.0'
```

## <a id="Q30"></a>Q30. How do you test Ansible projects?

The standard testing methods available:

- **_Asserts: Asserts duplicates how the test runs in other languages like Python. It verifies that your system has reached the actual intended state, and not just as a simulation that you would find in check mode. Asserts shows that the task did the job it was supposed to do and changed the appropriate resources._
- **_Check mode: Check mode shows you how everything would run without the simulation. Therefore, you can easily see if the project behaves the way we expected it to. The limitation is that check mode does not run the scripts and commands used in the roles and playbooks. To get around this, we have to disable check mode for specific tasks by running._
- **Command:** _check\_mode: no_
- **Manual run: Just run the play and verify that the system is in its desired state. This testing choice is the easiest method, but it carries an increased risk because it results in a test environment that may not be similar to the production environment.


## <a id="Q31"></a>Q31. What is the recommended method/practice to make ansible play content reusable/redistributable?

You can read everything about “Roles” in the playbooks documentation section. This helps to make playbook content self-contained and shareable with other ansible users.

## <a id="Q32"></a>Q32. How do you see all variables for a host?

You can see them using the hostvars variable. This stores host variables with the hostname as key. For example, to look at the variables defined for localhost, you can run;

```
ansible -m debug -a "var=hostvars[inventory_hostname]"
```


## <a id="Q33"></a>Q33. How to continue execution on failed task after fixing error in playbook?

If you want to start executing your playbook at a particular task, you can do so with the `--start-at-task` option:

```
ansible-playbook playbook.yml --start-at-task="install packages"
```

The above will start executing your playbook at a task named _“install packages”_.

Alternatively, take a look at this previous answer [How to run only one task in ansible playbook?](https://stackoverflow.com/questions/23945201/how-to-run-only-one-task-in-ansible-playbook)

Finally, when a play fails, it usually gives you something along the lines of:

```
PLAY RECAP ******************************************************************** 
           to retry, use: --limit @/home/user/site.retry
```

Use that `--limit` command and it should retry from the failed task.

Notes/limitations: 

* The .retry file only contains the failed hosts, it doesn't store where exactly each host failed.
* As of ansible 2.2.1.0, --start-at-task does not work for tasks defined within roles.



## <a id="Q34"></a>Q34. How to define a task to fail only when the following 2 conditions exist in the registered task results:  (1) result is failed and (2) the pattern "ALREADY_ENABLED" is not found in result.msg?

If you want the task to fail when the 2 conditions are satisfied, change the `failed_when` definition to

```
    ...
    register: result
    failed_when: result is failed and 'ALREADY_ENABLED' not in result.msg
```

