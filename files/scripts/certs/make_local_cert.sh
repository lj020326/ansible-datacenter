#!/usr/bin/env bash

## Generate a Root CA + Intermediate CA for local (internal) use on Mac OSX using cfssl and
## add the intermediate certificate to your keychain so it can be trusted by your local browser.
## source: https://gist.github.com/jdeathe/7f7bb957a4e8e0304f0df070f3cbcbee

# REF: https://github.com/cloudflare/cfssl

# Change working directory
cd -- "$(
	dirname "${0}"
)" || exit 1

readonly CA_ROOT_CERT_KEY="ca-root"
readonly CA_INTERMEDIATE_CERT_KEY="ca-intermediate"
readonly CF_COMMANDS="
	cfssl
	cfssljson
"
readonly SERVER_CERT_KEY="localhost"

HOSTNAMES
REGENERATE="${1:-false}"
SERVER_HOST_NAME="${2:-localhost.localdomain}"
SERVER_LOCAL_HOST_NAME="${3:-localhost}"
SERVER_PUBLIC_HOST_NAMES="${4:-}"

for COMMAND in ${CF_COMMANDS}; do
	if ! command -v ${COMMAND} &> /dev/null; then
		echo "ERROR: Missing command ${COMMAND}" >&2
		echo "Install the package from: https://pkg.cfssl.org/" >&2
		exit 1
	fi
done

tee ca-config.json 1> /dev/null <<-CONFIG
{
	"signing": {
		"default": {
			"expiry": "8760h"
		},
		"profiles": {
			"server": {
				"expiry": "43800h",
				"usages": [
					"signing",
					"key encipherment",
					"server auth"
				]
			},
			"client": {
				"expiry": "43800h",
				"usages": [
					"signing",
					"key encipherment",
					"client auth"
				]
			},
			"client-server": {
				"expiry": "43800h",
				"usages": [
					"signing",
					"key encipherment",
					"server auth",
					"client auth"
				]
			}
		}
	}
}
CONFIG

tee ca-root-to-intermediate-config.json 1> /dev/null <<-CONFIG
{
	"signing": {
		"default": {
			"expiry": "43800h",
			"ca_constraint": {
				"is_ca": true,
				"max_path_len": 0,
				"max_path_len_zero": true
			},
			"usages": [
				"digital signature",
				"cert sign",
				"crl sign",
				"signing"
			]
		}
	}
}
CONFIG

if [[ ! -f ${CA_ROOT_CERT_KEY}-key.pem ]]; then
	cfssl genkey \
		-initca \
		- \
		<<-CONFIG | cfssljson -bare ${CA_ROOT_CERT_KEY}
	{
		"CN": "(LOCAL) ROOT CA",
		"key": {
			"algo": "rsa",
			"size": 2048
		},
		"names": [
			{
				"C": "--",
				"ST": "STATE",
				"L": "LOCALITY",
				"O": "ORGANISATION",
				"OU": "LOCAL"
			}
		],
		"ca": {
			"expiry": "131400h"
		}
	}
	CONFIG
else
	echo "${CA_ROOT_CERT_KEY}-key.pem already generated."
fi

if [[ ! -f ${CA_INTERMEDIATE_CERT_KEY}-key.pem ]]; then
	cfssl gencert \
		-initca \
		- \
		<<-CONFIG | cfssljson -bare ${CA_INTERMEDIATE_CERT_KEY}
	{
		"CN": "(LOCAL) CA",
		"key": {
			"algo": "rsa",
			"size": 2048
		},
		"names": [
			{
				"C": "--",
				"ST": "STATE",
				"L": "LOCALITY",
				"O": "ORGANISATION",
				"OU": "LOCAL"
			}
		],
		"ca": {
			"expiry": "43800h"
		}
	}
	CONFIG
else
	echo "${CA_INTERMEDIATE_CERT_KEY}-key.pem already generated."
fi

if [[ ! -f ${CA_INTERMEDIATE_CERT_KEY}.pem ]] \
	|| [[ ${REGENERATE} == true ]]; then
	set -x
	# Sign intermediate certificate with root certificate
	cfssl sign \
		-ca ${CA_ROOT_CERT_KEY}.pem \
		-ca-key ${CA_ROOT_CERT_KEY}-key.pem \
		-config ca-root-to-intermediate-config.json \
		${CA_INTERMEDIATE_CERT_KEY}.csr \
	| cfssljson -bare ${CA_INTERMEDIATE_CERT_KEY}

	if [[ -f ${HOME}/Library/Keychains/login.keychain ]]; then
		echo "Adding intermediate certificate to keychain"
		echo "You will need to manually set to 'Always Trust' using Keychain Access."
		sudo security \
			add-trusted-cert \
			-r trustRoot \
			-k "${HOME}/Library/Keychains/login.keychain" \
			"${CA_INTERMEDIATE_CERT_KEY}.pem"
	fi
	set +x
fi

echo -e "\nDistribute the intermediate certificate: ${CA_INTERMEDIATE_CERT_KEY}.pem"
cat ${CA_INTERMEDIATE_CERT_KEY}.pem

## Server certificate
cfssl gencert \
	-ca ${CA_INTERMEDIATE_CERT_KEY}.pem \
	-ca-key ${CA_INTERMEDIATE_CERT_KEY}-key.pem \
	-config ca-config.json \
	-profile server \
	-hostname "${SERVER_HOST_NAME},${SERVER_LOCAL_HOST_NAME}${SERVER_PUBLIC_HOST_NAMES:+, }${SERVER_PUBLIC_HOST_NAMES}" \
	- \
	<<-CONFIG | cfssljson -bare ${SERVER_CERT_KEY}
{
	"CN": "${SERVER_HOST_NAME}",
	"key": {
		"algo": "rsa",
		"size": 2048
	}
}
CONFIG

echo -e "\nserver private key:"
cat ${SERVER_CERT_KEY}-key.pem

echo -e "\nserver certificate:"
cat ${SERVER_CERT_KEY}.pem

rm ca-config.json
rm ca-root-to-intermediate-config.json

echo -e "\nUpdating Apache Configuration: /etc/pki/tls/certs/${SERVER_CERT_KEY}.crt"
sudo bash -c "{ \
	mkdir -p /etc/pki/tls/certs; \
	cat ${SERVER_CERT_KEY}-key.pem \
		${SERVER_CERT_KEY}.pem \
		${CA_INTERMEDIATE_CERT_KEY}.pem \
	> /etc/pki/tls/certs/${SERVER_CERT_KEY}.crt; \
}"