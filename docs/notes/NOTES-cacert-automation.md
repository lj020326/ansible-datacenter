
Setup cert manager to support API based cert issue/signing
===


- create cluster issue as signer
- create certs for nodes
- get signed certs for nodes from cluster
- renew certificates at time of expiration
- query to get list of expiring certificates
- allow admin to view / manage certs

- solves the issues around ansible node cacert create
    - currently when bootstraping a new node-
    - the process involves interaction between

    (1) the ansible control node,
    (2) the node getting provisioned, and
    (3) the cert manager node (called the keyring node in our playbooks)

    There are issues when the tasks running on the provisioned node delegate tasks to the cert manager
    The issues usually are ssh/sudo related to the cert manager
    We want to reduce/eliminate the dependency on ansible to automate the cert manager
    We prefer to use/leverage an API that ansible can then call to get the cacert for the node.

    Before creating one of our own - ask are there already ones available meeting the tasks above:

Perhaps:
    https://cert-manager.io/docs/

    At first glance this appears to interact with other external 3rd party agents to create/sign the cer
    Need to research further if this server can also create internally ca signed certs.

    Results of search to date seems to indicate that this only operates/serves the kubernetes ecosystem.
    I cannot find any useful examples showing how to use this for baremetal cert create/signing use cases.

    it looks like it does all of this and more:

    https://www.redhat.com/sysadmin/cert-manager-operator-openshif
    https://github.com/jetstack/cert-manager
    https://cert-manager.io/docs/reference/api-docs/
    https://github.com/jetstack/cert-manager/tree/master/tes

    https://github.com/mmatur/traefik-cert-manager
    https://doc.traefik.io/traefik/providers/kubernetes-crd/
    https://elastisys.com/building-and-testing-base-images-for-kubernetes-cluster-nodes-with-packer-qemu-and-chef-inspec/
    https://itnext.io/cert-manager-native-x509-certificate-management-for-kubernetes-80ac478d314f

        https://itnext.io/how-to-expose-your-kubernetes-dashboard-with-cert-manager-422ab1e3bf30

        https://dzone.com/articles/secure-your-kubernetes-services-using-cert-manager

        https://github.com/bitnami/bitnami-docker-cert-manager
        https://github.com/bitnami/bitnami-docker-cert-manager/blob/master/docker-compose.yml

        https://stackoverflow.com/questions/51177410/create-issuer-for-cert-manager-for-rancher-2-x-launched-with-docker-compose
        https://www.2stacks.net/blog/rancher-2-and-letsencrypt/


- perhaps use the following as simple example apps to use as a starting point:

    https://github.com/linuxserver/docker-healthchecks

    - healthcheck app
        - it has a good simple UI to manage healthchecks
        - migrate noun/subject from healthchecks to certs
        - it currently offers a simple API
