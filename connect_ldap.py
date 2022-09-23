#!/usr/bin/env python

import ldap
import os

def authenticate(address, username, password):
    conn = ldap.initialize('ldaps://' + address)
    conn.protocol_version = 3
    conn.set_option(ldap.OPT_REFERRALS, 0)
    return conn.simple_bind_s(username, password)

ldap_pdc_host = os.environ['MACHINE_CREDENTIALS_PROD_PDC_HOST']
ldap_username = os.environ['MACHINE_CREDENTIALS_TEST_WINDOWS_DOMAIN_USERNAME']
ldap_password = os.environ['MACHINE_CREDENTIALS_TEST_WINDOWS_DOMAIN_PASSWORD']

authenticate(ldap_pdc_host, ldap_username, ldap_password)
