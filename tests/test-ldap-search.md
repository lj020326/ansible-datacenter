
Testing search from a ldap client container:

```shell
env SAMBA_LDAP_PASSWORD=
docker run --rm -it \
  --network docker_net \
  lj020326/samba-ldap:latest \
  ldapsearch -x \
  -H ldap://ldap.dettonville.int \
  -b "dc=dettonville,dc=int" \
  -D "cn=readonly,dc=dettonville,dc=int" \
  -w "${LDAP_RO_PASSWORD}" \
  "(& (objectClass=inetOrgPerson) (memberOf=cn=admin,ou=vikunja,ou=applications,ou=groups,dc=dettonville,dc=int) )"

```

This should output:

```shell
# extended LDIF
#
# LDAPv3
# base <dc=example,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

[...]

# numResponses: 3
# numEntries: 2

```
