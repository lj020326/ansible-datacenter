

example vars/vault.yml:
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

## vmware
vault__vcenter_password: "passwordhere"

## VCENTER SERVER STANDARD
vault__vcenter_license: 00000-000000-00000-00000-00000

vault__esxi_license: 00000-000000-00000-00000-00000

##	VMWARE VSPHERE 6 ENTERPRISE PLUS
vault__vsphere_licenses:
  esx00.example.int: "{{ esxi_license }}"
  esx01.example.int: "{{ esxi_license }}"
  esx02.example.int: "{{ esxi_license }}"
  ## nested/virtual esxi host
  vesxi01.example.int: "{{ esxi_license }}"

## role: vsphere-deploy-dc
vault__esxi_password: "passwordhere"
vault__nested_esxi_password: "{{ esxi_password }}"
vault__nested_esxi_password_crypted: "{{ nested_esxi_password | password_hash('sha512',65534 | random(seed=hash_seed) | string) }}"

vault__veeam_agent_password: "passwordhere"

vault__fog_mysql_password: "abcZmhn8WqaG1xrt"
vault__docker_stack_mysql_fog_password: "{{ fog_mysql_password }}"

## shell envs
vault__envvar_ldap_config_pwd: "passwordhere"
#envvar_ansible_ssh_password: "passwordhere"
#envvar_ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') | d(ansible_ssh_pass) }}"
vault__envvar_ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') }}"
vault__envvar_ansible_become_password: "{{ envvar_ansible_ssh_password }}"

## iscsi
vault__iscsi__session_auth_username: usernamehere
vault__iscsi__session_auth_password: passwordhere

vault__bootstrap_linux_ansible_ssh_allowed_ips: |
  [
    {% for item in groups["control_node"] -%}
    {{ comma() }}{{ hostvars[item].ansible_default_ipv4.address }}
    {%- endfor %}
  ]

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

## gmail smtp pwd:
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

# user to join domain
vault__samba_join_user: admin
vault__samba_join_passwd: "{{ ldap_admin_password }}"

## if smb_ldap_uri not empty, use ldap (to be defined in eg. "SMBDC" group)
#smb_ldap_admindn: "cn=admin,{{ ldap_internal.ldap_base_dn }}"
#smb_ldap_adminpw: "{{ ldap_admin_password }}"

#smb_ldap_uri: "ldap://{{ hostvars[groups['ldap_server'][0]]['inventory_hostname'].{{ smb_domain }}"
vault__smb_ldap_uri: "ldap://{{ hostvars[groups['docker_stack_admin'][0]]['inventory_hostname'].{{ smb_domain }}"
#smb_ldap_suffix: "dc=johnson,dc=int"
vault__smb_ldap_suffix: "dc={{ internal_domain.split('.')[-2] }},dc={{ internal_domain.split('.')[-1] }}"
vault__smb_ldap_group_suffix: 'ou=groups'
vault__smb_ldap_user_suffix: 'ou=users'
vault__smb_ldap_machine_suffix: 'ou=computers'
vault__smb_ldap_idmap_suffix: "ou=Idmap"
vault__smb_ldap_replication_sleep: 2000
vault__smb_ldap_ssl: 'off'
vault__smb_ldap_passwd_sync: 'Yes'

#shares:
#  - name: "netlogon"
##    path: "/shares/netlogon"
#    path: "/srv/storage/netlogon"
#    cifs: True
#    smbparms:
#      guest ok: yes
#      read only: yes
#      valid users: "@smbadmin, @smbuser"
#      comment: "Netlogon service"
##      root preexec: "/my/script/mknetlogon %U %G %I"

vault__smb_group_shares:
  - name: "data"
    path: "/data"
    cifs: True
    smbparms:
      valid users: "root @users @admin @smbuser @smbguest @smbadmin @administrator"
      public: "yes"
      guest ok: "yes"
      force group: "smbguest"
      force directory mode: "775"
      force create mode: "775"
      write list: "root @users @admin @smbuser @smbguest @smbadmin @administrator"
      writeable: "yes"
      create mode: "0777"
      directory mode: "0777"

vault__registry_create_certs: yes
vault__registry_country: US
vault__registry_province: NY
vault__registry_locality: New York City
vault__registry_organization: Dettonville
vault__registry_organizational_unit: Internal

vault__registry_username: "admin"
vault__registry_password: "passwordhere"

vault__docker_registry_username: "{{ registry_username }}"
vault__docker_registry_password: "{{ registry_password }}"

vault__registry_users:
  - username: "{{ registry_username }}"
    password: "{{ registry_password }}"
