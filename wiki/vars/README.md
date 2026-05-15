```markdown
---
title: Vault Variables Documentation
original_path: vars/README.md
category: Configuration
tags: [ansible, vault, variables]
---

# Vault Variables

This document contains sensitive information stored in Ansible Vault. Ensure that you have the necessary permissions and tools to access and manage these variables securely.

## Example `vars/vault.yml`

```yaml
---
vault__ansible_password__linux: "goobar"
vault__ansible_password__windows: "moobar"

vault__hash_seed: "myhashseed"

vault__idrac_user: "root"
vault__idrac_password: "passwordhere"

vault__bind_tsig_keys_secret: "HasmFAbvvlakrgarvmavr0var=="

#awx_pb_admin_password: "passwordhere"
vault__awx_admin_password: "passwordhere"

## VMware
vault__vcenter_password: "passwordhere"

## VCENTER SERVER STANDARD
vault__vcenter_license: 00000-000000-00000-00000-00000

vault__esxi_license: 00000-000000-00000-00000-00000

## VMWARE VSPHERE 6 ENTERPRISE PLUS
vault__vsphere_licenses:
  esx00.example.int: "{{ esxi_license }}"
  esx01.example.int: "{{ esxi_license }}"
  esx02.example.int: "{{ esxi_license }}"
  ## nested/virtual esxi host
  vesxi01.example.int: "{{ esxi_license }}"

## Role: vsphere-deploy-dc
vault__esxi_password: "passwordhere"
vault__nested_esxi_password: "{{ esxi_password }}"
vault__nested_esxi_password_crypted: "{{ nested_esxi_password | password_hash('sha512',65534 | random(seed=hash_seed) | string) }}"

vault__veeam_agent_password: "passwordhere"

vault__fog_mysql_password: "abcZmhn8WqaG1xrt"
vault__docker_stack_mysql_fog_password: "{{ fog_mysql_password }}"

## Shell Environments
vault__envvar_ldap_config_pwd: "passwordhere"
#envvar_ansible_ssh_password: "passwordhere"
#envvar_ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') | d(ansible_ssh_pass) }}"
vault__envvar_ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') }}"
vault__envvar_ansible_become_password: "{{ envvar_ansible_ssh_password }}"

## iSCSI
vault__iscsi__session_auth_username: usernamehere
vault__iscsi__session_auth_password: passwordhere

vault__bootstrap_linux_ansible_ssh_allowed_ips:
  - "{{ groups['control_node'][0]['ansible_default_ipv4']['address'] }}"

vault__smbusername: "root"
vault__smbpassword: "passwordhere"

vault__CSAdminUser: "admin"
vault__CSMySQLPwd: "passwordhere"
vault__CloudDBPass: "passwordhere"

#CSAdminPwd: "passwordhere"
vault__CSAdminPwd: "passwordhere"
vault__CSHostpassword: "passwordhere"

vault__pfsense_user: "admin"
vault__pfsense_pwd: "passwordhere"

# rndc_key:
# DNS update key, generated with `rndc-confgen -a -b 512 -r /dev/urandom`
# stored in ansible vault
# omapi_key:
# DHCP failover key, generated with `dnssec-keygen -a HMAC-MD5 -b 512 -n USER DHCP_OMAPI`
# stored in ansible vault
vault__rndc_key: "SssssTewewwGssgdHKjsdvdsfklsdgdfG:DSFgdfHDKHDHDLfhdFHDLGFhdGHLDHLdhDFHLhdFHLDHLDHLdhQ=="
vault__omapi_key: "AzzzzTewewwGssgdHKjsdvdsfklsdgdfG:DSFgdfHDKHDHDLfhdFHDLGFhdGHLDHLdhDFHLhdFHLDHLDHLdhQ=="

#bootstrap_linux_ansible_username: deployer
#bootstrap_linux_ansible_sudo_group: sudo
#bootstrap_linux_ansible_authorized_public_sshkey: ~/.ssh/id_rsa.pub

#admin_ssh_public_key: "{{ lookup('file', admin_ssh_public_keyfile) }}"
vault__admin_ssh_public_key: ssh-rsa AAAAB3NtxC1fg2EZZZZDBQABAAABAQDMX0dPcvoiLIR3qdv+FZLB/yia1RYga28TBQcy762y/I5dgNs1hKNr9lCGlWj08Miiazb/BUS7OD9Pby+c4SK4BOwdqn/LMAGKe23JbMlhCVSwEll8U/ojW1Nm0OrfOnK6CIjkf8lXsTG0hh8DC7QGzGALeQJUpLMQpTvrWk2dJ66jGOFNnqVcJGiVIRuSreFoSbWGyOUbJ6wbXKKLUk+0uD3eAMc6pMDvP3cyhSBlfJce6gB7XzmVrnCSFYJK+s12WcseQa9HeInNgyHdhpinfn1bGMdOLEQz/bhviKosKg8e4L2i3pC3w+tJCGs36b5OmKZDkElfR8+ZtuYyX6Rb lee.james.johnson@gmail.com

