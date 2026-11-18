# Vault Variables Reference (`vars/vault.yml`)

This document explains how to populate and structure credentials, keys, hashes, and service secrets in `vars/vault.yml` for the `ansible-datacenter` repository.

> **Important:** Every secret, token, key, password, and hash in the example below is a **synthetic placeholder value** provided strictly to illustrate expected formats, types, and Jinja2 variable references. Never deploy with placeholder/example values—replace them with real secrets and encrypt `vars/vault.yml` with `ansible-vault` before committing.
>
> **Secret Scanning (`gitleaks`):** This file (`vars/README.md`) is intentionally excluded via `.gitleaks.toml` (`vars/README\.md$`) because it contains illustrative example syntax and mock credentials for documentation purposes only. Do **not** place real production credentials or actual private keys in this README.

---

## How to Add & Format Values in `vars/vault.yml`

1. **Follow the `vault__` Prefix Convention:**
   Top-level vault variables use the `vault__` prefix (often followed by a component/service namespace and double underscores in nested maps, such as `vault__llm__vllm_api_key` or `vault__gitea__tokens`). Keep naming consistent so roles and playbooks can reliably look up or override them.

2. **Match the Expected Data Type & Encoding:**
   - **Plaintext / Secret Strings:** Quote strings containing special YAML/Jinja characters (such as `:`, `{`, `}`, `[`, `]`, `#`, `&`, `*`, `!`, `%`, `@`, `=`, `+`, `/`) to prevent YAML parsing errors.
   - **Multiline SSH Keys & PEM/Cert Blocks:** Use YAML block scalars (`|` for literal newlines, preserving line breaks) so OpenSSH private keys or certificates remain intact. Public keys typically appear as single-line strings (e.g., `ssh-ed25519 ...`).
   - **Password Hashes (`sha512`, `bcrypt`, `{SSHA}`, `{ssha}`, NT hashes):** Generate hashes using the appropriate algorithm/format expected by the target OS, LDAP directory, or auth service rather than storing raw passwords where a hash is required.

3. **Coalesce & Reuse Values via Jinja2 References:**
   Rather than duplicating secrets across dozens of variables, `vars/vault.yml` uses Jinja2 expressions to derive, compose, or fall back across related variables:
   - **Direct Aliasing / Defaults:** e.g., `vault__awx_admin_password: "{{ vault__app_admin_password }}"` or `vault__vm_image_sudo_pwd: "{{ vault__vm_image_pwd }}"`.
   - **Deterministic Hashing & Salting:** e.g., generating `sha512` or `bcrypt` hashes from a base password and a seed (`vault__passwd_hash_seed`).
   - **Encoding & Composite Secrets:** e.g., combining `username:password` and applying `| b64encode` for basic auth headers or API tokens.
   - **Map / Host Selection Coalescing:** e.g., defining environment/host dictionaries (`prod` vs. `test`, or hosts like `control02`, `gpu01`, `gpu02`) and selecting the active endpoint/credential dynamically using a selector variable such as `vault__llm__vllm_default_host`.

4. **Encrypt Before Committing:**
   Encrypt the file in place using Ansible Vault:
   ```bash
   ansible-vault encrypt vars/vault.yml
   ```
   To edit an existing encrypted vault file:
   ```bash
   ansible-vault edit vars/vault.yml
   ```

---

## Example `vars/vault.yml` (Placeholder Reference)

