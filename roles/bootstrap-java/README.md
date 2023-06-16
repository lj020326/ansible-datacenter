# Ansible Role: bootstrap-java

Installs Java for RedHat/CentOS and Debian/Ubuntu linux servers.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values:

    # The defaults provided by this role are specific to each distribution.
    bootstrap_java__packages:
      - java-1.8.0-openjdk

Set the version/development kit of Java to install, along with any other necessary Java packages. Some other options include are included in the distribution-specific files in this role's 'defaults' folder.

    bootstrap_java__home: ""

If set, the role will set the global environment variable `JAVA_HOME` to this value.

## Dependencies

None.

## Example Playbook (using default package)

    - hosts: servers
      roles:
        - role: bootstrap-java
          become: yes

## Example Playbook (install OpenJDK 8)

For RHEL / CentOS:

    - hosts: server
      roles:
        - role: bootstrap-java
          when: "ansible_os_family == 'RedHat'"
          bootstrap_java__packages:
            - java-1.8.0-openjdk

For Ubuntu < 16.04:

    - hosts: server
      tasks:
        - name: installing repo for Java 8 in Ubuntu
  	      apt_repository: repo='ppa:openjdk-r/ppa'
    
    - hosts: server
      roles:
        - role: bootstrap-java
          when: "ansible_os_family == 'Debian'"
          bootstrap_java__packages:
            - openjdk-8-jdk

## Reference

- https://github.com/buluma/ansible-role-openjdk
- https://github.com/geerlingguy/ansible-role-java
- https://github.com/abessifi/ansible-java
- https://github.com/traveloka/ansible-java-openjdk
- https://github.com/idealista/java_role
