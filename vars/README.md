
example vars/vault.yml:
```yaml
---
vault__machine_credentials:
  prod:
    windows_domain:
      pdc_host: domainp1s1.example.int
      username: "AnsibleDomain@example.int"
      password: "3y!3hIH$d=0Cs@5c6q+pKHzS$IRFtT"
    windows_domain_join:
      pdc_host: domainp1s1.example.int
      domain_join_dns: example.int
      username: "AnsibleDomain@example.int"
      password: "&HvT^v7NMmom33Qe9wfgFQQg%"
    windows_local_admin:
      username: "Administrator"
      password: "$g8W7&VidMAhk-Wf2LE!YQ*Ltqdf"
    windows:
      username: "ansible"
      password: "Lj9wavUg-J%^@fXGdo@!_qfC68k$&9t"
    linux:
      username: "ansible"
      password: "okBczu65L^b!GWNT!9H5%Djrt45Yl"
    linux_domain:
      username: "ansible"
      password: "M^2f&Psxph1nn-0vdIQXvS#DgEE"
    vcsa_site1:
      host: "VCSA1.example.int"
      username: "ansible-vm-provisioner"
      password: "t1vmm-VXyX&4Iz&+S%2RjC"
    vcsa_site2:
      host: "VCSA2.example.int"
      username: "ansible-vm-provisioner"
      password: "+j_L++UJ=9%kH%f^7lDI_&Ra"
  test:
    windows_domain:
      pdc_host: domainp1s1.example.int
      username: "AnsibleDomain@example.int"
      password: "mkHifT3oI-U^3zREo$p6vfM$!HN"
    windows_domain_join:
      pdc_host: domainp1s1.example.int
      domain_join_dns: example.int
      username: "AnsibleDomain@example.int"
      password: "okhm&J9LsbGSBnWEoWPRM&O*i"
    windows_local_admin:
      username: "Administrator"
      password: "&7dS%cGy!a5#&*WOn@lcRojoSZ"
    windows:
      username: "ansible"
      password: "phPwb@RbT1z!g7G^f7G^o!O+9Mub^$wi"
    linux:
      username: "ansible"
      password: "b7lg=88&55ErZP*ZGyLn+i_#yF^t&5"
    linux_domain:
      username: "ansible"
      password: "fO36CaW8#WJMFGde$sDS12Tv8"
    vcsa_site1:
      host: "VCSA1.example.int"
      username: "ansible-vm-provisioner"
      password: "qksh#sIG5aoJ#E09O4vs&%kOp"
    vcsa_site2:
      host: "VCSA2.example.int"
      username: "ansible-vm-provisioner"
      password: "ZurbUECDa6Jz-eS#*r91f!7JG"

vault__ansible_username__linux: "{{ vault__machine_credentials.prod.linux.username }}"
vault__ansible_password__linux: "{{ vault__machine_credentials.prod.linux.password }}"

## windowsRM
## https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html
## NTLM auth method
vault__ansible_username__windows: "{{ vault__machine_credentials.prod.windows.username }}"
vault__ansible_password__windows: "{{ vault__machine_credentials.prod.windows.password }}"

vault__ansible_vault_password: "@P%dsXBB_oOLsAnyTfnmS03YZynQuM^"
vault__ansible_galaxy_token: "10lq467if4t9481eph1hm52096n13203j071kz90"

## IDRAC
vault__idrac_user: "root"
vault__idrac_password: "tIrCc=h3e6B&NvAWKCh$u3QeljrsRP"

#vault__admin_public_sshkeyfile: "{{ '~/.ssh/id_rsa.pub' | expanduser }}"
#vault__admin_ssh_public_keyfile: "{{ vault__ssh_public_key | d(admin_public_sshkeyfile) }}"
#vault__ansible_ssh_public_keyfile: "{{ vault__admin_ssh_public_keyfile }}"
#vault__admin_ssh_public_key: "{{ lookup('file', vault__admin_ssh_public_keyfile) }}"
vault__admin_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  t3UtmiQcvP2fVEsmfeOCSRIZOZ0kypXOCDLScn4tDUQWDOMSNUGRAEREBkHPQQikk9coLLYlAJUx
  VXKHPPTNmL1RvdZGLNHmvrqWDg5bpiDnBpLvOl3pBeFJ3jIBUWTJAMyXBrShXBTi8FPRSQavx9un
  LCEbHRLkETGZDNQXcZ7OjcCUQKPabxeCAj9qukBpGnWrYi9fNtKS3nORXDUOLESo3orW8VbKndCL
  Plu+a58i8gdA4RQAW7LX4ztg/T6J7uCCeNTKj24DcaeJVCEyuy/PTgnqPLIAFy2r5ODxgF4yERXO
  FNYUKwDK
  -----END OPENSSH PRIVATE KEY-----

vault__admin_ssh_public_key: ssh-ed25519 AFHXO1DbaG7hBNV7HNB1JDZHHPHQwXXAb13OercLWAPimt/BFmuqRXBRXf3q2BPwcS3z
  prp@qmbm-wcp.qa-example.int-1798-11-50

vault__admin_ssh_key_type: "ed25519"

## ansible user
vault__ansible_ssh_private_key: "{{ vault__admin_ssh_private_key }}"
vault__ansible_ssh_public_key: "{{ vault__admin_ssh_public_key }}"
vault__ansible_ssh_key_type: "{{ vault__admin_ssh_key_type }}"

# openssl rand -hex 32
# openssl rand -base64 32
vault__webui_secret_key: "zJCGG@nBsn=@#@dT*s6$e$9W@3"

#---------------------
# pulp secret_key
vault__pulp_secret_key: "5FcZLHqAKdkFkNtj2FTeK*AKd"

vault__pulp_admin_username: "admin"

# must use "simple" password for DJANGO
# 32 characters from a safe alphabet
# openssl rand -hex 16
vault__pulp_admin_password: "GA9nP%l8so#UK_&FKb-2e7EB"

vault__pulp_admin_email: "admin+pulp@qa-example.int"
#vault__pulp_api_token: "Basic {{ (vault__pulp_admin_username + ':' + vault__pulp_admin_password) | b64encode }}"
vault__pulp_api_token: "{{ vault__pulp_admin_password }}"

#---------------------
# to fetch current token info from vault container:
# docker exec -it "${CONTAINER_ID}" sh -c 'openbao_info --content' | yq -P
vault__admin_password: 'lwxfg9T+@q7DHIfU8fnCov'
vault__admin_password_sha512: "{{ vault__admin_password | ansible.builtin.password_hash('sha512',65534 | random(seed=vault__user_passwd_hash_seed)
  | string) }}"
vault__root_password_sha512: "{{ vault__admin_password_sha512 }}"

vault__app_admin_password: "gvQrDOWOHfRC#9Jv#kx$&zaIQ&"
vault__app_admin_password_bcrypt: "{{ vault__app_admin_password | ansible.builtin.password_hash('bcrypt', salt=(vault__user_passwd_hash_seed
  | string | hash('sha256'))[:22]) }}"

#########################################################################
## if using sha512 (current) hash for linux user password:
##    openssl passwd -6 -salt <YOUR_SALT>
##    OR
##    python3 -c 'import crypt; print(crypt.crypt("password here", crypt.mksalt(crypt.METHOD_SHA512)))'
##    python3 -c 'import crypt; print(crypt.crypt("password here", "$6$rounds=200000$random_salt"))'
##    python3 -c 'import crypt; print(crypt.crypt("password here", "$6$rounds=656000$jF.sJku8iq0nuuvL"))'
## e.g., in ks.cfg
##   rootpw --iscrypted $6$rounds=656000$jF.sJku8iq0nuuvL...
## idempotent hash
vault__user_passwd_hash_seed: "&tXYgg_wMCexQ&yIR_dEg#w+2Q"
vault__os_build_user_password: "o4!XTSP!bUidRr%=0%5@f33JY40n-T"

vault__packer_user_username: "osbuild"
vault__packer_user_password: "yZ-&_yKD+NEcP#tuhd=gQmO3eHK+fL"
vault__packer_user_ssh_public_key: "{{ vault__admin_ssh_public_key }}"

vault__grub_secure_boot_password: '$4$LbMvb$DOgbe8ov.HXBltq07dDXG.'

vault__bind_tsig_keys_secret: "xryfFW3SbVaOVcxrJ1nvUtc=="

vault__awx_admin_password: "{{ vault__app_admin_password }}"

vault__webmin_password: "x^c0cc^J%F@OKOJ=0=#f8RUpIA_"

vault__user_credentials:
  root:
    hashed_password: "{{ vault__admin_password_sha512 }}"
    ssh_keypair:
      private: "{{ vault__admin_ssh_private_key }}"
      public: "{{ vault__admin_ssh_public_key }}"
      key_type: "{{ vault__admin_ssh_key_type }}"

  ansible:
    password: "{{ ansible_password__linux }}"
    auth_key: "{{ admin_ssh_public_key }}"
    ssh_keypair:
      private: "{{ vault__ansible_ssh_private_key }}"
      public: "{{ vault__ansible_ssh_public_key }}"
      key_type: "{{ vault__ansible_ssh_key_type }}"

  administrator:
    hashed_password: "{{ vault__admin_password_sha512 }}"
    password: "{{ vault__admin_password }}"
    auth_key: "{{ vault__admin_ssh_public_key }}"
    ssh_keypair:
      private: "{{ vault__admin_ssh_private_key }}"
      public: "{{ vault__admin_ssh_public_key }}"
      key_type: "{{ vault__admin_ssh_key_type }}"

  container-user:
    hashed_password: "{{ vault__admin_password_sha512 }}"

  media:
    hashed_password: "{{ vault__admin_password_sha512 }}"


###################
# vmware
vault__nested_esxi_password: "{{ vault__esxi_password }}"
#vault__nested_esxi_password_crypted: "{{ vault__nested_esxi_password
#  | ansible.builtin.password_hash('sha512',65534 | random(seed=vault__user_passwd_hash_seed) | string) }}"

vault__veeam_agent_password: "5dJ2RS9I!^rudZUDsaAn3hEoCW$cK"

vault__dozzle_admin_username: "admin"
# Generate with
# docker run -it --rm amir20/dozzle generate admin --password password --email me@email.net --name "Admin"
#vault__dozzle_admin_password: "{{ vault__app_admin_password | ansible.builtin.password_hash('bcrypt') }}"
vault__dozzle_admin_password: "{{ vault__app_admin_password_bcrypt }}"

## created as of 2026-09-01
## https://plugins.jetbrains.com/author/me/tokens
vault__ldap_config_pwd: "JcKsAEyD4PG7RLNH%0#%P5L=bca!jj"

## iscsi
vault__iscsi_session_auth_username: 6xIYWNIz7JVszYef
vault__iscsi_session_auth_password: 6gIce3*s@qx#XEE7Yw!htjFG^f@BD!K

vault__smbusername: "root"
vault__smbpassword: "l6!Q9prHl#-ggyu#HrzuR0M7l-M-"

vault__rndc_key: "MnalNfuDDbayBFHpX6Cxa2KPwCpbc3sZovDy34naqCrskgRVDOX31fxhlyNpv3NDUmasHLxROcFjJC3oShutAV=="
vault__omapi_key: "cZQFgJO3E3zSm5Wb6Knd+q+TdB36sUanAi+3psTejARaIr1hFEq6RSFZ6ZI/HIN7PE9gpWSzQvh/yLFu6sGE5S=="

vault__git_ssh_private_keyfile: "{{ vault__admin_ssh_private_key }}"
vault__git_ssh_public_keyfile: "{{ vault__admin_ssh_public_key }}"
vault__openstack_ssh_public_key_file: "{{ vault__admin_ssh_public_keyfile }}"

####################
# SMTP auth configs
vault__postfix_recipient_target: "admin+dcc@dettonville.org"

vault__fw_ddns_api_token: "5gPN09ik-9KcGqg8HmeZvGbLcbLIOHBaha5EXsly"

vault__ldap_root_password: "{SSHA}/RemS8gPJujXXNlOvjcptabSFqEnDGGd"
vault__ldap_config_password: "dlUXlsBkAoYmgJFv2n*0V0"
vault__ldap_admin_password: "4_VdJ83FHCw$r$^PtbB2fuWMLpH"
vault__ldap_readonly_password: "deSJwmE5O=@xha3Gb0!Z0S&Di5YZ"

vault__bind_admin_password: "yPs*gWJGi5E9ZL@lZI*YW9+J7ghi"

vault__docker_user_password: niSGleltME+dlqchK0Im2e

## basic auth bcrypt salt
## openssl rand -base64 30 | tr -dc 'A-Za-z0-9' | head -c 22
vault__basic_auth_salt: balMaioXKvkDkdtvA0aEgJ

vault__http_auth_users:
  admin:
    password: "W4tJEqQdRT1P^_*l=-f!0U8yKvd"
  ron:
    password: "Gt%BCN14!8#FNATdpq!X^FSHYv#lS"

vault__http_auth__admin_auth_key: "admin:{{ vault__http_auth_users['admin']['password'] }}"
vault__http_auth__admin_auth_key_base64: "{{ vault__http_auth__admin_auth_key | b64encode }}"

vault__registry_username: "admin"
vault__registry_password: "{{ vault__http_auth_users['admin']['password'] }}"

vault__http_auth_user_list:
  - username: "{{ vault__registry_username }}"
    password: "{{ vault__registry_password }}"
  - username: "ron"
    password: "{{ vault__http_auth_users['ron']['password'] }}"

vault__registry_users: "{{ vault__http_auth_user_list }}"

vault__mysql_root_password: "J-x-346nMmx4j%_KwSLxPW_pc4"

## https://smallstep.com/docs/step-ca/getting-started#initialize-your-certificate-authority
## step certificate fingerprint stepca/home/certs/root_ca.crt
## root@control01:[docker]$ step certificate fingerprint stepca/home/certs/root_ca.crt
vault__grafana_admin_password: "{{ vault__app_admin_password }}"

vault__authelia_jwt_secret: "l8BGIjkJ7X-eaMhSvuiPkD%CW2"
vault__authelia_encryption_key: "w9z1b$W.C%P@QgYiPlJp5e2m7t?G?S.Z-MiXeZsXiAi1v4d5o/K^J.D+ZuImVkMh"

## Use this to create hash -> https://argon2.online/
## or
## docker run authelia/authelia:latest authelia hash-password your-password-here
vault__authelia_password_raw: "{{ vault__app_admin_password }}"
vault__authelia_password: "$fcxpf1za$s=37$d=3850613,a=2,d=4$VqwzRZgikwEhAIjFHNO2Sq$kWpBhM0rgnmELuCbXII8kNH19+f7TCHoQ+M4Q+yKJZS"

vault__authelia_users:
  admin:
    displayname: "Admin User"
    password: "{{ vault__authelia_password }}"
    email: "{{ vault__postfix_recipient_target }}"
    groups:
      - admins
      - dev
vault__redis_password: "Al#7@hZBs319%z5c$Abp3UhwCf"

vault__gitea_lfs_jwt_secret: cTbeCg15Kp4EMXcd*eaO6zxu@x*8
vault__gitea_secret_key: T1R=hs0NzNQ8=Ws&Ia5qW#ALJ-xU@$*
vault__gitea_internal_token:
  qrYasEexGdMOWqK0MtWnQvH0qJP2HytWXBL8.qzRuZeZwIpX4ZSH0YkN0EGn7.iEP7ycuGVBNep1FLb6-4;HFPgpHYFYFE9IpHuF(sJ6a
vault__gitea_oauth_jwt_secret: mkpHGoEXaj=4w4AawqdFmu

vault__gitea__tokens:
  gitea.admin.example.int:
    ## user/settings/applications as of 2026-04-16
    jenkins: 151m2d46ts08q4gwh290e30l3z08g3i7pp1882r7
    ## user/settings/applications as of 2026-06-22
    ssh_rotate: s5tyw42641u3426is23c532265u6s7008552ol03
    ## user/settings/applications as of 2026-07-04
    llm_agent: ti9zm169pol3460sq3d2654s6g43h99332md8v1j
  gitea.admin.qa-example.int:
    ## user/settings/applications as of 2026-06-22
    ssh_rotate: 994ql1d84h3913618dh80163731d21udu447433j

vault__healthchecks_email_su_password: "5$Q!6&^WazAc&9wYmayyp8"

vault__jenkins_mgr_pwd_secret: "{UDBMHLLUIBAHJ4KQwjRfraQfAYaweB5YjGCQEEmeLCNFTjAC0ZBLZT9=}"

vault__jenkins_agent_secret: "tmLyZ0$HpaUqFXuEJ9ygc+6"

vault__gitea_postgres_username: "gitea"
vault__gitea_postgres_password: "jtrcSN0FlpB#uLuPwL2pVBI8!vUB"

vault__vnc_passwd: "c=C&pWEmO7ezVB#SCgzX=dvW"

vault__snapraid_healthcheck_io_uuid: "1b56n3a0-in30-4w56-9l9y-f6113j815k5j"

vault__postgres_user: "zskkecis"
vault__postgres_password: "VUH9R!L3mvGn0v6wbh5^x-o00ONW"
vault__pgadmin_password: "-pvHo5u+o^RR&ZtwjU=unyPUQ_Q@77UA"

#########
## LLM related tokens
#########

vault__hugging_face_api:
  ## full access token created on 2026-08-19
  automation_token:
    token: "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"

vault__hugging_face_token: "{{ vault__hugging_face_api['automation_token']['token'] }}"

vault__ollama_api:
  control02:
    url: "https://ollama.admin.qa-example.int"
  gpu01:
    url: "https://ollama.llm-gb10.qa-example.int"
  gpu02:
    url: "https://ollama.llm-rtx.qa-example.int"

vault__ollama_default_host: "control02"
vault__ollama_api_url: "{{ vault__ollama_api[vault__ollama_default_host]['url'] }}"
vault__ollama_api_key: "{{ vault__http_auth__admin_auth_key_base64 }}"

vault__llama_api:
  gpu01:
    url: "https://llama.llm-gb10.qa-example.int"
  gpu02:
    url: "https://llama.llm-rtx.qa-example.int"

vault__llama_default_host: "gpu02"
vault__llama_api_url: "{{ vault__llama_api[vault__llama_default_host]['url'] }}"
## openssl rand -base64 48 | tr -d '\n=' | cut -c1-64
## as of 2026-07-27
vault__llama_api_key: "trwFQa/KStpXhEUvA6JO+6kTX5r31gCIHsdDaXapbfZsidxMxgtoD7REHXsfV9UV"

vault__vllm_api:
  control02:
    url: "https://vllm.admin.qa-example.int"
  gpu01:
    url: "https://vllm.llm-gb10.qa-example.int"
  gpu02:
    url: "https://vllm.llm-rtx.qa-example.int"

vault__vllm_default_host: "gpu01"
vault__vllm_api_url: "{{ vault__vllm_api[vault__vllm_default_host]['url'] }}"

## openssl rand -base64 48 | tr -d '\n=' | cut -c1-64
## as of 2026-07-01
vault__vllm_api_key: "f1pcIfKJew+1J7ATRWtXFxKzqmpslX4aTuNQcgiBJyyc5aB8VszCz8ye1ZtugHEq"

vault__llm_api_url: "{{ vault__vllm_api_url }}"
vault__llm_api_key: "{{ vault__vllm_api_key }}"

## openssl rand -base64 48 | tr -d '\n=' | cut -c1-64
vault__langgraph_api_secret_key: "sVtw=+WLARrtI8pmx6pG5Hz3ti+K"

## created in settings/api-tokens - with full perms
vault__jenkins_agent_username: "admin"
vault__jenkins_agent_password: "{{ vault__app_admin_password }}"
vault__jenkins_swarm_agent_passwords:
  jenkins.admin.example.int: 3347x5h1u7wi25l7988ox36399304870w3
  jenkins.admin.qa-example.int: 348398h832hw16r68p758w8w30put6753i

vault__jenkins_agent_tokens:
  ## "ansible-token" as of 2026-04-17
  ## generate token here:
  ## https://jenkins.admin.johnson.int/user/admin/security/
  jenkins.admin.qa-example.int: "31359fm23055m5047e2q98091l6692k3wf"

vault__vm_image_pwd: "r%HFRx---G_iLsfryjPm8+xJ@c"
vault__vm_image_sudo_pwd: "{{ vault__vm_image_pwd }}"

## openssl passwd -1 -salt SaltSalt secret
vault__pxe_vm_admin_pwd: "{{ vault__vm_image_pwd }}"

vault__gitea_admin_username: "gitadmin"
vault__gitea_admin_password: "{{ vault__app_admin_password }}"
vault__gitea_admin_token: "46m810c0ct04a807484994457v561e6096lvcv7b"

vault__ansible_gitea_user: "gitadmin"
vault__ansible_gitea_token: 5mz4wzf46w42d886u8721j1279144b75a838h1m8

vault__healthchecks_secret_key: "%Js*SxUS8*Do@IIGAikhuEnK9N"

vault__ldap_domain_sid_root: "S-1-5-21-4431941720-3677188468-8147887253"

vault__ldap_base_user_admin_password_ssha: "{ssha}Jo7Pbqa3BD79DxsFSWvpRZzLiBgCpijz"
vault__ldap_base_user_search_password_ssha: "{ssha}IKxhBICxyKNfNVQzbqXb6Lkl/0iKA3jnm4Ag8g=="
vault__ldap_base_user_readonly_password_ssha: "{SSHA}4qBfS4rHSN84MRB91sbGEjoWdKY45nWi"

## test user password foobar!@#
vault__ldap_test_user_ssha_password: "{SSHA}JcmfxOKm/ORoy+nx2bm10QyuI7y+3Q9PIbUjwi=="
vault__ldap_test_user_nt_password: "Xu@SnaR+ox@qO$IW#^*8B3S"

vault__ldap_domain_user_map:
  root:
    ssha_password: "{SSHA}e8v729fdcMjZfiYHMZ9/4Go6Wqv2Zon="
    samba:
      nt_password: "GjRi91M9NBz@BOE&9w=u&0JHotYr"
      primary_group_sid: "{{ docker_stack__openldap__domain_admins_group_sid }}"
  netadmin:
    ssha_password: "{SSHA}u6tpcXZktE8AZQvP0XZpA8P95Jl0cqzp"
    ssh_public_key: "{{ vault__admin_ssh_public_key }}"
    samba:
      nt_password: "T2hx2wXg4hBcSvMLXzk0ftyeDRZs^g#h"
  admin:
    ssha_password: "{ssha}ZurBfiQI8tTRuuPioVBnqr7D7M2JLiJ9Jr2uOs=="
  smbguest:
    ssha_password: "{SSHA}ZNNL6VI6M86ctJL+Q8cITHOrMHMlkz=="
    samba:
      nt_password: "oTjqaim#aJb05CQzBZ+gf&Dde"
  media:
    ssha_password: "{SSHA}n3omiEXwmB1HAFlD8ZNuI7E17Iw9rxdg"
  ron:
    ssha_password: "{SSHA}DFES4CR4E70jsKD+V3nDKVIwHEPxat=="
    ssh_public_key: "{{ vault__admin_ssh_public_key }}"
    samba:
      nt_password: "%iu8L*M$Gwtr!Q_C7GFge*_$wX*w8"
  obiwan:
    username: obiwan
    uid_number: 10101
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Obi-Wan Kenobi
    given_name: Obi-Wan
    sn: Kenobi
    display_name: Obi-Wan Kenobi
    initials: OK
    mail: obiwan.kenobi@example.int
    ssha_password: "{SSHA}fWMe92aOnEn7wkD1SYpI6q6Yv2siI8On"
    samba:
      primary_group_sid: "{{ docker_stack__openldap__domain_users_group_sid }}"
      nt_password: "BQB&&SH+i%#2k3pz^YWd8L"
  legolas:
    username: legolas
    uid_number: 10103
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Legolas Greenleaf
    given_name: Legolas
    sn: Greenleaf
    display_name: Legolas Greenleaf
    initials: LG
    mail: legolas.greenleaf@example.int
    ssha_password: "{SSHA}i8bkq2qlWUaq4YvF9xbTlQWuX39ahdjwqM615v=="
    samba:
      primary_group_sid: "{{ docker_stack__openldap__domain_users_group_sid }}"
      nt_password: "rPzUnxqjramL1!^m00gPVQhL"
  frodo:
    username: frodo
    uid_number: 10102
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Frodo Baggins
    given_name: Frodo
    sn: Baggins
    display_name: Frodo Baggins
    initials: FB
    mail: frodo.baggins@example.int
    ssha_password: "{SSHA}yQ4GwBMm/GeLGDtRnlF5YElwQjUtRAj="
    samba:
      nt_password: "vYLDizIKa2K6qic9XuH4U-"

vault__ldap_domain_group_map:
  Domain Users:
    memberUidList:
      - ron
      - obiwan
      - legolas
      - frodo
    samba:
      users:
        - ron
        - obiwan
        - legolas
        - frodo
  smbuser:
    gid_number: 10001
    object_class_list:
      - top
      - posixGroup
      - sambaGroupMapping
    memberUidList:
      - media
      - ron
      - obiwan
      - legolas
      - frodo
    samba:
      groups:
        - Domain Users
  staff.django:
    cn: staff
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - ron
      - obiwan
  epgblog.django:
    cn: epgblog
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - ron
      - obiwan
  superuser.django:
    cn: superuser
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - netadmin
      - admin
      - ron
      - obiwan
  family.cloudusers:
    cn: family
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - ron
      - obiwan
      - legolas
      - frodo
  epgblog.cloudusers:
    cn: epgblog
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - admin
      - ron
      - obiwan
  nextcloud.cloudusers:
    cn: nextcloud
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - ron
      - obiwan
      - legolas
      - frodo
  superuser.cloudusers:
    cn: superuser
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - netadmin
      - admin
      - ron
      - obiwan
vault__docker_registry_username: "{{ vault__registry_username }}"
vault__docker_registry_password: "{{ vault__registry_password }}"
vault__docker_registry_admin_password: "{{ vault__registry_password }}"

vault__jenkins_admin_user_password: "Ly88$fJIjPe^7WFjbZF5_xc"
vault__jenkins_git_user_password: "LcuUTNjBpkZlS4tVB#JTp2%fd="

vault__ansible_ssh_key: "{{ vault__ansible_git_ssh_private_key }}"

vault__gitea_ssh_username: "git"
vault__gitea_ssh_private_key: "{{ vault__dettonville_ssh_private_key }}"

vault__ansible_git_ssh_private_key: "{{ vault__dettonville_ssh_private_key }}"
vault__report_inventory_facts_git_ssh_private_key: "{{ vault__bitbucket_ssh_private_key }}"
vault__test_repo_git_ssh_private_key: "{{ vault__bitbucket_ssh_private_key }}"
vault__test_repo_git_ssh_public_key: "{{ ansible_git_ssh_public_key }}"

vault__ansible_ssh_username: "{{ vault__ansible_username__linux }}"
vault__ansible_ssh_password: "{{ vault__ansible_password__linux }}"

#vault__ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') | d(ansible_ssh_pass) }}"
vault__ansible_become_password: "{{ vault__ansible_ssh_password }}"

vault__docker_hub_username: han
vault__docker_hub_token: m5u65079-909t-6055-61f2-7182k9068289
vault__docker_ci_builder_token:
  uid: han
  token: u9y45595-521x-2533-40d5-3495n9374610

```
