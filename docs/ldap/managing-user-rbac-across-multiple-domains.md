
# User RBAC Management for Multiple Domains

All host/machine user groups must be bound/derived from the LDAP/AD, except for 'DMZ' network hosts, or other possible 'detached'/'special' network host groups that cannot connect to the internal LDAP/AD?  

But even then, one can argue that there should be a separate LDAP/AD setup in each of those 'detached'/'special' networks/domains such that host/machine specific user networks/domains should never exist.

That is the way the LDAP/AD is set up for a number of large clients that I have set up/managed/used infrastructure.

In most cases, there is an 'internal' network/domain defined with a corresponding 'internal' LDAP/AD (e.g., domain '.example.int') and an 'external' network/domain (DMZ) (e.g., '.example.org', '.example.com') defined with a corresponding 'external' LDAP/AD. 

This allows/enables having a centralized RBAC for both domain use cases.   

Basically, a distinct separation between 'internal' LDAP RBAC use cases versus 'external' LDAP RBAC use cases (client facing,, B2B vendor facing, etc).

This has many benefits in terms of risk reduction, access control, meeting PCI reg requirements, etc.  Consider a case where a DoS attack is made such that it impacts the performance of the external LDAP/AD.  This would have no impact on the internal LDAP/AD since it is maintained separately inside the company internal network.

In fact, taking a step further, as was the case in the aforementioned companies, there almost always is also a another set of LDAP/AD instances corresponding to the SDLC environments (e.g., DEV, QA/TEST, PROD) to enable distinct separation of the LDAP/AD access control between each of the respective SDLC domains.  

In most cases, the company environments I have been in make use of internal subdomains (e.g., '*.dev.example.int', '*.qa.example.int') such that each subdomain is mapped to a respective network and LDAP/AD instance with distinct separation made wrt each environment with minimized risk of impact within each environment to not affect the upper environment.

It seems that is the entire point of having LDAP/AD to manage user configuration/RBAC in a centralized manner for each respective network/domain.

In this multi-domain setting with requirements for multiple LDAP instances, it becomes evident that there must be efficient methods to quickly provision/bootstrap LDAP instances upon demand as each domain is provisioned.  This is coupled with the realistic scenario that multiple domains is a given requirement. 

Towards that objective/goal, and to greatly accelerate the non-prod LDAP network domain instance setup since there can be a number of non-prod LDAP network subdomains, I set up a dockerized openldap framework to quickly enable/bootstrap non-prod LDAP instances for multiple non-prod  domains and initialize with the respective LDAP LDIF seed data.  

See the [openldap ldif jinja2 template here](https://github.com/lj020326/ansible-datacenter/blob/main/files/openldap/ldif/ldap_seed_info.ldif.j2) used to seed the openldap docker container instance for each non-prod domain. 

See the [docker-compose.yml template here](https://github.com/lj020326/ansible-datacenter/blob/main/roles/docker-stack/vars/app-services/v2/docker_stack_openldap.yml) element used by the [docker stack orchestration role](https://github.com/lj020326/ansible-datacenter/tree/main/roles/docker-stack) here. 

Note the ansible variable 'ldap_internal_base_dn' is set by the playbook that is bootstrapping the site/domain inventory.

E.g., 

```yaml
network_openldap_domains:
- dev.{{ external_root_domain }}
- qa.{{ external_root_domain }}
- dev.{{ internal_root_domain }}
- qa.{{ internal_root_domain }}
- dev.site1.{{ external_root_domain }}
- qa.site1.{{ external_root_domain }}
- dev.site2.{{ external_root_domain }}
- qa.site2.{{ external_root_domain }}
- dev.site1.{{ internal_root_domain }}
- qa.site1.{{ internal_root_domain }}
- dev.site2.{{ internal_root_domain }}
- qa.site2.{{ internal_root_domain }}
```