#  - username: testuser
#    password: testpasswordhere
#  - username: testuser1
#    password: testpasswordhere2
#  - username: testuser2
#    password: testpasswordhere2

## ref: https://stackoverflow.com/questions/19292899/creating-a-new-user-and-passwordhere-with-ansible
vault__admin_password: "passwordhere"
vault__sha512_hashed_admin_password: "{{ admin_password | password_hash('sha512',65534 | random(seed=hash_seed) | string) }}"

vault__ansible__user_password: "passwordhere"

vault__ansible_root_password: "passwordhere"

vault__crypt_hashed_password: "$1$words.a$Aw9ZpMWeB1R9NWWXTLiu0."

## role: deploy-vm
vault__deploy_vm__vm_ansible_password: "{{ ansible__user_password }}"

## By default, "openssl passwd" will use an md5 algoritme for your passwordhere hash.
## md5 is type 1
## sha512 is type 6
##
## openssl passwd -1 -salt SaltSalt secret
## openssl passwd -1
## openssl passwd -6 -salt In279KJIUOzcmUwM f00b4r987
## echo 'cleartext-passwordhere' | openssl passwd -1 -stdin
##
## To hash a sha512 passwordhere (salt type 6):
## openssl passwd -6 -salt In279KJIUOzcmUwM f00b4r987
##
## If you’re looking for sha256 or sha512 hash you can also use this python code
## refs:
##   https://ma.ttias.be/how-to-generate-a-passwd-passwordhere-hash-via-the-command-line-on-linux/
##   https://unix.stackexchange.com/questions/52108/how-to-create-sha512-passwordhere-hashes-on-command-line

##
## python -c "import crypt; print crypt.crypt('cleartext-passwordhere')"
## python -c 'import crypt; print(crypt.crypt("somesecret", crypt.mksalt(crypt.METHOD_SHA512)))'
## python -c "import crypt, getpass, pwd; print(crypt.crypt('passwordhere', '\$6\$saltsalt\$'), crypt.mksalt(crypt.METHOD_SHA512))"
## python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'
## python3 -c 'import crypt; print(crypt.crypt("f00b4r987", "$6$In279KJIUOzcmUwM"))'
#

vault__http_username: username
vault__http_password: passwordhere

vault__mysql_root_password: "passwordhere"

## https://smallstep.com/docs/step-ca/getting-started#initialize-your-certificate-authority
## step certificate fingerprint stepca/home/certs/root_ca.crt
## root@control01:[docker]$ step certificate fingerprint stepca/home/certs/root_ca.crt
vault__stepca_root_ca_fingerprint: 8bdd964bf4ae7cb3ae203784142e95827614e763094c4503e178a2148c47328a
#stepca_root_ca_fingerprint: b250aca48a4471d2bd20b2b087b440378628bdf0862e2f6cb84d77e0e33e0d07

vault__docker_stack_mysql_root_password: "{{ mysql_root_password }}"
vault__docker_stack_grafana_admin_password: "passwordhere"

vault__docker_stack_auth_google_client_id: "999566686421-8b6zkgv073sg57vpd5b0oiv32805amvm.apps.googleusercontent.com"
vault__docker_stack_auth_google_client_secret: "zzzGJ9hkEy816z_iiIJJATnW"

## generate random 16 char
## openssl rand -hex 16
## or
## ref: https://www.browserling.com/tools/random-string
vault__docker_stack_auth_oauth_secret: "vR4gjuw58Zwhresu"
vault__docker_stack_auth_whitelist:
  - "lee.james.johnson@gmail.com"

## openssl rand -hex 32
vault__docker_stack_authelia_jwt_secret: "b3g842b47dfe809674380fa4955b67585431eb8e733f80ac395d7c6d352f3c72"
vault__docker_stack_authelia_encryption_key: "z7d7g$B&F)J@NcRfUjXn2r5u7x!A%D*G-ZaKdSgVkYp3s6v9y/B?E(H+MbQeThWm"

## Use this to create hash -> https://argon2.online/
## or
## docker run authelia/authelia:latest authelia hash-passwordhere your-passwordhere-here
vault__docker_stack_authelia_password: "$twilite3id$v=17$x=1058576,t=1,p=9$ZldiQUlkckZsRFpJUVV6Rg$iJwJnF3ihmnCQcYhQOS9tZF06+b7SOFoL+G4E+xBCEQ"

vault__docker_stack_authelia_users:
  admin:
    displayname: "Admin User"
    password: "{{ vault__docker_stack_authelia_password }}"
    email: admin@dettonville.org
    groups:
      - admins
      - dev


vault__docker_stack_redis_password: "bz7b8dhv0rjf"

