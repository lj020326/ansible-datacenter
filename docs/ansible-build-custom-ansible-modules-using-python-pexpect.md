
# Build custom Ansible modules using Python's Pexpect

When developing automation you may be faced with challenges that are simply too complicated or tedious to accomplish with Ansible alone. There may even be cases where you are told that "it can’t be automated." However, when you combine the abilities of Ansible and custom Python using the Pexpect module, then you are able to automate practically anything you can do on the command line. In this post we will discuss the basics of creating a custom Ansible module in Python.  

Here are a few examples of cases where you might need to create a custom module: 

-   Running command line programs that drop into a new shell or interactive interface. 
    
-   Processing complex data and returning a subset of specific data in a new format. 
    
-   Interacting with a database and returning data in a specific format for further Ansible processing.
    

For the purposes of this post we will focus on the first case. When writing a traditional Linux shell or Bash script it simply isn’t possible to continue your script when a command you run drops you into a new shell or new interactive interface. This might be seen when following installation instructions provided by some software publishers. For example, I have seen cases where you run a script that prepares a special KornShell environment where you then run other scripts from.

If these tools also provided a non-interactive mode or config/script input we would not need to do this. To overcome this situation we need to use Python with Pexpect. The native Ansible `expect` module provides a simple interface to this functionality and should be evaluated before writing a custom module. However, when you need more complex interactions, want specific data returned or want to provide a re-usable and simpler interface to an underlying program for others to consume, then custom development is warranted.  

In this guide I will talk about the requirements and steps needed to create your own library module. The source code with our example is located here and contains notes in the code as well. The Pexpect code is intentionally complex to demonstrate some use cases. Note that we've reviewed the code for accuracy but can't guarantee that it will work in all possible environments, future Python updates, and so forth. You can see the code on GitHub here: 

-   [Module Code (Python)](https://github.com/keyvatech/RHUG2020_ansible_pexpect/blob/master/library/keyva_pexpect_cli.py)
-   [Example Repo](https://github.com/keyvatech/RHUG2020_ansible_pexpect)

In order to create a module you need to put your new `mymodule.py` file somewhere in the Ansible module library path, typically the `library` directory next to your playbook or library inside your role. As you can see in the repo above the modules are in a directory named "library" next to the playbook and will automatically be seen by ansible at runtime. You should also be careful not to name your module in a way that could conflict with the standard library. I would suggest adding your company name as a prefix like we have.

It’s also important to note that Ansible library modules run on eachtarget host, so if you want to use the Ansible "expect" module or make a custom module with Pexpect in it then you will need to install the Python Pexpect module on the remote host before running the module. In the playbook.yaml file in the main directory of the repo you can see that we automatically check and install this for the virtual machine. (Note: the Pexpect version provided in RHEL/CentOS repo RPMs may be older and might not support the Ansible "expect" module, check the version and if it is older install it via pip instead for the latest version. Python >= 2.6 and Pexpect >= 3.3 are required, see the [module page here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/expect_module.html).) 

Information on the library path is located in [Adding modules and plugins locally — Ansible Documentation](https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html). 

Your `example.py` file needs to be a standard file with a Python shebang header and it also must import the Ansible module. Here is a bare minimum amount of code needed for an Ansible module. 

```
#!/usr/bin/env python 
from ansible.module_utils.basic import AnsibleModule 
module = AnsibleModule(argument_spec=dict(mysetting=dict(required=False, type='str'))) 
try: 
return_value = "mysetting value is: {0}".format(module.params['mysetting']) 
except: 
module.fail_json(msg="Unable to process input variable into string") 
module.exit_json(changed=True, my_output=return_value) 
```

With this example you can see how variables are passed into and out of the module. This also includes a basic exception handling for dealing with errors and allowing Ansible to deal with the failure. This exception clause is too broad for normal use as it will catch and hide all errors that could happen in the try block. When you create your module you should only except error types that you anticipate to avoid hiding stack traces of unexpected errors from your logs. 

Now we can add in some custom Pexpect processing code. This is again a very basic example. The sample code linked in this post has a complicated and in-depth example. This function would then be added into our try-except block in the code above. 

```
def run_pexpect(password): 
import pexpect 
child = pexpect.spawn('/path/to/myscript.sh') 
child.timeout = 60 
child.expect(r"Enter password\:") 
child.sendline(password) 
child.expect('Thank you') 
child.sendline('exit') 
child.expect(pexpect.EOF) 
exit_dialog = child.before.strip() 

return exit_dialog
```

There are some important things to note here when dealing with Pexpect and Ansible. 

-   If the program hits a timeout it will raise `pexpect.TIMEOUT` and if it terminates unexpectedly it will raise `pexpect.EOF`. These exceptions will need to be either expected, with child.expect or excepted using pythons exception handling. Any other exceptions don’t really need to be handled as then are likely real errors that should cause failure and raise a stack trace.  
    
-   Always use a timeout! Be careful never to set the timeout to None as an unattended process will hang indefinitely waiting on any new/unexpected prompt. It’s better to set a very generous timeout over none at all. You can change the timeout multiple times in code based on how long you expect each prompt to take to come back. 
    
-   If you do not set a timeout value at all the default for the spawn class is 30 seconds. This is the timeout looking for the text in an expect method. Even if your program is outputting text to stdout, when the timeout is hit before the string is found then the program is killed and `pexpect.TIMEOUT` is raised. 
    
-   Don’t use print functions in Python to try to send information back to Ansible. Printing to stdout with your module will cause ansible to register a failure. Output and information should be passed back through an Ansible method like `module.exit_json`.  
    
-   For debugging you may want to use the `child.logfile` facility to create log files on the remote system. 
    
-   The `child.expect` method takes regular expressions as input. If you want an explicit string you can always `import re` and use the `re.escape` method on a string to escape it. 
    

When creating custom modules I would encourage you to give thought to making the simplest, most maintainable and modular modules possible. It can be easy to create one module/script to rule them all, but the Linux concept of having one tool to do one thing well will save you rewriting chunks of code that do the same thing and also help future maintainers of the automation you create.

For a more comprehensive and interactive example of doing this, which includes mock cli and install scripts please see our repo here. You can see that the mock install script is an example of an installer that behaves very poorly. It always exits 0, terminates without a message on a bad password and calls an error, but doesn't quit. This is also something that I have encountered and making a custom module to manage a script you don’t have control over can help automate an otherwise difficult case. This was [presented at a 2020 Red Hat User Group as well](https://github.com/keyvatech/RHUG2020_ansible_pexpect).

## Reference

* https://www.redhat.com/en/blog/build-custom-ansible-modules-using-pythons-pexpect

