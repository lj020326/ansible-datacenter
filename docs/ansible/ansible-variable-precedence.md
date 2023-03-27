
# Ansible variable precedence

Ansible applies variable precedence. The following is the order of precedence from least to greatest (the last listed variables override all other variables) as of version 2.10:

1. command line values (for example, -u my_user, these are not variables)
2. role defaults (defined in role/defaults/main.yml) [^1]
3. inventory file or script group vars [^2]
4. inventory group_vars/all [^3]
5. playbook group_vars/all [^3]
6. inventory group_vars/* [^3]
7. playbook group_vars/* [^3]
8. inventory file or script host vars [^2]
9. inventory host_vars/* [^3]
10. playbook host_vars/* [^3]
11. host facts / cached set_facts [^4]
12. play vars
13. play vars_prompt
14. play vars_files
15. role vars (defined in role/vars/main.yml)
16. block vars (only for tasks in block)
17. task vars (only for the task)
18. include_vars
19. set_facts / registered vars
20. role (and include_role) params
21. include params
22. extra vars (for example, -e "user=my_user")(always win precedence)

## Footnotes

[^1]: [Tasks in each role see their own role’s defaults. Tasks defined outside of a role see the last role’s defaults.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id4)

[^2]: Variables defined in inventory file or provided by dynamic inventory.[1](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id5) [2](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id10)

[^3]: [Includes vars added by ‘vars plugins’ as well as host\_vars and group\_vars which are added by the default vars plugin shipped with Ansible.] [1](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id6) [2](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id7) [3](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id8) [4](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id9) [5](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id11) [6](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id12)

[^4]: [When created with set\_facts’s cacheable option, variables have the high precedence in the play, but are the same as a host facts precedence when they come from the cache.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable#id13)


## Reference

* https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence
* 