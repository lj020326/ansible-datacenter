
# apt_key deprecated in Debian/Ubuntu - how to fix in Ansible

For many packages, like Elasticsearch, Docker, or Jenkins, you need to install a trusted GPG key on your system before you can install from the official package repository.

Traditionally, you'd run a command like:

```shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
```

But if you do that in modern versions of Debian or Ubuntu, you get the following warning:

```shell
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
```

This way of adding apt keys still works for now (in mid-2022), but will stop working in the next major releases of Ubuntu and Debian (and derivatives). So it's better to stop the usage now. In Ansible, you would typically use the [`ansible.builtin.apt_key`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_key_module.html) module, but even that module has the following deprecation warning:

> The apt-key command has been deprecated and suggests to ‘manage keyring files in trusted.gpg.d instead’. See the Debian wiki for details. This module is kept for backwards compatiblity for systems that still use apt-key as the main way to manage apt repository keys.

So traditionally, I would use a task like the following in my Ansible roles and playbooks:

```yaml
- name: Add Jenkins apt repository key.
  ansible.builtin.apt_key:
    url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
    state: present

- name: Add Jenkins apt repository.
  ansible.builtin.apt_repository:
    repo: "deb https://pkg.jenkins.io/debian-stable binary/"
    state: present
    update_cache: true
```

The new way to do this without adding an extra `gpg --dearmor` task is to use `get_url` to download the file into the `trusted.gpg.d` folder with the `.asc` filename. Therefore the first task above can be replaced with:

```yaml
- name: Add Jenkins apt repository key.
  ansible.builtin.get_url:
    url: "{{ jenkins_repo_key_url }}"
    dest: /etc/apt/trusted.gpg.d/jenkins.asc
    mode: '0644'
    force: true
```

See [this issue in ansible/ansible](https://github.com/ansible/ansible/issues/78063) for a little more background.

## Reference

- [aptkey-deprecated-debianubuntu-how-fix-ansible](https://www.jeffgeerling.com/blog/2022/aptkey-deprecated-debianubuntu-how-fix-ansible)

