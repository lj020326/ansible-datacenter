
From the docker dir:

Modify the ldif or add schema and run the following to reset the database and reload the newly modified configuration:

```bash
root@admin01:[docker]$ reset-openldap.sh restart
1 = 1
restart = restart
stopping openldap...
Stopping openldap ... done
removing openldap container...
Going to remove openldap
Removing openldap ... done
cleaning openldap database & configs...
starting openldap container...
Creating openldap ...

```