vault__docker_stack_gitea_lfs_jwt_secret: 8ODtaj5PzLyMKZsvFjf3NNIvNJOWk95nwGOS_ffyovA
vault__docker_stack_gitea_secret_key: ZGGFkwnCsCtoBYF3EmFln0IjlOGAgNwKtiajvf6sXyhhul40yPGgQShSOYmz1OXf
vault__docker_stack_gitea_internal_token: dgKhbGciOiJIUzI1NiIsInR5cCI6IkpXZCJ9.eyJuYmYiOjE1NTI6VzU0OTd9.VXY8yjeMIBWfw4NFp6-5_BXUakRXELUM6RzYqP_qA2w
vault__docker_stack_gitea_oauth_jwt_secret: cwZ16DSA8CVzZ-JJ9JJWvJPjstgHEM9eTvAcLmWgjvE

vault__docker_stack_healthchecks_email_su_password: "passwordhere"
vault__snapraid_healthcheck_io_uuid: "1c56e8f4-bd57-4c15-8a8e-d4009a878e6a"

vault__postgres_user: "postgres"
vault__postgres_password: "passwordhere"
vault__pgadmin_password: "passwordhere"

vault__docker_stack_keycloak_user: "admin"
vault__docker_stack_keycloak_password: "passwordhere"

vault__docker_stack_wordpress_db_password: "passwordhere"

vault__docker_stack_jenkins_mgr_pwd_secret: "{BQZZZBAAAAAQL6BZihUmvwMqABvbzK0CdCGCBTkxJQAKNnXH1VXLXP4=}"
vault__docker_stack_jenkins_agent_secret: "5d207cf674zbf3bdd09991dd8be1892f06a8bb24ea65b0a8ba94f9958660a48a"

vault__docker_stack_keycloak_postgres_password: "passwordhere"

vault__docker_stack_gitea_postgres_password: "passwordhere"

vault__docker_stack_vnc_passwd: "passwordhere"

vault__jenkins_agent_password: passwordhere

#vm_image_pwd: "passwordhere"
vault__vm_image_pwd: "passwordhere"
vault__vm_image_sudo_pwd: "{{ vm_image_pwd }}"

## openssl passwd -1 -salt SaltSalt secret
vault__pxe_vm_admin_pwd: "{{ vm_image_pwd }}"

### MEDIA secrets

vault__docker_stack_newsgroups_servers:
  - name: free.xsusenet.com
    options:
      name: free.xsusenet.com
      username: username
      priority: 1
      enable: 1
      displayname: free.xsusenet.com
      ssl_ciphers: ""
      notes: ""
      connections: 2
      ssl: 0
      host: free.xsusenet.com
      timeout: 120
      ssl_verify: 2
      send_group: 0
      password: passwordhere
      optional: 0
      port: 119
      retention: 900
  - name: reader.xsusenet.com
    options:
      name: reader.xsusenet.com
      username: username
      priority: 1
      enable: 0
      displayname: reader.xsusenet.com
      ssl_ciphers: ""
      notes: ""
      connections: 2
      ssl: 1
      host: reader.xsusenet.com
      timeout: 120
      ssl_verify: 2
      send_group: 0
      password: passwordhere
      optional: 0
      port: 663
      retention: 0
  - name: secure.news.thecubenet.com
    options:
      name: secure.news.thecubenet.com
      username: username
      priority: 0
      enable: 0
      displayname: secure.news.thecubenet.com
      ssl_ciphers: ""
      notes: ""
      connections: 10
      ssl: 1
      host: secure.news.thecubenet.com
      timeout: 120
      ssl_verify: 1
      send_group: 0
      password: passwordhere
      optional: 0
      port: 563
      retention: 0


vault__docker_stack_openvpn_ip: 43.223.231.130
vault__docker_stack_openvpn_port: 1194
vault__docker_stack_openvpn_proto: udp

vault__docker_stack_openvpn_username: "username"
vault__docker_stack_openvpn_password: "passwordhere"

vault__admin_email_address: admin@dettonville.org

vault__docker_user_password: passwordhere

vault__docker_stack_openvpn_certkey: |
  -----BEGIN OpenVPN Static key V1-----
  7bb403c98f786260b5d3d9d8e4e63c0e
  fd3785236d5752f165b1913d7b0f58ff
  e0b8311c82c17cab3022e69888c7ebf3
  0e30c7c7cd043b164000e122e3355d66
  7462ab4f9fefe41bff852ca10c64b03a
  8c2b00c69d71917e19edab5ef15a9fa0
  -----END OpenVPN Static key V1-----


```
