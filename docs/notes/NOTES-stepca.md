

If bootstrapping a machine step-ca and get 'fingerprint not found':

	```
	## Check the fingerprint in vars/secrets.yml matches this:
	step certificate fingerprint <(curl -k -s https://stepca.admin.dettonville.int/1.0/roots | jq -r '.crts[0]' | sed -r '/^\s*$/d')
	```

How to setup kubernetes-acme-ca

	https://smallstep.com/docs/tutorials/kubernetes-acme-ca


step certificate commands:

	https://smallstep.com/docs/step-cli/reference/certificate#commands

	Name	Usage
	bundle	bundle a certificate with intermediate certificate(s) needed for certificate path validation
	create	create a certificate or certificate signing request
	format	reformat certificate
	inspect	print certificate or CSR details in human readable format
	fingerprint	print the fingerprint of a certificate
	lint	lint certificate details
	needs-renewal	Check if a certificate needs to be renewed
	sign	sign a certificate signing request (CSR)
	verify	verify a certificate
	key	print public key embedded in a certificate
	install	install a root certificate in the system truststore
	uninstall	uninstall a root certificate from the system truststore
	p12	package a certificate and keys into a .p12 file

Use Keycloak to issue user certificates with step-ca

	https://smallstep.com/docs/tutorials/keycloak-oidc-provisioner

Read host and protocol information from request for links

	https://github.com/smallstep/certificates/pull/243

Add new acmeHost config option

	https://github.com/smallstep/certificates/pull/236

To get fingerprint of root ca:

	ref: https://smallstep.com/blog/embarrassingly-easy-certificates-on-aws-azure-gcp/

	The --fingerprint is for the root certificate used by step-ca. 
	Find it by running the following command on your CA:

		step certificate fingerprint $(step path)/certs/root_ca.crt

	## OR by running this from the client machine:
	```
	## ref: https://github.com/smallstep/certificates/discussions/449#discussioncomment-275657
	step certificate fingerprint <(curl -k -s https://stepca.admin.dettonville.int/1.0/roots | jq -r '.crts[0]' | sed -r '/^\s*$/d')
	```

Source code for default/base templates:

	https://github.com/smallstep/crypto/blob/42c30c598c49b98b32e40a97b60e43588eef885d/x509util/templates.go#L149-L170

Debug docker container:

	To run bash to debug step-ca image:

	docker run -p 8443:8443 -v `pwd`/stepca/home:/home/step -it --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	...
	bash-5.1# bash -x entrypoint.sh

How to init step-ca certs:

	docker run -e INIT_CONFIG=1 -p 8443:8443 -v `pwd`/stepca/home:/home/step media.johnson.int:5000/docker-stepca:latest

How to init step-ca csr:

	docker run -e CREATE_CSR=1 -p 8443:8443 -v `pwd`/stepca/home:/home/step media.johnson.int:5000/docker-stepca:latest


How to test step-ca:

	curl -v https://stepca.admin.johnson.int/health

Examples:

	https://github.com/smallstep/certificates/tree/master/examples
	https://github.com/smallstep/certificates/blob/master/examples/bootstrap-tls-server/server.go
	https://github.com/smallstep/certificates/blob/master/examples/pki/config/ca.json
	https://awesomeopensource.com/project/smallstep/certificates

	GETTING A CERTIFICATE FROM STEP-CA USING IID-BASED AUTHENTICATION
		Bootstraping azure VMs with step-ca certs using IID based authn
			https://smallstep.com/blog/embarrassingly-easy-certificates-on-aws-azure-gcp/

		Instance identity documents (IIDs) are simply credentials that identify an instance's name and owner. 
		By presenting an IID in a request, a workload can prove that it's running on a VM instance that you own.

		The major clouds have different names for IIDs: 
			AWS calls them instance identity documents, 
			GCP calls them instance identity tokens, and 
			Azure calls them access tokens. 

		The "metadata" included in an IID also differs between clouds, along with many other implementation details. 
		Abstractly, though, they're all the same: signed bearer tokens that identify, minimally, the name and owner of a VM.

		IIDs are returned from a metadata API exposed via a non-routable IP address (the link-local address 169.254.169.254). 
		This magic is orchestrated by the hypervisor, which identifies the requesting VM and services IID requests locally. 
		The upshot is: IIDs are very easy to get from within a VM via one unauthenticated HTTP request. 
		Barring any security issues, they're impossible to get from anywhere else.


	Good docker example - with custom entrypoint.sh to bootstrap root ca creation if not already exist:
		https://github.com/Praqma/smallstep-ca-demo

