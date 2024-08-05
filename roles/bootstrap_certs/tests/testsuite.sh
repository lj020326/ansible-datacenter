#!/usr/bin/env bash

ansible-playbook -i tests/inventory tests/test.yml --connection=local --become

# Verify contents of keystore
keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'testservice' \
&& (echo 'testservice certificate exists: pass' && exit 0) \
|| (echo 'testservice certificate exists: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q '2 entries' \
&& (echo 'assert 2 entries exists: pass' && exit 0) \
|| (echo 'assert 2 entries exists: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'CN=testservice' \
&& (echo 'assert CN is testservice: pass' && exit 0) \
|| (echo 'assert CN is testservice: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'OU=blog' \
&& (echo 'assert OU is blog: pass' && exit 0) \
|| (echo 'assert OU is blog: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'O=thecuriousdev' \
&& (echo 'assert O is thecuriousdev: pass' && exit 0) \
|| (echo 'assert O is thecuriousdev: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'L=Grondal' \
&& (echo 'assert L is Grondal: pass' && exit 0) \
|| (echo 'assert L is Grondal: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'ST=Stockholm' \
&& (echo 'assert ST is Stockholm: pass' && exit 0) \
|| (echo 'assert ST is Stockholm: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'C=SE' \
&& (echo 'assert C is SE: pass' && exit 0) \
|| (echo 'assert C is SE: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'Issuer: CN=thecuriousdev.org' \
&& (echo 'assert Issuer CN is thecuriousdev.org: pass' && exit 0) \
|| (echo 'assert Issuer CN is thecuriousdev.org: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'DNSName: testservice' \
&& (echo 'assert testservice SAN DNS is added: pass' && exit 0) \
|| (echo 'assert testservice SAN DNS is added: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'DNSName: testservice2' \
&& (echo 'assert testservice2 SAN DNS is added: pass' && exit 0) \
|| (echo 'assert testservice2 SAN DNS is added: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'DNSName: localhost' \
&& (echo 'assert localhost SAN DNS is added: pass' && exit 0) \
|| (echo 'assert localhost SAN DNS is added: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'IPAddress: 127.0.0.1' \
&& (echo 'assert 127.0.0.1 SAN IP is added: pass' && exit 0) \
|| (echo 'assert 127.0.0.1 SAN IP is added: fail' && exit 1)

# Truststore verifications

keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure \
| grep -q 'rootca' \
&& (echo 'assert root CA is trusted: pass' && exit 0) \
|| (echo 'assert root CA is trusted: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure \
| grep -q 'baltimore' \
&& (echo 'assert baltimore CA is trusted: pass' && exit 0) \
|| (echo 'assert baltimore CA is trusted: fail' && exit 1)

ansible-playbook -i tests/inventory tests/test-no-clean-up.yml --connection=local --become

# Verification of re-run without clean up

keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure \
| grep -q 'DNSName: testservice3' \
&& (echo 'assert testservice2 SAN DNS is added: pass' && exit 0) \
|| (echo 'assert testservice2 SAN DNS is added: fail' && exit 1)

# Verification of truststore after re-write  

keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure \
| grep -q 'rootca' \
&& (echo 'assert root CA is trusted: pass' && exit 0) \
|| (echo 'assert root CA is trusted: fail' && exit 1)

keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure \
| grep -q 'baltimore' \
&& (echo 'assert baltimore CA is trusted: pass' && exit 0) \
|| (echo 'assert baltimore CA is trusted: fail' && exit 1)

# Remove old CA and re-run with clean_up disabled
ansible-playbook -i tests/inventory tests/test-no-clean-up-other-path.yml --connection=local --become

keytool -list -v -keystore /tmp/myCA/keystore.p12 -storepass unsecure \
| grep -q '3 entries' \
&& (echo 'assert 3 entries was added: pass' && exit 0) \
|| (echo 'assert 3 entries was added: fail' && exit 1)

# Verification of truststore after re-write  

keytool -list -v -keystore /tmp/myCA/truststore.p12 -storepass unsecure \
| grep -q 'rootca' \
&& (echo 'assert root CA is trusted: pass' && exit 0) \
|| (echo 'assert root CA is trusted: fail' && exit 1)

keytool -list -v -keystore /tmp/myCA/truststore.p12 -storepass unsecure \
| grep -q 'baltimore' \
&& (echo 'assert baltimore CA is trusted: pass' && exit 0) \
|| (echo 'assert baltimore CA is trusted: fail' && exit 1)