#admin_ssh_private_key: "{{ lookup('file', admin_ssh_private_keyfile) }}"
#admin_ssh_private_key: "{{ lookup('env','ANSIBLE_NET_SSH_KEY') | d(admin_private_sshkey) }}"

vault__admin_ssh_private_key: |
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEAzF9HT3L6IiyEd6nb/hVyxP8omtUWIGtvEwUHMu+tsvyOXYDb
  NYSja/ZQhpVo9PDIoms2/wVEuzg/T28vnOEiuATsHap/yzABinttyWzJYQlUsBJZ
  fFP6I1tTZtDq3zpyugiI5H/JV7ExtIYfAwu0BsxgC3kCVKSzEKU761pNnSeuoxjh
  eo5QFy6TXpWyBRwfEvrxnZ5U+yFgu5J1JNyShv1NCi4s4PWwqoCK8Ozfo9FbpgPq
  9ZJM5wKBgQCEaWSxhrASiUtEb/H+zjfs8UqhCoi82wEyKlArrdCJw0NdQ66NoYR2
  KZDimirwwdPFgGQbgAIjeeL2+TgOo+GAMQF3kV/yK7726dBb5EWaonkIt9NCqSF3
  tF5wv2frG/QhUABPFn4ihFBsdyXRnr5+wzP3rRB77Cp+JaFDr6hxBA==
  -----END RSA PRIVATE KEY-----

vault__ansible_ssh_private_key: "privatekeyhere"
vault__ansible_ssh_public_key: "pubkeyhere"

vault__git_ssh_private_keyfile: "{{ admin_ssh_private_keyfile }}"
vault__openstack_ssh_public_key_file: "{{ admin_ssh_public_keyfile }}"

## Gmail SMTP Password
vault__google_app_password_gmail: "passwordhere"

vault__smtp_relay_password: "{{ google_app_password_gmail }}"

vault__postfix_sasl_user: "{{ smtp_relay_username }}"
vault__postfix_sasl_password: "{{ smtp_relay_password }}"

vault__cloudflare_email: "lee.james.johnson@gmail.com"
vault__cloudflare_apikey: "4a5f6f4f9b3h20f70b280b59dcf1f0ca9fd51"

#passthru_registry_name: "admin2"
#registry_name: "media"
#registry_domain: "{{ internal_domain }}"

vault__samba_domain: JOHNSON.INT

vault__ansible_repo_name: ansible-datacenter
vault__ansible_repo_source: "git@bitbucket.org:leejjohnson/{{ ansible_repo_name }}.git"

vault__ldap_config_password: "passwordhere"
vault__ldap_admin_password: "passwordhere"
vault__ldap_readonly_user_password: "passwordhere"

vault__bind_admin_password: "passwordhere"

# User to join domain
vault__samba_join_user: admin
vault__samba_join_passwd: "{{ ldap_admin_password }}"

## If smb_ldap_uri not empty, use LDAP (to be defined in eg. "SMBDC" group)
#smb_ldap_admindn: "cn=admin,{{ ldap_internal.ldap_base_dn }}"
#smb_ldap_adminpw: "{{ ldap_admin_password }}"

#smb_ldap_uri: "ldap://{{ hostvars[groups['ldap_server'][0]]['inventory_hostname'].{{ smb_domain }}"
vault__smb_ldap_uri: "ldap://{{ hostvars[groups['docker_stack_admin'][0]]['inventory_hostname'] }}.{{ smb_domain }}"
#smb_ldap_suffix: "dc=johnson,dc=int"
vault__smb_ldap_suffix: "dc={{ internal_domain.split('.')[-2] }},dc={{ internal_domain.split('.')[-1] }}"
```

## Backlinks

- [Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Managing Sensitive Data](https://docs.ansible.com/ansible/latest/guide_collection/managing_sensitive_data.html)

Ensure that all sensitive information is encrypted and securely managed using Ansible Vault.
```

This improved version includes a clean structure with proper headings, YAML frontmatter for metadata, and a "Backlinks" section to provide additional resources.