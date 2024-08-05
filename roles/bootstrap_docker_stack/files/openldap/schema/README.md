
This directory contains user application schema definitions for use
with slapd(8).

File                    Description
----                    -----------
collective.schema       Collective attributes (experimental)
corba.schema            Corba Object
core.schema             OpenLDAP "core"
cosine.schema           COSINE Pilot
dsee.schema             Sun DSEE compatibility schema for replication
duaconf.schema          Client Configuration (work in progress)
dyngroup.schema			Dynamic Group (experimental)
inetorgperson.schema    InetOrgPerson
java.schema             Java Object
misc.schema             Miscellaneous Schema (experimental)
msuser.schema           Microsoft's Active Directory schema for replication
namedobject.schema      namedObject draft schema (work in progress)
nis.schema              Network Information Service (experimental)
openldap.schema         OpenLDAP Project (FYI)
pmi.schema              ITU X.509 PMI support (experimental)

Additional "generally useful" schema definitions can be submitted
using the OpenLDAP Issue Tracking System <http://www.openldap.org/its/>.
Submissions should include a stable reference to a mature, open
technical specification (e.g., an RFC) for the schema.

The core.ldif and openldap.ldif files are equivalent to their
corresponding .schema files. They have been provided as examples
for use with the dynamic configuration backend. These example files
are not actually necessary since slapd will automatically convert any
included *.schema files into LDIF when converting a slapd.conf file
to a configuration database, but they serve as a model of how to
convert schema files in general.
