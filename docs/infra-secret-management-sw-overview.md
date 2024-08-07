
# Infrastructure Secret Management Software Overview

Currently, there is an explosion of tools that aim to manage secrets for automated, cloud native
infrastructure management. Here is a recent effort to summarize the various tools.

This is an attempt to give a quick overview of what can be found out there. The list is alphabetical.
There will be tools that are missing, and some of the facts might be wrong--I welcome your corrections.
For the purpose, I can be reached via @lj020326 on Twitter, or just leave me a comment here.

Below is feature matrix of various tools, also available in [excel](./infra-secret-management-sw-feature-matrix.xlsx).

| Software                                  | Flexible, Per Service access control                             | Secret Generators, Temporary Secrets | Versioning (store multiple versions, rollback, rollover) | Notify client on secret change | Editing Options | Audit                              | Presentation                            | Bindings                                                   | Supports multiple cloud providers | Highly Available               | Notes                                             |
|-------------------------------------------|------------------------------------------------------------------|--------------------------------------|----------------------------------------------------------|--------------------------------|-----------------|------------------------------------|-----------------------------------------|------------------------------------------------------------|-----------------------------------|--------------------------------|---------------------------------------------------|
| Ansible Vault                             | Some (can use separate keys, cumbersome membership change)       | No                                   | Via source control                                       | No                             | CLI only        | No                                 | File                                    | None?                                                      | Yes                               | Yes / no centralized component | Integrated into Ansible                           |
| Barbican                                  | Yes (WIP?)                                                       | CA API for creating certificates     | No                                                       | No                             | API             | Yes                                | ENV, FUSE, REST                         | Python - 1st party. Ruby - 2015 (dead?)                    | Yes                               | Unclear                        | Platform tax: OpenStack ecosystem                 |
| Chef Encrypted Databags                   | No                                                               | No                                   | No                                                       | No                             | CLI only        | No (server could track bag access) | Files or ENV, when orchestrated by Chef | Ruby - 1st party                                           | Yes                               | No                             |                                                   |
| Chef Encrypted Databags with Diverse Keys | Some (cumbersome membership change)                              | No                                   | No                                                       | No                             | CLI only        | No (server could track bag access) | Files or ENV, when orchestrated by Chef | Ruby - 1st party                                           | Yes                               | No                             |                                                   |
| Chef Vault                                | Yes                                                              | No                                   | No                                                       | No                             | CLI only        | No (server could track bag access) | Files or ENV, when orchestrated by Chef | Ruby - 1st party                                           | Yes                               | No                             |                                                   |
| Citadel                                   | Yes                                                              | No                                   | Possible (via S3)                                        | No                             | Via AWS?        | Possible (via S3)                  | Files or ENV, when orchestrated by Chef | Ruby - 1st party                                           | AWS only                          | Yes                            |                                                   |
| Confidant                                 | Yes                                                              | No                                   | Yes                                                      | ?                              | UI, CLI         | ?                                  | ?                                       | ?                                                          | AWS Only                          | ?                              |                                                   |
| Conjur                                    | Yes                                                              | "Rotators"                           | Yes                                                      | No                             | UI, CLI         | Yes                                | ENV with Summon                         | Ruby, Python, Node, Java, .NET                             | Yes                               | Manual failover?               |                                                   |
| Crypt                                     | Some (cumbersome membership change)                              | No                                   | No                                                       | No                             | CLI only        | No                                 | File or library                         | Golang                                                     | Yes                               | Yes / no centralized component |                                                   |
| EJSON                                     | Yes, limited                                                     | No                                   | Via Git                                                  | No                             | CLI only        | No                                 | File                                    | None                                                       | Yes                               | Yes / no centralized component |                                                   |
| Hashicorp Vault                           | Yes                                                              | Some backends; no extensibility      | No                                                       | No                             | CLI only        | Maybe (syslog)                     | Env, files (additional 1st party tools) | Ruby and Go - 1st party; Python, Scala, Erlang - 3rd party | Yes                               | Yes                            | Platform tax: multi-DC issues with Consul backend |
| Keywhiz                                   | Yes                                                              | Plugins?                             | Yes                                                      | Maybe inotify?                 | UI, CLI         | Yes                                | Files                                   | None?                                                      | Yes                               | No                             |                                                   |
| Knox                                      | Yes, but multiple services on the same machine share all secrets | No                                   | Yes, best?                                               | Maybe inotify?                 | CLI only        | Yes                                | Files                                   | None?                                                      | Yes                               | Yes                            | Platform tax: must be a Go developer :)           |
| Red October                               | Yes                                                              | No                                   | No                                                       | No                             | UI, CLI         | No                                 | API only                                | None?                                                      | Yes                               | No                             | Does not actually store secrets                   |
| Trousseau                                 | No                                                               | No                                   | No                                                       | No                             | CLI only        | No                                 | File                                    | None?                                                      | Yes                               | Yes / no centralized component |                                                   |
| Zookeeper                                 | Yes                                                              | No                                   | Yes                                                      | Yes                            | ?               | No                                 | API only                                | Java?                                                      | Yes                               | Yes                            |                                                   |
| etcd                                      | In development                                                   | No                                   | Yes                                                      | Yes                            | ?               | No                                 |                                         |                                                            | Yes                               | Yes                            |                                                   |
| Consul                                    | Yes                                                              | No                                   | No                                                       | No                             | UI, CLI         | No                                 |                                         |                                                            | Yes (DC centric)                  | Yes                            |                                                   |
| Credstash                                 |                                                                  |                                      |                                                          |                                |                 |                                    |                                         |                                                            | AWS Only                          |                                |                                                   |
| Sneaker                                   |                                                                  |                                      |                                                          |                                |                 |                                    |                                         |                                                            | AWS Only                          |


