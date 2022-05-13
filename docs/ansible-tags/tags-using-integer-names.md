
There is inconsistent behavior with respect to tags with names containing only numbers, or numbers combined with underscores. 

The version of ansible we are using to demonstrate this.

```yaml
ansible --version
ansible [core 2.12.3]
  config file = None
  configured module search path = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/ljohnson/.pyenv/versions/3.10.2/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/ljohnson/.ansible/collections:/usr/share/ansible/collections
  executable location = /Users/ljohnson/.pyenv/versions/3.10.2/bin/ansible
  python version = 3.10.2 (main, Feb 21 2022, 15:35:10) [Clang 13.0.0 (clang-1300.0.29.30)]
  jinja version = 3.1.0
  libyaml = True

```

# Integer based tag name does not work for tasks tags without quotes

Take the following [tags-using-integer-names.yml](./tags-using-integer-names.yml) playbook for this example.

./tags-using-integer-names.yml
```yaml
---
- hosts: localhost
  gather_facts: false
  tasks:
    - name: integer test
      debug:
        msg: "Test of an integer tag"
      tags:
        - 4_5_6
        - "9_9_9"

```


Running following ansible-playbook commands will not invoke the "integer test" task.

* Test 1
  ```output
  ansible-playbook tags-using-integer-names.yml -t 4_5_6
  [WARNING]: No inventory was parsed, only implicit localhost is available
  [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
  PLAY [localhost] **************************************************************************************************************************************************************************************************************************************************************
  PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************
  ```

* Test 2
  ```output
  ansible-playbook tags-using-integer-names.yml -t "4_5_6"
  [WARNING]: No inventory was parsed, only implicit localhost is available
  [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
  PLAY [localhost] **************************************************************************************************************************************************************************************************************************************************************
  PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************
  ```

# Integer based tag name does work for tasks tags using quotes

Note that the [tags-using-integer-names.yml](./tags-using-integer-names.yml) playbook, that the task tag for "9_9_9" uses quotes.

When running the playbook for this tag, it works:

* Test 1
  ```output
  ansible-playbook tags-using-integer-names.yml -t 9_9_9
  [WARNING]: No inventory was parsed, only implicit localhost is available
  [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
  PLAY [localhost] **************************************************************************************************************************************************************************************************************************************************************
  TASK [integer test] ***********************************************************************************************************************************************************************************************************************************************************
  ok: [localhost] => {
      "msg": "Test of an integer tag"
  }
  PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************
  localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  ```

* Test 2
```output
ansible-playbook tags-using-integer-names.yml -t "9_9_9"
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
PLAY [localhost] **************************************************************************************************************************************************************************************************************************************************************
TASK [integer test] ***********************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Test of an integer tag"
}
PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Conclusion

Note for the ansible environment we are using that the python version is 3.10.2.

As of Python version 3.6 (and [PEP-515](https://www.python.org/dev/peps/pep-0515/)) there is a new convenience notation for big numbers introduced which allows you to divide groups of digits in the number literal so that it is easier to read them.

Python will consider underscores as just number separators for readability.  So you could do 9_999_999 to make 9999999 more readable.  The python interpreter then considers 9_9_9 to be the same as 999.

This python version difference behavior also explains why one may encounter ansible repos in the wild (github.com) using integer name based tags without quotes.   It is likely the respective repo developers were using an ansible environment with python versions <= 3.6 at the time of publishing to the repo.

## Related Information

* https://www.reddit.com/r/ansible/comments/8qt7ds/tags_inheritance_in_include_tasks_vs_import_tasks/
* https://www.python.org/dev/peps/pep-0515/
* https://stackoverflow.com/questions/54009778/what-do-underscores-in-a-number-mean


