

1. Bootstrap nodes:

    ```bash
    ansible-playbook -v -i inventory/hosts.ini site.yml --ask-become-pass --tags bootstrap
    #ansible-playbook -v -i inventory/hosts.ini bootstrap.yml
    ```

    When running on a remote jump host, use the run-remote.sh helper script to run ansible remotely:

    ```bash
    run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit algo
    ```


2. Ping host

    ```bash
    ansible -i inventory/hosts.ini all -m ping -b -vvvv
    ```

3. Add SSH key for host to be managed by ansible
    - ref: https://unix.stackexchange.com/questions/6533/is-there-an-easy-way-to-update-information-in-known-hosts-when-you-know-that-a-h

    ```bash
    TARGET_HOST=[hostname or IP]
    
    # Remove the old key(s) from known_hosts
    ssh-keygen -R $TARGET_HOST
    
    # Add the new key(s) to known_hosts (and also hash the hostname/address)
    ssh-keyscan -H $TARGET_HOST >> ~/.ssh/known_hosts
    
    ```

    ```bash
    ssh-keygen -R node01.example.int -f ~/.ssh/known_hosts
    
    ansible -i host.ini all -a "grep ^root: /etc/shadow"  -b
    ansible -i inventory all -a "grep ^root: /etc/shadow"  -b
    ```

Additional Notes:

To ping 

	ansible -m ping all
	ansible -i inventory -m ping all
	ansible -i inventory -m ping -c paramiko -vvv
	ansible -i inventory -m ping -c ssh -vvv


Bootstrap setup/testing notes/history:

```bash
#run-remote.sh ansible-playbook -v site.yml --tags bootstrap-user --ask-pass --limit nas2

run-remote.sh ansible-playbook -v site.yml --tags bootstrap-user --limit nas2
bootstrap-users.sh nas2
run-remote.sh ansible-playbook -v site.yml --tags cacerts

run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit nas2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit nas2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit samba
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit samba
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit nas2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit Ubuntu
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit os_Ubuntu
run-remote.sh ansible-playbook -v site.yml --tags bootstrap -e "pattern=os_Ubuntu"
#run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit node01
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit oscontroller01
#run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker --limit node01
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker --limit oscontroller01
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker --limit openshift
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit openshift
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-ansible --limit openshift
run-remote.sh ansible-playbook -vvv site.yml --tags bootstrap-ansible --limit openshift
bootstrap-users.sh openshift
run-remote.sh ansible-playbook -vvv site.yml --tags bootstrap-ansible --limit openshift
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-ansible --limit openshift
run-remote.sh ansible-playbook -vvv site.yml --tags bootstrap-ansible --limit openshift
run-remote.sh ansible-playbook -vvv site.yml --tags bootstrap --limit openshift
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit openshift
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit os_Ubuntu
run-remote.sh ansible-playbook -v site.yml --tags bootstrap -e "pattern=os_Ubuntu"
run-remote.sh ansible-playbook -v site.yml --tags bootstrap -e "group=os_Ubuntu"
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-ansible --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit nas2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker-images --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap --limit admin2
run-remote.sh ansible-playbook -v site.yml --tags bootstrap
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-samba-server
bootstrap-users.sh ubuntu18
history | grep bootstrap
bootstrap-users.sh ubuntu18
gethist | grep bootstrap | uniq
gethist | grep bootstrap | uniq >> NOTES.md 

```
