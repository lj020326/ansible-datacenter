```markdown
---
title: Deploy Step-CA with Ansible
original_path: roles/bootstrap_stepca/README.md
category: Documentation
tags: ansible, step-ca, acme, ca-server
---

# Deploy Step-CA with Ansible

Since the launch of Let's Encrypt, setting up an ACME CA server for internal infrastructure has been on my to-do list. This Ansible role handles the setup of Step-CA necessary packages.

## Documentation

For more information about [Step-CA](https://github.com/smallstep/step-ca), refer to their official documentation.

## Requirements

1. **Manual Creation of Issuing CA:**
   - You need to manually create your issuing CA before using this role.
   - Place the CA files in a secret folder, which will be created when you first run this role or specify an absolute path using the `secret` variable.
   
2. **DNS Records:**
   - Set up subdomain names for ACME and OCSP requests:
     - `pki.example.com` for ACME.
     - `ocsp.pki.example.com` for OCSP.
   - Configure CAA records to allow Step-CA to issue certificates.

3. **Ansible Version:**
   - Requires Ansible 2.9 or later.

4. **Operating System:**
   - Built with Debian Buster in mind, requires testing apt repo enabled.

5. **Internal DNS Server:**
   - Set up an internal DNS server for gRPC clients and Validation Authority name resolution.
   - Ensure this server does not have unrestricted internet access.

6. **Root Access:**
   - Root access is required on the target machine. Review all tasks before running the play.

## Usage

Copy the included roles to your Ansible roles directory and use as follows:

```yaml
---
- name: Sample playbook
  hosts: localhost
  
  roles:
    - role: bootstrap_stepca
      vars:
        # Optional. Software install directories.
        install_root: /opt/stepca
        src_root: /opt/stepca-src
        ct_install_root: /opt/ctgo
        ct_src_root: /opt/ctgo-src
        trillian_install_root: /opt/trillian
        trillian_src_root: /opt/trillian-src
        
        # Optional. Change these releases vars to use updated source code.
        current_release: release-2020-02-03
        ct_current_release: tags/v1.1.0
        trillian_current_release: master

        # Required. Place your CA in secret/certificates/{{ ansible_facts['fqdn'] }}/issuing
        issuing_ca_crtname: name.pem
        issuing_ca_keyname: name.key
        
        # Required.
        ca_database_name: ca
        ctlog_database_name: ct
        
        # Optional. Set False to avoid overhead of running a full CT log.
        stepca_ca_server: True

        # Required when stepca_ca_server is True.
        ctlog_sharding: False
        ctlog_shards:
          - prefix: example
            start: 0
            end: 0
            root: "{{ issuing_ca_crtname }}"
        
        # Required. Provide your resolver *and* port.
        va_resolvers:
          - 127.0.0.1:53
        
        # Required for custom environments.
        ca_policies:
          caa_domain: example.com
          valid_duration: 2160h
          cp_oid: 2.5.29.32.0
          ocsp_domain: ocsp.pki.example.com
          cps_url: http://pki.example.com/cps
          tos_url: http://pki.examples.com/tos
        
        # Required. Set to where you're hosting the ACME endpoints.
        api_domain: pki.example.com

        # Optional. This is meta.website in the ACME directory.
        company_homepage: example.com
```

For more control over issuing policies, refer to `$(install_root)/config/*.yml`.

## Resource Usage

This server does not require significant resources; 1GB of RAM should suffice.

```shell
top - 21:15:47 up 24 days, 20:43,  1 user,  load average: 0.01, 0.04, 0.04
Tasks: 131 total,   1 running, 130 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.5 us,  0.3 sy,  0.0 ni, 99.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   3946.2 total,    191.0 free,    489.7 used,   3265.6 buff/cache
```

## Certificate Transparency Log Viewer

Since there is no open-sourced CT log viewer available, you can use `ctclient` from the certificate-transparency-go package to view issued certificates:

```shell
/opt/ctgo$ ./ctclient -log_uri http://127.0.0.1:4011/prefix sth
2020-02-06 17:55:21.394 +0800 CST (timestamp 1580982921394): Got STH for V1 log (size=n) at http://127.0.0.1:4011/prefix, hash ...
Signature: Hash=SHA256 Sign=ECDSA Value=...
/opt/ctgo$ ./ctclient -log_uri http://127.0.0.1:4011/prefix -first 0 -last n-1 getentries | grep Subject:
        Subject: CN=...
        Subject: CN=...
        ...
```

## Additional Roles

You can use the included `caddy2` role separately by supplying Caddyfile content to `vars.Caddyfile`.

## Backlinks

- [Ansible Playbooks](https://github.com/your-repo/playbooks)
- [Step-CA Documentation](https://smallstep.com/docs/)
```

This improved version maintains all original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.