How to run with existing pki / root ca cert:

	https://github.com/smallstep/certificates/blob/master/docs/questions.md#i-already-have-pki-in-place-can-i-use-this-with-my-own-root-certificate
	https://github.com/smallstep/certificates/issues/160

	2 methods:

	1) Option 1: the easy way:

		If you have your root CA signing key available, you can run:

			step ca init --root=[ROOT_CERT_FILE] --key=[ROOT_PRIVATE_KEY_FILE]

	2) Option 2: More secure
		
		CAs are usually pretty locked down and it's bad practice to move the private key around. 

		We assume that's not an option and give you the instructions to do this "the right way", by 

			1) generating a CSR for step-ca, 
			2) getting it signed by your existing root, and 
			3) configuring step-ca to use it.

		When you run step ca init we create a couple artifacts under ~/.step/. The important ones for us are:

			~/.step/certs/root_ca.crt is your root CA certificate
			~/.step/certs/intermediate_ca.crt is your intermediate CA cert

			~/.step/secrets/root_ca_key is your root CA signing key
			~/.step/secrets/intermediate_ca_key is the intermediate signing key used by step-ca

		The easiest thing to do is to run step ca init to get this scaffolding configuration in place, 
		then remove/replace these artifacts with new ones that are tied to your existing root CA.

		1) First, step-ca does not actually need the root CA signing key. So you can simply remove that file:

			rm ~/.step/secrets/root_ca_key

		2) Next, replace step-ca's root CA cert with your existing root certificate:

			mv /path/to/your/existing/root.crt ~/.step/certs/root_ca.crt

		3) Now you need to generate a new signing key and intermediate certificate, signed by your existing root CA. 
			To do that we can use the step certificate create subcommand to generate a certificate signing request (CSR) 
			that we'll have your existing root CA sign, producing an intermediate certificate.

			To generate those artifacts run:

				step certificate create "Intermediate CA Name" intermediate.csr intermediate_ca_key --csr

		4) Next, you'll need to transfer the CSR file (intermediate.csr) to your existing root CA and get it signed.

			OpenSSL
			
			openssl ca -config [ROOT_CA_CONFIG_FILE] \
			  -extensions v3_intermediate_ca \
			  -days 3650 -notext -md sha512 \
			  -in intermediate.csr \
			  -out intermediate.crt
			CFSSL
			
			For CFSSL you'll need a signing profile that specifies a 10-year expiry:
			
			cat > ca-smallstep-config.json <<EOF
			{
			  "signing": {
			    "profiles": {
			      "smallstep": {
			        "expiry": "87660h",
			        "usages": ["signing"]
			      }
			    }
			  }
			}
			EOF
			Now use that config to sign the intermediate certificate:
			
			cfssl sign -ca ca.pem \
			    -ca-key ca-key.pem \
			    -config ca-smallstep-config.json \
			    -profile smallstep
			    -csr intermediate.csr | cfssljson -bare
			This process will yield a signed intermediate.crt certificate (or cert.pem for CFSSL). Transfer this file back to the machine running step-ca.
			
			Finally, replace the intermediate .crt and signing key produced by step ca init with the new ones we just created:
			
			mv intermediate.crt ~/.step/certs/intermediate_ca.crt
			mv intermediate_ca_key ~/.step/secrets/intermediate_ca_key
	

		
	

How to install step-cli
	ref: https://smallstep.com/docs/step-cli/installation

	windows:
		scoop bucket add smallstep https://github.com/smallstep/scoop-bucket.git
		scoop install smallstep/step


Don't know your root certificate fingerprint?
	You can get it by running the following on your CA:

	step certificate fingerprint $(step path)/certs/root_ca.crt

How to setup traefik with step-ca:

	https://github.com/Praqma/smallstep-ca-demo/blob/master/clients/traefik/traefik-compose.yaml


Step-ca
	Using step-ca with cert-manager using cert-issuer:
	https://github.com/smallstep/step-issuer

	https://smallstep.com/docs/step-ca/installation
	https://smallstep.com/docs/step-ca/certificate-authority-core-concepts

	Step Issuer - a cert-manager's CertificateRequest controller that uses step certificates (a.k.a. step-ca) to sign the certificate requests.
	https://smallstep.com/blog/embarrassingly-easy-certificates-on-aws-azure-gcp/