```yaml
---
vault__bind_admin_password: "!vHU3t22v#1lwYlI8w5kwdVyg^G"
vault__bind_tsig_keys_secret: "VUkat%s2NzvjGA5*PTo$ZfP&e"
vault__dhcp_omapi_key: "qADMqQW0E7tHk3Gh3Vun+y+BmF97kOifOp+2uyTneGWtRa2gVPx5XLFS9FT/WQD8WT7joBWlJwi/wPWy2gWM9J=="
#   rndc_key:
#   DNS update key, generated with `rndc-confgen -a -b 512 -r /dev/urandom`
#   stored in ansible vault
vault__dhcp_rndc_key: "EtgnJdxIOxexMUPbV4Vko0RCjCwjg5yNuvDh73mzrLaaiiRIJIL61dzjygWla0DSHbiyZXmHZyZqLM4mEhvqTI=="

vault__fw_ddns_api_token: "7hMM28sh-5BaHuk7EkoSkNcLvyTENZTloz9ATomm"
vault__grub_secure_boot_password: '$9$ZrAyh$DZsth1wr.TDJvpw68rJGD.'
vault__healthchecks_email_su_password: "l16ueQ5*b3OQrn+vvx861&$xj_+"
vault__healthchecks_secret_key: "qcd9SR0s6xwX_TEko#F=pjutPIB_7c*g"
vault__idrac_password: "i5jr&9%zV71Ylm98Q4tJCO*_r"
vault__idrac_user: "root"

#---------------------
# iscsi
vault__iscsi_session_auth_password: q=njI_C44-1p$L3px-uV#zN$p0Fb!o3
vault__iscsi_session_auth_username: 4zCHITQw2QNvuKyq
vault__langgraph_api_secret_key: "cHVb$R6AF#_6s2WJVkU4kRv938^NeO8Q"
vault__mysql_root_password: "w9ttu5^N&X@zxZN8JmPK_#2lC*XyZC8u"
vault__openstack_ssh_public_key_file: "{{ vault__admin_ssh_public_keyfile }}"
vault__os_build_user_password: "Ri1197CUX1^VEhyCWkqmD6-j"

#---------------------
# Idempotent hash
# if using sha512 (current) hash for linux user password:
#    openssl passwd -6 -salt <YOUR_SALT>
#    OR
#    python3 -c 'import crypt; print(crypt.crypt("password here", crypt.mksalt(crypt.METHOD_SHA512)))'
#    python3 -c 'import crypt; print(crypt.crypt("password here", "$6$rounds=200000$random_salt"))'
#    python3 -c 'import crypt; print(crypt.crypt("password here", "$6$rounds=656000$jF.sJku8iq0nuuvL"))'
# e.g., in ks.cfg
#   rootpw --iscrypted $6$rounds=656000$jF.sJku8iq0nuuvL...
vault__passwd_hash_seed: "#m^F4@3GHaDh3FCCK^WlN7Pe+ZXx2pd"

#---------------------
# Admin password
#
# By default, "openssl passwd" will use an md5 algorithm for your password hash.
# md5 is type 1
# sha512 is type 6
#
# openssl passwd -1 -salt SaltSalt secret
# openssl passwd -1
# openssl passwd -6 -salt In279KJIUOzcmUwM f00b4r987
# echo 'cleartext-password' | openssl passwd -1 -stdin
#
# To hash a sha512 password (salt type 6):
# openssl passwd -6 -salt In279KJIUOzcmUwM f00b4r987
#
# If you’re looking for sha256 or sha512 hash you can also use this python code
# refs:
#   https://ma.ttias.be/how-to-generate-a-passwd-password-hash-via-the-command-line-on-linux/
#   https://unix.stackexchange.com/questions/52108/how-to-create-sha512-password-hashes-on-command-line
#
# python -c "import crypt; print crypt.crypt('cleartext-password')"
# python -c 'import crypt; print(crypt.crypt("somesecret", crypt.mksalt(crypt.METHOD_SHA512)))'
# python -c "import crypt, getpass, pwd; print(crypt.crypt('password', '\$6\$saltsalt\$'), crypt.mksalt(crypt.METHOD_SHA512))"
# python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'
# python3 -c 'import crypt; print(crypt.crypt("f00b4r987", "$6$In279KJIUOzcmUwM"))'
#
# ref: https://stackoverflow.com/questions/19292899/creating-a-new-user-and-password-with-ansible
vault__admin_password: '0B&VOhU9RlsE4&d&Ihnv_KJZbq5qkY6t'
vault__admin_password_sha512: "{{ vault__admin_password | ansible.builtin.password_hash('sha512',65534 | random(seed=vault__passwd_hash_seed)
  | string) }}"
vault__admin_ssh_key_type: "ed25519"

#---------------------
# admin ssh keys
#vault__admin_public_sshkeyfile: "{{ '~/.ssh/id_rsa.pub' | expanduser }}"
#vault__admin_ssh_public_keyfile: "{{ vault__ssh_public_key | d(admin_public_sshkeyfile) }}"
#vault__ansible_ssh_public_keyfile: "{{ vault__admin_ssh_public_keyfile }}"
#vault__admin_ssh_public_key: "{{ lookup('file', vault__admin_ssh_public_keyfile) }}"
vault__admin_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  c2GkrtYnzV5pZOcphjZDCTEPAF5mtoQQKBYXif6bHNQVOLPZDTJWUOVHYlWROKtnv1qnNSDjGDYc
  AOPKOKJKnI5XciRRYHDgpfpXJf7mbsVmNnOkEx3nMnIR6eKSDGFIMFkWRhFlXJWg5EUCHKvhe0jo
  RKAgDFHdUJOVDUMRyA0OccFRAFYwygvEGe0fbrAkGoUdYd1qUkIX8uCISIXIDROg7tgK3ThLsvFR
  Gun+h39m8xnN0KMBL3YJ1vyl/R3S8wAVyVJXx51TfcuOKXKrhr/JUuhvTZWKRs7w3QBuqO8fGJTE
  TBINVgGB
  -----END OPENSSH PRIVATE KEY-----

vault__admin_ssh_public_key: ssh-ed25519 CWTUH8OhoD1vSVB9UKG9SWNZPHENsZCPy44QjipHRDGbbz/RAzpeWZMYFg1a5ULwoW6o
  mzmvrv@hget-vpb.qa-example.int-4502-11-34

vault__app_admin_password: "nwWibK1_!+0Wgv-T#j6oxH"
vault__app_admin_password_bcrypt: "{{ vault__app_admin_password | ansible.builtin.password_hash('bcrypt', salt=(vault__passwd_hash_seed
  | string | hash('sha256'))[:22]) }}"

vault__awx_admin_password: "{{ vault__app_admin_password }}"
vault__ansible_galaxy_token: "40bo076ua6s8028bxy3gu24278s49343k066fd44"

vault__ansible_git_ssh_private_key: "{{ vault__dettonville_ssh_private_key }}"
vault__ansible_gitea_token: 5qp6dtu33k78w764e6506x0975207o80u737e0h4
vault__ansible_gitea_user: "gitadmin"

#---------------------
# ansible host credentials
vault__ansible_host_credentials:
  prod:
    windows_domain:
      pdc_host: domainp1s1.example.int
      username: "AnsibleDomain@example.int"
      password: "bU6fF2zo_+DJOs9Vsjcn@0LoygsZ"
    windows_domain_join:
      pdc_host: domainp1s1.example.int
      domain_join_dns: example.int
      username: "AnsibleDomain@example.int"
      password: "DVPfv9BPhZI-+1Z5*idVVyk7rb_X"
    windows_local_admin:
      username: "Administrator"
      password: "5CW8rP^vx*_t4HqI8IXW%+Ncic9B"
    windows:
      username: "ansible"
      password: "I*Vt*tTPaDv&us#^oBvmn9C"
    linux:
      username: "ansible"
      password: "7cTVO2v_AHXtm3*B3&%YS^Z8e"
    linux_domain:
      username: "ansible"
      password: "0-=b!&b*^P*4bm7AEBxa^SepM"
    vcsa_site1:
      host: "VCSA1.example.int"
      username: "ansible-vm-provisioner"
      password: "+@R5ce5ZMAwwnpE+&l*NX3nHGYHk="
    vcsa_site2:
      host: "VCSA2.example.int"
      username: "ansible-vm-provisioner"
      password: "_b%^*MZI9EK2^Jy0K@tav7-"
  test:
    windows_domain:
      pdc_host: domainp1s1.example.int
      username: "AnsibleDomain@example.int"
      password: "tOaQZDUa&7XZ1fw-2T50#JWyJD7"
    windows_domain_join:
      pdc_host: domainp1s1.example.int
      domain_join_dns: example.int
      username: "AnsibleDomain@example.int"
      password: "2HBqd!Qx75ax#c+^wOShiBx4p#!"
    windows_local_admin:
      username: "Administrator"
      password: "FtORCZz%L!$WBUj5yBmnQrTja+e8tW"
    windows:
      username: "ansible"
      password: "Oxzdx@_^DlsXmgLr9fg^Dtf"
    linux:
      username: "ansible"
      password: "y^HC9qbaI=Wo=H8hcN4Qq=j^#T_uDg"
    linux_domain:
      username: "ansible"
      password: "TmTCv0e#5mkjqNVKCaC!5DIjA4JWBlj"
    vcsa_site1:
      host: "VCSA1.example.int"
      username: "ansible-vm-provisioner"
      password: "aOQRdV6yq4AXt9o9i5m3hNsW$"
    vcsa_site2:
      host: "VCSA2.example.int"
      username: "ansible-vm-provisioner"
      password: "D=kOHkioAFfxPl*D$@hp10%83"

#---------------------
# Ansible host credentials
vault__ansible_credential__linux__password: "{{ vault__ansible_host_credentials.prod.linux.password }}"
vault__ansible_credential__linux__username: "{{ vault__ansible_host_credentials.prod.linux.username }}"

# windowsRM
# https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html
# NTLM auth method
vault__ansible_credential__windows__password: "{{ vault__ansible_host_credentials.prod.windows.password }}"
vault__ansible_credential__windows__username: "{{ vault__ansible_host_credentials.prod.windows.username }}"
vault__ansible_ssh_key: "{{ vault__ansible_git_ssh_private_key }}"
vault__ansible_ssh_key_type: "{{ vault__admin_ssh_key_type }}"

vault__ansible_ssh_password: "{{ vault__ansible_credential__linux__password }}"

#vault__ansible_ssh_password: "{{ lookup('env','ANSIBLE_SSH_PASSWORD') | d(ansible_ssh_pass) }}"
vault__ansible_become_password: "{{ vault__ansible_ssh_password }}"

#---------------------
# ansible ssh keys
vault__ansible_ssh_private_key: "{{ vault__admin_ssh_private_key }}"
vault__ansible_ssh_public_key: "{{ vault__admin_ssh_public_key }}"
vault__ansible_ssh_username: "{{ vault__ansible_credential__linux__username }}"

#---------------------
# ansible vault
vault__ansible_vault_password: "K1@jF#nuY@dwW86q@y5CeNDKKF&v%Uz5"
vault__dozzle_admin_password: "{{ vault__app_admin_password_bcrypt }}"
vault__dozzle_admin_username: "admin"

#---------------------
# git
vault__git_ssh_private_keyfile: "{{ vault__admin_ssh_private_key }}"
vault__git_ssh_public_keyfile: "{{ vault__admin_ssh_public_key }}"

#---------------------
# Gitea
vault__gitea__tokens:
  gitea.admin.example.int:
    ## user/settings/applications as of 2026-04-16
    jenkins: 536s6v55ze13b0pco531t98b3u45q5m8si4988m0
    ## user/settings/applications as of 2026-06-22
    ssh_rotate: x1tji77968t8341ca03e876323a0q0302208ab45
    ## user/settings/applications as of 2026-07-04
    llm_agent: gl2rq356dlp0490hl2m6364g2e15g86768bg1i2o
  gitea.admin.qa-example.int:
    ## user/settings/applications as of 2026-06-22
    ssh_rotate: 666nf4i15z2713387bg54623234t10ynj569817c

vault__gitea_admin_password: "{{ vault__app_admin_password }}"
vault__gitea_admin_token: "52d266n8uj41e612639744944o241d3663pjuj7r"
vault__gitea_admin_username: "gitadmin"
vault__gitea_internal_token:
  qeCkgZwaLvUEWiW1OnLsQpC0oQZ0YvmJTHX5.ldNvLwRyDkD0FUO7ZlR9GGk5.gRY4xcjXFGXhn1MMn5-6|ZEJjsHNCNID5JxCdJ#mS1k
vault__gitea_lfs_jwt_secret: +D=QHeNoQilG#+Iy8Ja&hkt_Z8GrFU
vault__gitea_oauth_jwt_secret: Ilpp#8-3ou7v^%PsLSPtrmoeowxb
vault__gitea_postgres_password: "t=9^B=D%^w6b@qXSmW8vPajsmF*P1"
vault__gitea_postgres_username: "gitea"
vault__gitea_secret_key: 7QxR0+1iTyqZBb^moBPKpx
vault__gitea_ssh_private_key: "{{ vault__dettonville_ssh_private_key }}"
vault__gitea_ssh_username: "git"

vault__grafana_admin_password: "{{ vault__app_admin_password }}"

#---------------------
# Jenkins
vault__jenkins_admin_user_password: "p0=9N#S&UJnvX+QxHT9hbm"
vault__jenkins_agent_password: "{{ vault__app_admin_password }}"
vault__jenkins_agent_secret: "mVv$m#h7OLV0LeVi#UgODM7a5*FD"
vault__jenkins_agent_tokens:
  ## "ansible-token" as of 2026-04-17
  ## generate token here:
  ## https://jenkins.admin.qa-example.int/user/admin/security/
  jenkins.admin.qa-example.int: "00460cs45414r6391l4g48044e0771i2vd"
vault__jenkins_agent_username: "admin"
vault__jenkins_git_user_password: "xc@xZ+BX5WncqbDApaLm^wmoWh^cYTo"

vault__jenkins_mgr_pwd_secret: "{IPZWDSHLIPGTZ3MAdxGeqcDqRWfuxW3WlUYXUEaeCICXIbRE7ZHBYE5=}"
vault__jenkins_swarm_agent_passwords:
  jenkins.admin.example.int: 0534q0j9z9bb79m0147zv53512301184t0
  jenkins.admin.qa-example.int: 963967a349cn25p62l025n1o08jmu6905i
vault__ldap_admin_password: "5*O+9IhA3_bz-HSQ$inP6Ah8X16ies7t"
vault__ldap_base_user_admin_password_ssha: "{ssha}Nz5Unlt4FL21FgaBYFklJClQbSaFcsso"
vault__ldap_base_user_readonly_password_ssha: "{SSHA}5wDcS2iYYR61MKQ39qxBVyvYiEO89cJn"
vault__ldap_base_user_search_password_ssha: "{ssha}ZDqfBKWknTGaHCVmbjMp4Rjz/8dZI0ino8Vj6t=="
vault__ldap_config_password: "pwMhem19Kl8AhRInrkDO*_W"
vault__ldap_config_pwd: "gWg&7Dbt2q=uA9pNbewch$2b03F"

vault__ldap_domain_group_map:
  Domain Users:
    memberUidList:
      - obiwan
      - ron
      - aragorn
      - harry
    samba:
      users:
        - obiwan
        - ron
        - aragorn
        - harry
  smbuser:
    gid_number: 10001
    object_class_list:
      - top
      - posixGroup
      - sambaGroupMapping
    memberUidList:
      - media
      - obiwan
      - ron
      - aragorn
      - harry
    samba:
      groups:
        - Domain Users
  ## DJANGO app dev team
  staff.django:
    cn: staff
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - obiwan
      - ron
  epgblog.django:
    cn: epgblog
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - obiwan
      - ron
  superuser.django:
    cn: superuser
    parent_ou: "ou=django,ou=applications,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - netadmin
      - admin
      - obiwan
      - ron
  family.cloudusers:
    cn: family
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - obiwan
      - ron
      - aragorn
      - harry
  epgblog.cloudusers:
    cn: epgblog
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - admin
#      - administrator
      - obiwan
      - ron
  nextcloud.cloudusers:
    cn: nextcloud
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - obiwan
      - ron
      - aragorn
      - harry
  superuser.cloudusers:
    cn: superuser
    parent_ou: "ou=cloudusers,ou=groups"
    object_class_list:
      - top
      - groupOfNames
    memberDnList:
      - netadmin
      - admin
      - obiwan
      - ron

vault__ldap_domain_sid_root: "S-1-5-21-6218482505-5115771482-2354613626"

vault__ldap_domain_user_map:
  root:
    ssha_password: "{SSHA}k8u206aovPsKllXKCP7/6Qm0Tbh3Fzz="
    samba:
      nt_password: "dU&8iPeei8TRw*OJ1ABSuO25YY*PtlN"
      primary_group_sid: "{{ docker_stack__openldap__domain_admins_group_sid }}"
  netadmin:
    ssha_password: "{SSHA}a7yrcRLufS2VOPoS2JHyZ7N40Ko8cvra"
    ssh_public_key: "{{ vault__admin_ssh_public_key }}"
    samba:
      nt_password: "HiL0ju=8R+U5yxwGnlr9YqE"
  admin:
    ssha_password: "{ssha}VdqEsdYN2tDHrfJahPBtmx1Y4A9BZaM3Tx4vVu=="
  smbguest:
    ssha_password: "{SSHA}LTTJ6BV7T29pyFX+R5jXFUJxNZAljp=="
    samba:
      nt_password: "7LZ0t8-F^-93xU!61%z6V6kkTMM6"
  media:
    ssha_password: "{SSHA}h1lfiENlnB4OJBcY6KBiT0O42Lk0ikvo"
  obiwan:
    ssha_password: "{SSHA}JKCY4OW9N24naRW+C3mSEGFgWAHxnj=="
    ssh_public_key: "{{ vault__admin_ssh_public_key }}"
    samba:
      nt_password: "ixps*e+b+00ZLC6$QB#j0Ka_Ny%M"
  ron:
    username: ron
    uid_number: 10101
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Ron Weasley
    given_name: Ron
    sn: Weasley
    display_name: Ron Weasley
    initials: RW
    mail: ron.weasley@example.int
    ssha_password: "{SSHA}fUTd68dIaVr9mcG8ENuZ9h1Rb7qnX5Pn"
    samba:
      primary_group_sid: "{{ docker_stack__openldap__domain_users_group_sid }}"
      nt_password: "X!Pl3a!oRyh8xtA7DR!^bz"
  aragorn:
    username: aragorn
    uid_number: 10103
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Aragorn Elessar
    given_name: Aragorn
    sn: Elessar
    display_name: Aragorn Elessar
    initials: AE
    mail: aragorn.elessar@example.int
    ssha_password: "{SSHA}q9nea6dvNFrh5QnT3ksWjXQaK32xplgxsF183p=="
    samba:
      primary_group_sid: "{{ docker_stack__openldap__domain_users_group_sid }}"
      nt_password: "1Wo$b@a%LP@ZS1$dUYCFC+dAR#k"
  harry:
    username: harry
    uid_number: 10102
    gid_number: "{{ docker_stack__openldap__users_gid_number }}"
    cn: Harry Potter
    given_name: Harry
    sn: Potter
    display_name: Harry Potter
    initials: HP
    mail: harry.potter@example.int
    ssha_password: "{SSHA}lN6MsQIj/IvSRJdBlwV0VHqgWuEnTWu="
    samba:
      nt_password: "xe$7Ck*pRfwNql3U2WrSG!&OT8a"

vault__ldap_readonly_password: "=J19oDOlmMv&oI8I3JD*WP$Ptq"

vault__ldap_root_password: "{SSHA}/SuxE4rZLbuUBYfYcjqpvgvGFeBgFBVq"
vault__ldap_test_user_nt_password: "rEjEI$!#lzNZhGU-G6Rc!dh!Qy9Yv!Bv"
## test user password foobar!@#
vault__ldap_test_user_ssha_password: "{SSHA}OvjfrBWy/FVuc+yj6na05YeoJ4e+1S2ZUgKtto=="

#---------------------
# Packer
vault__packer_user_password: "qtnI!mf2%+hbQff8IPuw&b_Aqw1"
vault__packer_user_ssh_public_key: "{{ vault__admin_ssh_public_key }}"
vault__packer_user_username: "osbuild"
vault__pgadmin_password: "3%B@M%hf%9DOgjXAwB7f9ZU"
vault__postfix_recipient_target: "admin+dcc@dettonville.org"

#---------------------
# Authelia
vault__authelia_encryption_key: "x5e1r$A#E[Y@OnDtCbEz3a9e0r)T[P>L-DyEiPqBrFc7g0x7w/D(F&X+YaPkEnKu"

# openssl rand -hex 32
vault__authelia_jwt_secret: "%XePF8fT&0Lv#$-m@zHVJ+"

vault__authelia_password: "$jlfop9oi$f=21$x=5024137,q=5,p=0$GslvPXrardNlIQaSXUV5Vf$zCkMfJ7enkeWTiCaHRZ8pTP75+q7QODvF+W6A+lAROY"

## Use this to create hash -> https://argon2.online/
## or
## docker run authelia/authelia:latest authelia hash-password your-password-here
vault__authelia_password_raw: "{{ vault__app_admin_password }}"

vault__authelia_users:
  admin:
    displayname: "Admin User"
    password: "{{ vault__authelia_password }}"
    email: "{{ vault__postfix_recipient_target }}"
    groups:
      - admins
      - dev

#---------------------
# postgres
vault__postgres_password: "5cm$#hRg!X$AaadZWHGjR*u="
vault__postgres_user: "jtrncaax"

#---------------------
# pulp secret_key
vault__pulp_admin_email: "admin+pulp@qa-example.int"
# must use "simple" password for DJANGO
# 32 characters from a safe alphabet
# openssl rand -hex 16
vault__pulp_admin_password: "#bBR3$MuX7RAwhZtRS+LQH%t0TTf"
vault__pulp_admin_username: "admin"
#vault__pulp_api_token: "Basic {{ (vault__pulp_admin_username + ':' + vault__pulp_admin_password) | b64encode }}"
vault__pulp_api_token: "{{ vault__pulp_admin_password }}"
vault__pulp_secret_key: "$p4Wz$Z-leqiAF5KVujVYxX"
vault__redis_password: "ouZh%V3VsJpoB@edTHvQHCg-LPID"

vault__report_inventory_facts_git_ssh_private_key: "{{ vault__bitbucket_ssh_private_key }}"

vault__root_password_sha512: "{{ vault__admin_password_sha512 }}"

#---------------------
# Samba
vault__smb_password: "nWYUeHGJdpbB+*e^wccpG75"
vault__smb_username: "root"

vault__snapraid_healthcheck_io_uuid: "6l09a4h9-gx50-0b59-5i7w-k5645u922g7a"
vault__test_repo_git_ssh_private_key: "{{ vault__bitbucket_ssh_private_key }}"
vault__test_repo_git_ssh_public_key: "{{ ansible_git_ssh_public_key }}"

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

#---------------------
# Veeam
vault__veeam_agent_password: "Epm8=Ti!V^64PiONovL5TxkcsyG"
vault__vm_image_pwd: "*NuZuEPzcW_mO2KpYe20XiMXIQ$&EO*^"
vault__vm_image_sudo_pwd: "{{ vault__vm_image_pwd }}"

## openssl passwd -1 -salt SaltSalt secret
vault__pxe_vm_admin_pwd: "{{ vault__vm_image_pwd }}"
vault__vnc_passwd: "Wcs6LCU-V*y7YCLXIXGKyNk"

#---------------------
# Webmin
vault__webmin_password: "YFTCO9D1btbku0RwgXjF%8@A!"

# openssl rand -hex 32
# openssl rand -base64 32
vault__webui_secret_key: "4iwkeFZwHKQx1xVc_iTErp$LTu@*PE"
vault__basic_auth_salt: xsfEjjcYIpkQzyncS8pNyR

vault__basic_auth_users:
  admin:
    password: "!iYArTXi#a_dFUPfjM$zEuPso6HqM8"
  obiwan:
    password: "l13kyGHbFFqBnmCmp@b6Lx+oJBJO"

vault__basic_auth_admin_auth_key: "admin:{{ vault__basic_auth_users['admin']['password'] }}"
vault__basic_auth_admin_auth_key_base64: "{{ vault__basic_auth_admin_auth_key | b64encode }}"

vault__basic_auth_user_list:
  - username: "{{ vault__docker__registry_username }}"
    password: "{{ vault__docker__registry_password }}"
  - username: "obiwan"
    password: "{{ vault__basic_auth_users['obiwan']['password'] }}"

#---------------------
# docker registry
vault__docker__registry_password: "{{ vault__basic_auth_users['admin']['password'] }}"
vault__docker__registry_admin_password: "{{ vault__docker__registry_password }}"
vault__docker__registry_username: "admin"
vault__docker__registry_users: "{{ vault__basic_auth_user_list }}"
vault__docker__user_password: tb2Hm2XUe7fT-vt_9bYT$4O@IR!33

#---------------------
# docker hub
vault__docker_hub__ci_builder_token:
  uid: han
  token: r5r69654-209k-2913-74r4-9900t7868866
vault__docker_hub__token: o5h09726-256v-0723-41k4-2764m2061630
vault__docker_hub__username: han

#---------------------
# LLM Llama.cpp
vault__llm__llama_api:
  gpu01:
    url: "https://llama.llm-gb10.qa-example.int"
  gpu02:
    url: "https://llama.llm-rtx.qa-example.int"

## openssl rand -base64 48 | tr -d '\n=' | cut -c1-64
## as of 2026-07-27
vault__llm__llama_api_key: "piwZFr/WDdrPnLMcN4JA+0sZX2x33dFBYufJwGyrjuVgrhaQrkmaD8GRVKkkF8LN"

vault__llm__llama_default_host: "gpu02"
vault__llm__llama_api_url: "{{ vault__llm__llama_api[vault__llm__llama_default_host]['url'] }}"

#---------------------
# LLM Ollama
vault__llm__ollama_api:
  control02:
    url: "https://ollama.admin.qa-example.int"
  gpu01:
    url: "https://ollama.llm-gb10.qa-example.int"
  gpu02:
    url: "https://ollama.llm-rtx.qa-example.int"

vault__llm__ollama_api_key: "{{ vault__basic_auth_admin_auth_key_base64 }}"
vault__llm__ollama_default_host: "control02"
vault__llm__ollama_api_url: "{{ vault__llm__ollama_api[vault__llm__ollama_default_host]['url'] }}"

#---------------------
# LLM vLLM
vault__llm__vllm_api:
  control02:
    url: "https://vllm.admin.qa-example.int"
  gpu01:
    url: "https://vllm.llm-gb10.qa-example.int"
  gpu02:
    url: "https://vllm.llm-rtx.qa-example.int"

## openssl rand -base64 48 | tr -d '\n=' | cut -c1-64
## as of 2026-07-01
vault__llm__vllm_api_key: "w2yrGrSJbt+8I4XZGGsEGaPxwmpotC3oBrWNodkGUhyq8zU3TimMt7il5OzxhWRi"

vault__llm__vllm_default_host: "gpu01"
vault__llm__vllm_api_url: "{{ vault__llm__vllm_api[vault__llm__vllm_default_host]['url'] }}"

vault__llm_api_key: "{{ vault__llm__vllm_api_key }}"
vault__llm_api_url: "{{ vault__llm__vllm_api_url }}"
```