Comments are welcome in the same manner.

My approach is "if a feature is not described in the documentation, it does not exist". This applies in particular
to setting up a high availability secret storage service. I will not read the source or spend significant time
experimenting with a particular tool to figure out if something can be supported.

## Index of Tools
- [Ansible Vault](#ansible-vault)
- [Barbican](#barbican)
- [Chef Data Bags](#chef-data-bags)
- [Chef Vault](#chef-vault)
- [Citadel](#citadel)
- [Confidant](#confidant)
- [Configuration Storage Systems (Consul, etcd, Zookeeper)](#configuration-storage-systems-consul-etcd-zookeeper)
- [Conjur](#conjur)
- [Crypt](#crypt)
- [EJSON](#ejson)
- [Keywhiz](#keywhiz)
- [Knox](#knox)
- [Red October](#red-october)
- [Trousseau](#trousseau)
- [Vault (Hashicorp)](#vault-hashicorp)

### Ansible Vault
This is Ansible's built in secret management system, based on encrypting secrets into a file. Its usage 
can be more general than Chef's encrypted data bags, as it can be applied to tasks, handlers, etc. 
and not just to variables; but it is not transparent, in the sense that some tasks will be configured 
differently when encryption is used. A command line tool is provided to manage the process, 
and the suggested workflow is to check the encrypted files into source control. There does not appear 
to be a way to have more than one password for a file, or to define different types of access 
to a secret, or to audit access.

If you are using Ansible and your main goal is to get the secrets out of plaintext files, this would 
probably be your natural choice.

Read more:
- http://docs.ansible.com/ansible/playbooks_vault.html

### Barbican
Currently an OpenStack project, Barbican is used to cater to secret storage needs of other OpenStack services.
It is meant to contain certificates, encryption keys, and other secrets, replacing the multitude of methods used
by individual OpenStack projects (encrypted files at rest, database tables, and so on). It takes the "enterprisey"
approach (centralized secret management, interoperability between clouds, auditing and compliance support,
simple integration with legacy applications, and even HSM support). This sounds great; however, there is a
"platform tax" as Barbican both relies on and integrates best with other OpenStack components (such as identity
management / authentication, implemented by Keystone). "Use OpenStack tools, processes, libraries, and design
patterns" is a key design principle.

Barbican itself exposes a REST API. Presentations advertise the following companion tools: a first-party Python
binding and a command line client (Keep), a JavaScript GUI (Palisade) and a possibly-Go agent (Postern). Barbican
can connect to third-party authorities to provision secrets; for now this support seems to be limited to CA
certificates. For legacy compatibility, a Barbican agent can expose the secrets as a FUSE filesystem.

Read more:
- https://speakerdeck.com/jraim/secret-as-a-service-barbican (overview presentation)
- https://wiki.openstack.org/wiki/Barbican
- http://docs.openstack.org/developer/barbican/api/index.html (REST API documentation)

### Chef Data Bags
This is a built in capability of Chef. A data bag is a JSON file stored on a Chef server and accessible by clients.
Neither Chef server nor client care about the exact format of contents of the data bag. An encrypted data bag is
the same entity encrypted with a symmetric key. Anyone who wants access to an encrypted data bag's contents needs
to have the corresponding key available to them.

The simplest use case is to have a single secret key. The key would be available to all Chef
clients (for example, by dropping onto new machines during bootstrap) and some privileged users.
Only those users can update the secrets. This approach is very simple conceptually and is effective at keeping
secrets out of repos, but does not allow any advanced functionality and does not permit non-privileged users
to update secrets. One could use a different key for every data bag, achieving some access separation and allowing
self service. Since the data source is on a Chef server, it is possible to log API access for audit.
However, all the attendant infrastructure around deciding which keys to drop, rotating keys when group
membership changes, and so on would have to be built.

Read more:
- https://docs.chef.io/data_bags.html
- https://blog.engineyard.com/2014/encrypted-data-bags

### Chef Vault
The easiest way to understand Chef Vault is as a framework to use a different shared secret
key for every Chef encrypted data bag. Chef Vault addresses the problem of distributing data bag secret
keys by encrypting them with each client's public key (used by Chef for client authentication already)
and storing the encrypted keys in a separate data bag. A Chef Vault client would fetch the data bag
containing keys first; if the client is allowed to access a particular data bag, its corresponding keys
data bag would have an entry containing the shared secret and the client would be able to decrypt it
using its private key. From that point on, the interaction is the same as with a regular encrypted data bag.

While addressing a particular pain point around key distribution, and avoiding a single-secret-for-all pitfall,
Chef Vault still sees secrets themselves as opaque, same as plain Chef. Furthermore, the common use case
is making secrets available during a Chef run. Therefore none of the desirable advanced features around
generation, non-Chef related presentation, and audit are available in Chef Vault.

Read more:
- https://www.chef.io/blog/2016/01/21/chef-vault-what-is-it-and-what-can-it-do-for-you/
- https://github.com/chef/chef-vault/blob/main/THEORY.md

### Citadel
A Chef cookbook that retrieves secrets as files from an AWS S3 bucket and relies on AWS IAM policies to
enforce access to individual secrets / files. Needless to say, this solution is AWS only.

Documentation is extremely sparse and automation of provisioning access to new machines or humans is
nonexistent (for VMs, CloudFormation could help with that). Auditing and versioning are supported by S3
but there is no visible tooling that would present a unified view of all Citadel-related data.
The limitation of an EC2 VM having only one IAM role prohibits overlapping groups, making it impossible
for one machine to serve multiple roles.

Read more:
- https://github.com/poise/citadel

### Confidant
A tool to manage secrets built by Lyft. It is an AWS-only solution using DynamoDB for storage and AWS KMS
for both encryption and access control. The service is written in Python.

Interestingly, there is no written documentation whatsoever on how to consume secrets from Confidant,
only a mention of a Flask-based API. This is one of the very few services that explicitly says app servers
are stateless and therefore can be easily spun up in a highly available constellation.
The secret store is write only and the user interface allows viewing changes and rolling back versions
straight from the GUI.

Read more:
- https://eng.lyft.com/announcing-confidant-an-open-source-secret-management-service-from-lyft-1e256fe628a3#.rz20ffjte
- https://lyft.github.io/confidant/

### Configuration Storage Systems (Consul, etcd, Zookeeper)
There is a bunch of tools for storing configuration that is not necessarily a secret in a highly available,
datacenter scale setup. Most of those systems have a tree-like data structure, version their edits,
support ACLs and some even offer notification on changes-–something no secret management system provides.

The limitations of these systems are common and are related to not being security or password oriented.
Specifically, they do not offer password generators and they do not have first party support for presentation
of decrypted secrets. Support for authentication and encryption (in transit or at rest) has not been a
given but is becoming a commonplace optional feature. Audit functionality is generally not available.

Hashicorp Vault supports Consul (as first party), zookeeper and etcd as high availability backend storage
while adding the missing security oriented features.

Read more:
- https://www.consul.io/
- https://coreos.com/etcd/
- https://zookeeper.apache.org/

### Conjur
Conjur is a closed-source appliance that does secret management as well as generic directory and access
management with a RBAC model. The appliance is self-contained and provided as a Docker or AWS AMI image.
UI and CLI interfaces are provided to the core REST API exposed by the appliance. As a directory, Conjur
also provides a LDAP endpoint to integrate with other directory-consuming applications. For secrets,
Conjur offers a Summon plugin to present secrets as environment variables.

Reading the developer docs for plugins, I'm guessing the implementation is in Ruby as well. The server
documentation lists Postgres and Nginx as other services within the container. It is possible to run
multiple appliances in a primary-replica setup, but it is unclear if automated failover is included in
the base setup or must be done externally. The main Conjur website has been completely taken over by
marketing and sales gobbledygook; the developer documentation is a much more useful source of information.

Read more:
- https://developer.conjur.net/
- http://docs.conjur.apiary.io/

### Crypt
If you prefer a spartan approach but would like to use a (hopefully highly available) key-value store 
instead of files, Crypt could be a solution for you. It relies on etcd or Consul for persistence,
storing arbitrary data (which might be a single secret or any structured format like JSON) encrypted 
using OpenPGP's public key crypto. Multiple recipients are supported by specifying a set of public keys
at the time the secret is written, and the reader must have one of the corresponding private keys to 
successfully decrypt.

The implementation is a thin client-side Go glue layer binding together gzip, OpenPGP, and backend access. It may
be used as a CLI tool for both reading and writing, or as a library. Management of encryption keys on OpenPGP
keyrings, including having to find and re-encrypt all the affected secrets if one of the keys needs 
to be rotated, is left as an exercise to the user.

Read more:
- http://xordataexchange.github.io/crypt/

### EJSON
Designed by Shopify and one of the simplest solutions available, EJSON is a command-line tool (and
library?) to encrypt secrets inside of JSON files (turning them into EJSON files) using public key crypto,
probably NaCl. There is only one secret key for a particular EJSON file, and that key is required to decrypt
the secrets. A decrypted file is the only supported secret presentation, in plaintext JSON.

In the "introduction" Shopify blog post, they mention that the production usage re-encrypts all secrets
with a single infrastructure wide "primary key" when building containers; the primary key is temporarily
given to the container to decrypt the secrets. With secrets baked into containers and a single key, this
is a relatively inflexible and not particularly secure usage model. Nevertheless, it is effective at
keeping plaintext secrets out of repos while retaining a tight link between secrets and their projects and
allowing line-by-line change tracking and "blaming" with Git.

Read more:
- https://engineering.shopify.com/79963908-secrets-at-shopify-introducing-ejson
- https://github.com/Shopify/ejson

### Keywhiz
Keywhiz comes from Square and helps them distribute infrastructure secrets to services. It is a Java
service with a JSON API, backed by a MySQL or Postgres store. A separate client provides a FUSE
presentation for secrets. Authentication is performed using mutual TLS using a client certificate,
so some kind of a PKI that can provision certificates to services and humans is necessary to use Keywhiz.
There is a CLI tool and a Keywhiz server exposes a web interface for user-friendly secret management.

There are some interesting limitations (eg. "secrets have a globally unique name"). Groups cannot inherit
from other groups. Square considers the code to be alpha quality, but the service is used internally.
While the system is quite recent, the API endpoint list is already somewhat confusing and has
multiple versions of similar-looking functions.

Read more:
- https://corner.squareup.com/2015/04/keywhiz.html
- https://github.com/square/keywhiz
- http://square.github.io/keywhiz/apidocs/

### Knox
A brand new solution from Pinterest, Knox has plenty of rough edges but gets one important concept right, namely the separation of versions of the same secret into three groups: primary (recommended/most recent), active (still working) and old (no longer working). It is certainly possible to rotate secrets smoothly without implementing such a feature (even in systems that only store one version of the secret, simply by keeping the previous version active until after the new one is deployed), but making this classification explicit helps.

Knox follows a client-server architecture backed by a persistent store. Stored secrets are encrypted but ACLs and all the rest of the metadata are not, so the store must still be trusted. The encryption key is a file on each Knox server. Servers expose the Knox API to a client daemon that runs in the background to cache up-to-date secrets locally and to a CLI management tool. Installation requires modifying the Go code and compiling from source even for configuring a particular database type. Authentication for machines is done with client certificates, and for humans via GitHub credentials or OAuth – switching between those and configuration appears to require code changes as well. Client setup requires multiple steps and is not automated.

Secrets are presented as files (plain ones, not FUSE) in a hardcoded location. It follows that within one machine, there is no separation between different services and they can all read each other's secrets.

Read more:
- https://engineering.pinterest.com/blog/open-sourcing-knox-secret-key-management-service
- https://github.com/pinterest/knox/wiki

### Red October
Red October is a CloudFlare-designed system to automate a two-person rule for secret storage (two keys
belonging to two different users are needed to decrypt a secret). A server implemented in Go and
exposing a JSON API implements encryption and decryption workflows, and allows a user to "delegate"
their key to the server to perform a time- or use-limited number of decryption operations. Remarkably,
the server does not store encrypted secrets, only a catalog of users, delegations and other metadata.

The implementation creates all possible user pairs and encrypts the secret's symmetric key with public
keys of both users sequentially. The number of possible permutations is O(n^2) and is therefore suitable
only for rather limited user counts for a given secret. There is no significant tooling around the
system (all examples in the repo are raw JSON curling).

Read more:
- https://blog.cloudflare.com/red-october-cloudflares-open-source-implementation-of-the-two-man-rule/
- https://github.com/cloudflare/redoctober

### Trousseau
Trousseau is a Go tool that manages secrets in a single OpenPGP-encrypted file. The creator of the file
can specify who can open and modify the store. As far as I can see, the access control is global.
It seems to be more suitable for personal secret storage or a small project than an enterprise rollout.
Support for several storage backends (S3, scp, Gist) is built in.

Project page: https://github.com/oleiade/trousseau

### Vault (Hashicorp)
Vault is perhaps the most commonly heard name in secret storage for infrastructure these days. Developed
by Hashicorp, it is not a surprise that Vault suggests other Hashicorp infrastructure (for example,
Consul is the only high availability backend supported by Hashicorp). Secrets are arranged in a tree
with ACLs limiting access and allowed operations. A "lease" concept is used to recommend clients
to refresh secrets once in a while, and in this manner implement a poll-based rollover functionality.
When used with "generic" secrets, the concept of a lease is advisory since secrets can be revoked
at any time regardless of existing leases, and continue to remain valid indefinitely unless changed
by some external agent. For authentication, Vault offers a large variety of backends including
GitHub and certificates.

For some specific services, Vault offers password generators where a new secret can be created
for each use request and revoked once its lifetime ("lease") expires. However, the list
of the services is fixed and there is no current extensibility for adding new generators.
First party tooling for Vault includes a CLI client, Ruby and Go libraries, and presentation
utilities such as envconsul and consul-template. There is also a growing number of third party
tools and libraries. Notably, no first party user interface besides a CLI is available. Having
Consul as the only built-in HA backend is problematic in multi-datacenter environments, since
by default Consul is consistent only within a single datacenter. Consul replication has been
attempted successfully to solve this, but is not officially supported. No first-party tooling
to reconcile multiple Vault clusters exists or is planned. Support for key versioning
is not currently planned due to backend limitations.

Read more:
- https://www.vaultproject.io/
- http://sysadminsjourney.com/blog/2015/10/30/replicating-hashicorp-vault-in-a-multi-datacenter-setup/

### Other Comparisons, Reviews, and Suggestions

- https://coderanger.net/chef-secrets/ (August 2014)
- https://github.com/pinterest/knox/wiki/Similar-Solutions (September 2016)

## Reference

* https://gist.github.com/maxvt/bb49a6c7243163b8120625fc8ae3f3cd