Integrating with K8s:

	https://github.com/smallstep/step-issuer

Using with a custom root ca cert:
	ref: https://github.com/smallstep/certificates/issues/160#issuecomment-579038826
	ref: https://github.com/smallstep/certificates/blob/master/docs/questions.md
	ref: https://github.com/smallstep/certificates/blob/master/docs/questions.md#i-already-have-pki-in-place-can-i-use-this-with-my-own-root-certificate

	Option 1: The easy way
		If you have your root CA signing key available, you can run:
	
			step ca init --root=[ROOT_CERT_FILE] --key=[ROOT_PRIVATE_KEY_FILE]

		The root certificate can be in PEM or DER format, and the signing key can be a PEM file containing a PKCS#1, PKCS#8, or RFC5915 (for EC) key.

	Option 2: More secure

		That said, CAs are usually pretty locked down and it's bad practice to move the private key around. 

		So I'm gonna assume that's not an option and give you the more complex instructions to do this "the right way".

		To summarize, this involves:
			1) Generate a CSR for step-ca, 
			2) Get it signed by your existing root, and 
			3) Configure step-ca to use it.
		
		When you run step ca init we create a couple artifacts under ~/.step/. 
		The important ones for us are:
		
		~/.step/certs/root_ca.crt is your root CA certificate
		~/.step/secrets/root_ca_key is your root CA signing key
		~/.step/certs/intermediate_ca.crt is your intermediate CA cert
		~/.step/secrets/intermediate_ca_key is the intermediate signing key used by step-ca

		The easiest thing to do is to 
		1) run step ca init to get this scaffolding configuration in place, then 
		2) remove/replace these artifacts with new ones that are tied to your existing root CA.
		
		First, step-ca does not actually need the root CA signing key. 
		So you can simply remove that file:
		
			rm ~/.step/secrets/root_ca_key

		Next, replace step-ca's root CA cert with your existing root certificate:
		
			mv /path/to/your/existing/root.crt ~/.step/certs/root_ca.crt

		Now you need to generate a new signing key and intermediate certificate, signed by your existing root CA. 
		To do that we can use the step certificate create subcommand to generate a certificate signing request (CSR).
		Then have your existing root CA sign, producing an intermediate certificate.
		
		To generate those artifacts run:
		
			step certificate create "Intermediate CA Name" intermediate.csr intermediate_ca_key --csr

		Next, you'll need to transfer the CSR file (intermediate.csr) to your existing root CA and get it signed.
		
		Now you need to get the CSR executed by your existing root CA.

		OpenSSL
		
			openssl ca -config [ROOT_CA_CONFIG_FILE] \
			  -extensions v3_intermediate_ca \
			  -days 3650 -notext -md sha512 \
			  -in intermediate.csr \
			  -out intermediate.crt
			CFSSL
			
		CFSSL
			For CFSSL you'll need a signing profile that specifies a 10-year expiry:
			
			cat > ca-smallstep-config.json <<EOF
			{
			  "signing": {
			    "profiles": {
			      "smallstep": {
			        "expiry": "87660h",
			        "usages": ["signing"]
			      }
			    }
			  }
			}
			EOF
			Now use that config to sign the intermediate certificate:
			
			cfssl sign -ca ca.pem \
			    -ca-key ca-key.pem \
			    -config ca-smallstep-config.json \
			    -profile smallstep
			    -csr intermediate.csr | cfssljson -bare
			This process will yield a signed intermediate.crt certificate (or cert.pem for CFSSL). Transfer this file back to the machine running step-ca.
		
		Finally, replace the intermediate .crt and signing key produced by step ca init with the new ones we just created:
		
			mv intermediate.crt ~/.step/certs/intermediate_ca.crt
			mv intermediate_ca_key ~/.step/secrets/intermediate_ca_key

		That should be it! You should be able to start step-ca and the certificates should be trusted by anything that trusts your existing root CA.

	
	Orig/old answer:
		when you run step ca init this creates a PKI with a root and intermediate certificate. 
		The root certificate and the intermediate cert + key are then referenced (by file location) in the step-ca configuration file - ca.json.
	
		Suppose you have your own root and intermediate certificates already. 
		You can run step ca init and just replace the values in ca.json with the locations of your existing files and the CA should work.
	
		Suppose you only have a root certificate and you'd like to bootstrap a new PKI using that root.
		E.g., to create a new intermediate cert signed by that root. 

		You can run step ca init --root <my-root.pem> --key <my-root-priv-key> and this will create an intermediate certificate 
		and create a ca.json file with the correct root and intermediates already filled in.



