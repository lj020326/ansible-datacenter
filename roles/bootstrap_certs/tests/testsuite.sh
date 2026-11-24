#!/usr/bin/env bash

set -euo pipefail

ansible-playbook -i tests/inventory tests/test.yml --connection=local --become

# Verify contents of keystore
if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'testservice'; then
    echo 'testservice certificate exists: pass'
else
    echo 'testservice certificate exists: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q '2 entries'; then
    echo 'assert 2 entries exists: pass'
else
    echo 'assert 2 entries exists: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'CN=testservice'; then
    echo 'assert CN is testservice: pass'
else
    echo 'assert CN is testservice: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'OU=blog'; then
    echo 'assert OU is blog: pass'
else
    echo 'assert OU is blog: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'O=thecuriousdev'; then
    echo 'assert O is thecuriousdev: pass'
else
    echo 'assert O is thecuriousdev: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'L=Grondal'; then
    echo 'assert L is Grondal: pass'
else
    echo 'assert L is Grondal: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'ST=Stockholm'; then
    echo 'assert ST is Stockholm: pass'
else
    echo 'assert ST is Stockholm: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'C=SE'; then
    echo 'assert C is SE: pass'
else
    echo 'assert C is SE: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'Issuer: CN=thecuriousdev.org'; then
    echo 'assert Issuer CN is thecuriousdev.org: pass'
else
    echo 'assert Issuer CN is thecuriousdev.org: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'DNSName: testservice'; then
    echo 'assert testservice SAN DNS is added: pass'
else
    echo 'assert testservice SAN DNS is added: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'DNSName: testservice2'; then
    echo 'assert testservice2 SAN DNS is added: pass'
else
    echo 'assert testservice2 SAN DNS is added: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'DNSName: localhost'; then
    echo 'assert localhost SAN DNS is added: pass'
else
    echo 'assert localhost SAN DNS is added: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'IPAddress: 127.0.0.1'; then
    echo 'assert 127.0.0.1 SAN IP is added: pass'
else
    echo 'assert 127.0.0.1 SAN IP is added: fail'
    exit 1
fi

# Truststore verifications

if keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure | grep -q 'rootca'; then
    echo 'assert root CA is trusted: pass'
else
    echo 'assert root CA is trusted: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure | grep -q 'baltimore'; then
    echo 'assert baltimore CA is trusted: pass'
else
    echo 'assert baltimore CA is trusted: fail'
    exit 1
fi

ansible-playbook -i tests/inventory tests/test-no-clean-up.yml --connection=local --become

# Verification of re-run without clean up

if keytool -list -v -keystore /tmp/testCA/keystore.p12 -storepass unsecure | grep -q 'DNSName: testservice3'; then
    echo 'assert testservice2 SAN DNS is added: pass'
else
    echo 'assert testservice2 SAN DNS is added: fail'
    exit 1
fi

# Verification of truststore after re-write

if keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure | grep -q 'rootca'; then
    echo 'assert root CA is trusted: pass'
else
    echo 'assert root CA is trusted: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/testCA/truststore.p12 -storepass unsecure | grep -q 'baltimore'; then
    echo 'assert baltimore CA is trusted: pass'
else
    echo 'assert baltimore CA is trusted: fail'
    exit 1
fi

# Remove old CA and re-run with clean_up disabled
ansible-playbook -i tests/inventory tests/test-no-clean-up-other-path.yml --connection=local --become

if keytool -list -v -keystore /tmp/myCA/keystore.p12 -storepass unsecure | grep -q '3 entries'; then
    echo 'assert 3 entries was added: pass'
else
    echo 'assert 3 entries was added: fail'
    exit 1
fi

# Verification of truststore after re-write

if keytool -list -v -keystore /tmp/myCA/truststore.p12 -storepass unsecure | grep -q 'rootca'; then
    echo 'assert root CA is trusted: pass'
else
    echo 'assert root CA is trusted: fail'
    exit 1
fi

if keytool -list -v -keystore /tmp/myCA/truststore.p12 -storepass unsecure | grep -q 'baltimore'; then
    echo 'assert baltimore CA is trusted: pass'
else
    echo 'assert baltimore CA is trusted: fail'
    exit 1
fi