Boulder-ca:
	https://github.com/letsencrypt/boulder/
	https://www.reddit.com/r/selfhosted/comments/f1ait1/i_wrote_an_ansible_role_to_deploy_an_acme_ca/

	Ansible role to deploy boulder-ca
		https://github.com/alemonmk/ansible_boulder_deployment



Debugging notes:

	cat ca-config.json
	cat dettonville.int
	cat .env
	cat /etc/fstab
	cat intermediate_ca.tpl
	cat stepca/home/ca-config.json
	cat stepca/home/certs/intermediate_ca.crt
	cat stepca/home/config/ca.json
	cat stepca/home/config/ca.json | jq
	cat stepca/home/config/defaults.json
	cat stepca/home/config/defaults.json | jq
	cat stepca/home/config/save/
	cat stepca/home/config/save/ca.json
	cat stepca/home/config/save/ca.json | jq
	cat stepca/home/secrets/password
	cat stepca/home/secrets/password
	cfssl sign -config ca-config.json -profile step-ca \
		-ca /usr/local/ssl/certs/ca.admin.johnson.int.pem \
		-ca-key /usr/local/ssl/private/ca.admin.johnson.int-key.pem \
		-csr admin.johnson.int.csr
	cfssl sign -config ca-config.json -profile step-ca \
		-ca /usr/local/ssl/certs/ca.admin.johnson.int.pem \
		-ca-key /usr/local/ssl/private/ca.admin.johnson.int-key.pem \
		-csr admin.johnson.int.csr | cfssljson -bare admin.johnson.int.3
	cfssl sign -config ca-config.json -profile step-ca \
		-ca /usr/local/ssl/certs/ca.admin.johnson.int.pem \
		-ca-key /usr/local/ssl/private/ca.admin.johnson.int-key.pem \
		-csr certs/intermediate.csr | cfssljson -bare admin.johnson.int.3
	chown container-user.container-user stepca/home/certs/root_ca.dettonville.int.crt
	cp admin.johnson.int.2.pem certs/intermediate_ca.crt
	cp admin.johnson.int.3.pem certs/intermediate_ca.crt
	cp -p intermediate_ca.crt intermediate_ca.crt.orig
	cp -p intermediate_ca_key intermediate_ca_key.orig
	cp -p root_ca.crt root_ca.crt.orig
	cp -pr pgdocker.dettonville.old pgdocker
	cp -p stepca/home/certs/intermediate_ca.crt.2884137.2021-06-17@08\:37\:52~ stepca/home/certs/intermediate_ca.crt.smallstep
	cp -p stepca/home/certs/root_ca.crt.2884109.2021-06-17@08\:37\:52~ stepca/home/certs/root_ca.crt.smallstep
	cp -p /usr/local/ssl/certs/ca-root.pem stepca/home/certs/root_ca.dettonville.int.crt
	cp -p /usr/local/ssl/certs/ca-root.pem stepca/home/certs/root_ca.johnson.int.crt
	curl -v https://localhost:8443/health
	curl -v https://stepca.admin.johnson.int:8443/health
	curl -v https://stepca.admin.johnson.int/health
	date
	docker-compose down
	docker-compose ps
	docker-compose restart jenkins jenkins-agent-01
	docker-compose restart samba
	docker-compose restart step-ca
	docker-compose rm -f jenkins
	docker-compose rm -f jenkins jenkins-agent-01
	docker-compose rm -f step-ca
	docker-compose rm -f step-ca-csr
	docker-compose stop jenkins
	docker-compose stop jenkins jenkins-agent-01
	docker-compose stop step-ca
	docker-compose stop stepca
	docker-compose stp[ step-ca
	docker-compose up -d
	docker-compose up -d jenkins
	docker-compose up -d jenkins jenkins-agent-01
	docker-compose up -d step-ca
	docker-compose up step-ca
	docker ps
	docker ps -a
	docker rm 3ef14e675589 8e0db3800312
	docker rm 40b72e64eee0
	docker rm 96dfd07ec682 424b0b8ac0b8 04d5e254c7c7 5604f7d27f4c 4674a928e879
	docker rm a359c0e2d1f7
	docker rm af15fab6f85d
	docker rm ca84c8d0006c
	docker rm -f step-ca-csr
	docker rm step-ca
	docker rm step-ca-csr
	docker run -d -p 8443:8443 -v `pwd`/stepca/home:/home/step --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	docker run -d -p 8443:8443 -v `pwd`/stepca/home:/home/step -it --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	docker run -d -p 8443:8443 -v ./stepca/home:/home/step --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	docker run -d -p 8443:8443 -v stepca/home:/home/step --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	docker run -e INIT_CONFIG=1 -p 8443:8443 -v `pwd`/stepca/home:/home/step media.johnson.int:5000/docker-stepca:latest
	docker run -p 8443:8443 -v `pwd`/stepca/home:/home/step -it --entrypoint /bin/bash media.johnson.int:5000/docker-stepca:latest
	docker stop 40b72e64eee0
	docker stop ca84c8d0006c
	docker stop step-ca
	docker stop step-ca-csr
	emacs ca-config.json
	emacs docker-compose.yml
	emacs intermediate_ca.tpl
	emacs stepca/home/ca-config.json
	emacs stepca/home/entrypoint.sh
	gethist | sort | uniq
	history | grep cfssl
	history | grep curl
	history | grep openssl
	history | grep step
	la ~/.step/
	la stepca/
	la stepca/home/
	la stepca/home/cert
	la stepca/home/certs/
	la stepca/home/config/
	la stepca/home/secrets/
	la stepca/home/templates/
	ll stepca/
	ll stepca/home/
	ll stepca/home/c
	ll stepca/home/certs/
	ll stepca/home/certs/intermediate.csr
	ll stepca/home/confg
	ll stepca/home/config/
	ll stepca/home/config/save/
	ll stepca/home/config/save/ca.json
	ll stepca/home/db/
	ll stepca/home/db/*
	ll stepca/home/secrets/
	ll stepca/home/templates/
	ll ../templates/
	ll /usr/local/ssl/
	ll /usr/local/ssl/certs/
	ll /usr/local/ssl/certs/admin.johnson.int.chain.pem
	ll /usr/local/ssl/certs/ca.admin.johnson.int.pem
	ll /usr/local/ssl/private/
	ll /usr/local/ssl/private/ca.admin.johnson.int-key.pem
	lsof /data
	mkdir stepca/home/config/save
	mount -a
	mount -l | grep container
	mount -l | grep export
	mv intermediate_ca.crt.3652674.2021-06-11@08\:51\:15~ intermediate_ca.crt
	mv intermediate_ca.crt intermediate_ca.crt.new
	mv intermediate_ca_key.3618179.2021-06-11@08\:15\:21~ intermediate_ca_key
	mv intermediate_ca_key intermediate_ca_key.new
	mv intermediate_ca.tpl ../templates/
	mv intermediate.csr intermediate.csr.20210625
	mv pgdocker pgdocker.20210625
	mv root_ca.crt.3618120.2021-06-11@08\:15\:20~ root_ca.crt
	mv root_ca.crt root_ca.crt.new
	mv stepca/home/certs/intermediate.csr stepca/home/certs/intermediate.csr.old
	mv stepca/home/config/*.json stepca/home/config/save/
	mv stepca/home/secrets/password stepca/home/secrets/password.orig
	mv ../templates/intermediate_ca.tpl ../templates/intermediate_ca.tpl.orig
	openssl req -text -noout -fingerprint -in stepca/home/certs/intermediate.csr
	openssl req -text -noout -in stepca/home/certs/intermediate.csr
	openssl req -text -noout -sha256 -fingerprint -in stepca/home/certs/intermediate.csr
	openssl req -text -noout -sha256 -in admin.johnson.int.csr
	openssl req -text -noout -sha256 -in stepca/home/admin.johnson.int.csr
	openssl req -text -noout -sha256 -in stepca/home/certs/intermediate.csr
	openssl req -text -noout -sha256 -in stepca/home/certs/intermediate.csr.20210625
	openssl verify -CAfile stepca/home/certs/root_ca.crt.smallstep stepca/home/certs/intermediate_ca.crt.smallstep
	openssl verify -CAfile stepca/home/certs/root_ca.crt stepca/home/certs/intermediate_ca.crt
	openssl verify -CAfile /usr/local/ssl/certs/admin.johnson.int.chain.pem stepca/home/certs/intermediate_ca.crt
	openssl verify -CAfile /usr/local/ssl/certs/ca.admin.johnson.int.pem stepca/home/admin.johnson.int.pem
	openssl verify -CAfile /usr/local/ssl/certs/ca.admin.johnson.int.pem stepca/home/certs/intermediate_ca.crt
	openssl x509 -text -noout -fingerprint -in stepca/home/certs/intermediate_ca.crt
	openssl x509 -text -noout -fingerprint -in stepca/home/certs/root_ca.crt
	openssl x509 -text -noout -fingerprint -in stepca/home/certs/root_ca.crt
	openssl x509 -text -noout -in stepca/home/certs/intermediate_ca.crt
	openssl x509 -text -noout -in stepca/home/certs/intermediate.csr
	openssl x509 -text -noout -in stepca/home/certs/root_ca.crt
	openssl x509 -text -noout -sha256 -fingerprint -in admin.johnson.int.2.pem
	openssl x509 -text -noout -sha256 -fingerprint -in admin.johnson.int.3.pem
	openssl x509 -text -noout -sha256 -fingerprint -in admin.johnson.int.pem
	openssl x509 -text -noout -sha256 -fingerprint -in admin.johnson.int.pem
	openssl x509 -text -noout -sha256 -fingerprint -in certs/intermediate_ca.crt
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/admin.johnson.int.csr
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/admin.johnson.int.pem
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/intermediate_ca.crt
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/intermediate_ca.crt
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/intermediate_ca.crt.2884137.2021-06-17@08\:37\:52~
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/intermediate_ca.crt.smallstep
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/root_ca.crt
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/root_ca.crt.2884109.2021-06-17@08\:37\:52~
	openssl x509 -text -noout -sha256 -fingerprint -in stepca/home/certs/root_ca.crt.smallstep
	openssl x509 -text -noout -sha512 -fingerprint -in stepca/home/certs/intermediate_ca.crt
	rm admin.johnson.int.2.*
	rm admin.johnson.int.3.*
	rm -fr pgdocker
	rm -fr stepca/home/config/*
	rm -f stepca/home/config/*
	rm stepca/home/*~
	rm stepca/home/admin.johnson.int.*
	rm stepca/home/#ca-config.json#
	rm stepca/home/ca-config.json~
	rm stepca/home/cert.csr
	rm stepca/home/cert.pem
	rm stepca/home/certs/*
	rm stepca/home/certs/intermediate
	rm stepca/home/certs/intermediate_ca.crt
	rm stepca/home/certs/intermediate_ca_key
	rm stepca/home/certs/intermediate.crt
	rm stepca/home/certs/intermediate.csr
	rm stepca/home/certs/root_ca.johnson.int.crt
	rm stepca/home/config/*
	rm stepca/home/config/ca.json
	rm stepca/home/db/*
	rm stepca/home/entrypoint.orig.sh
	rm stepca/home/secrets/
	rm stepca/home/secrets/*
	rm stepca/home/secrets/root_ca_key
	rm *tpl~
	sdiff -s ca-config.json~ ca-config.json
	sdiff -s docker-compose.yml.3568251.2021-05-05@08\:35\:15~ docker-compose.yml
	sdiff -s docker-compose.yml.3616173.2021-06-11@08\:14\:44~ docker-compose.yml
	sdiff -s gitea/gitea/conf/app.ini.3616729.2021-06-11@08\:14\:53~ gitea/gitea/conf/app.ini
	sdiff -s /usr/local/ssl/certs/admin.johnson.int.pem stepca/home/certs/root_ca.crt
	sdiff -s /usr/local/ssl/certs/ca.admin.johnson.int.pem stepca/home/certs/root_ca.crt
	step certificate fingerprint stepca/home/certs/root_ca.crt
	step certificate sign --profile intermediate-ca admin.johnson.int.csr /usr/local/ssl/certs/ca.admin.johnson.int.pem /usr/local/ssl/private/ca.admin.johnson.int-key.pem
	step certificate sign --profile intermediate-ca admin.johnson.int.csr /usr/local/ssl/certs/ca.admin.johnson.int.pem /usr/local/ssl/private/ca.admin.johnson.int-key.pem > admin.johnson.int.2.pem
	step certificate sign --profile intermediate-ca intermediate.csr /usr/local/ssl/certs/ca.admin.johnson.int.pem /usr/local/ssl/private/ca.admin.johnson.int-key.pem
	telnet localhost 8443

	step certificate inspect /usr/local/ssl/certs/admin02.dettonville.int.pem
	step certificate fingerprint /usr/local/ssl/certs/admin02.dettonville.int.pem
