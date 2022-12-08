
# NVIDIA GPU-OPERATOR INSTALLATION IN A PROXIED ENVIRONMENT

ADD NVIDIA GPUS TO YOUR OPENSHIFT MENU IN A CORPORATE PROXIED ENVIRONMENT

## Overview

If you’re running NVIDIA GPU’s & OpenShift/k8s in an unproxied or transparently proxied environment you probably haven’t encountered too many issues deploying NVIDIA’s gpu-operator (lucky you!), but your experience might not be as pleasant if using a traditional proxy with [HTTPS/SSL bumping/inspection enabled](https://sc1.checkpoint.com/documents/R80.40/WebAdminGuides/EN/CP_R80.40_SecurityManagement_AdminGuide/Content/Topics-SECMG/HTTPS-Inspection.htm).

In a traditional proxied environment you likely have a rule to bypass HTTPS inspection on **[cdn.redhat.com](http://cdn.redhat.com/)** due to the limitations of sending a client certificate (e.g. your entitlement cert) to an origin server when bumping connections... communication with Red Hat’s CDN [just won’t work](https://squid-users.squid-cache.narkive.com/4Zu5xFfD/squid-4-3-ssl-bump-fails-to-send-client-certificate#post7) if HTTPS inspection is enabled. Unfortunately the gpu-operator is also connecting to the unauthenticated **[cdn\-ubi.redhat.com](http://cdn-ubi.redhat.com/)** which (a) might not have a bypass rule and (b) requires a proper CA bundle to validate your proxy’s certificate when that MITM communication occurs.

Until a permanent fix is available, you have a few options:

1.  Add a HTTPS inspection bypass rule for **[cdn\-ubi.redhat.com](http://cdn-ubi.redhat.com/)**
2.  If using OpenShift, add a configMap with your injected CA bundle and use an alternate operator image that mounts your CA bundle at the appropriate location
3.  If using OpenShift or Kubernetes, use an alternate operator image that mounts your node’s CA bundle at the appropriate location within the container (provided your node has the proper CA chain in its bundle)

The path of least resistance is option (1) if you can get your Information Security team to sign-off. Option (2) and (3) are viable if you don’t mind building and/or using a custom operator image until a permanent fix is introduced by NVIDIA.

To see the minor edits made to accommodate option (1) and (2):

-   Using configMap with injected CA bundle: [https://gitlab.com/liveaverage/gpu-operator/-/commit/cd5250810b01b21fd27370bc5f7c7a5d91d05e38](https://gitlab.com/liveaverage/gpu-operator/-/commit/cd5250810b01b21fd27370bc5f7c7a5d91d05e38)
-   Using hostPath: [https://gitlab.com/liveaverage/gpu-operator/-/commit/25e3397c4223df0b097bb76da5e476b861bef2fc](https://gitlab.com/liveaverage/gpu-operator/-/commit/25e3397c4223df0b097bb76da5e476b861bef2fc)

We’ll cover implementing both of these options, each requiring an alternate operator image to be referenced before deploying via helm.

## Enable Cluster Entitlements

This is well documented across a couple articles. The general procedure involves downloading an entitlement certificate from Red Hat, dropping it into a MachineConfig, and rolling that into OpenShift:

-   [https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift](https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift)
-   [https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html#openshift-gpu-install-gpu-operator-via-helmv3](https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html#openshift-gpu-install-gpu-operator-via-helmv3)

| Note that applying the cluster-wide machineConfigs **will reboot your systems**! If you’d prefer a controlled reboot you can use the `pause` function:

```shell
# Pause MCO
oc patch --type=merge --patch='{"spec":{"paused":true}}' machineconfigpool/worker

# Resume MCO
oc patch --type=merge --patch='{"spec":{"paused":false}}' machineconfigpool/worker

```

## Entitlement Test

```shell
### Test Entitlements

### Initialize CM with label
cat <<EOF > ent-ca-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: trusted-ca
  labels:
    config.openshift.io/inject-trusted-cabundle: "true"
EOF

oc apply -f ent-ca-configmap.yaml

### Make sure HTTP/HTTPS_PROXY/NO_PROXY are set in env

cat <<EOF > ent-proxy.yaml
apiVersion: v1
kind: Pod
metadata:
 name: ent-proxy
spec:
 containers:
   - name: cluster-entitled-build
     image: registry.access.redhat.com/ubi8:latest
     command: [ "/bin/sh", "-c", "dnf -d 5 search kernel-devel --showduplicates" ]
     env:
     - name: HTTP_PROXY
       value: ${HTTP_PROXY}
     - name: HTTPS_PROXY
       value: ${HTTPS_PROXY}
     - name: NO_PROXY
       value: ${NO_PROXY}
     volumeMounts:
     - name: trusted-ca
       mountPath: "/etc/pki/ca-trust/extracted/pem/"
       readOnly: true
 volumes:
 - name: trusted-ca
   configMap:
     name: trusted-ca
     items:
     - key: ca-bundle.crt
       path: tls-ca-bundle.pem
 restartPolicy: Never
EOF

oc apply -f ent-proxy.yaml
oc get pods
oc logs -f ent-proxy

```

If you encounter any issues then **STOP** here and determine if your entitlement is valid (i.e. not expired, has acccess to appropriate repos, etc.). A quick way to test from a Red Hat CoreOS node (assuming your entitlement cert/key is present):

## Deploying modified operator via helm

Edit gpu-operator/values.yaml:

-   Modify the `operator` section
    -   Use `1.5.1-1-gcd52508` for assets creating/referencing configMap with injected CA Bundle
        -   Not certain why, but this required manual creation of the `nvidia-config` configMap
    -   Use `1.5.1-2-g25e3397` for assets using hostPath to CA Bundle (RECOMMENDED)

```yaml
operator:
  repository: registry.gitlab.com/liveaverage
  image: gpu-operator
  # If version is not specified, then default is to use chart.AppVersion
  version: 1.5.1-1-gcd52508
```

-   Add to the `driver` section, replacing each value with your environment variable values:

```yaml
    env:
    - name: "HTTP_PROXY"
      value: "${HTTP_PROXY}"
    - name: "HTTPS_PROXY"
      value: "${HTTPS_PROXY}"
    - name: "NO_PROXY"
      value: "${NO_PROXY}"
```

Deploy the chart from the **local** directory:

```shell
cd ..
helm install gpu-operator ./gpu-operator --set platform.openshift=true,operator.validator.version=vectoradd-cuda10.2-ubi8,operator.defaultRuntime=crio,nfd.enabled=false,devicePlugin.version=v0.7.3-ubi8,dcgmExporter.version=2.0.13-2.1.2-ubi8,toolkit.version=1.4.0-ubi8 --wait
```

Confirm your DriverContainers launch successfully and can now hit all repos:

```shell
oc get pods -n gpu-operator

NAME                                       READY   STATUS     RESTARTS   AGE
gpu-feature-discovery-27svk                1/1     Running    0          12m
gpu-feature-discovery-gxmtv                1/1     Running    0          12m
gpu-feature-discovery-tlvnh                1/1     Running    0          12m
gpu-feature-discovery-vbnsf                1/1     Running    0          12m
nvidia-container-toolkit-daemonset-hclwd   1/1     Running    0          5m38s
nvidia-container-toolkit-daemonset-t5cdb   1/1     Running    0          5m38s
nvidia-container-toolkit-daemonset-vlxd5   1/1     Running    0          5m38s
nvidia-container-toolkit-daemonset-wb7s2   1/1     Running    0          5m38s
nvidia-device-plugin-daemonset-bg7zp   0/1     Init:0/1   0          9s
nvidia-device-plugin-daemonset-dmbn2   0/1     Init:0/1   0          9s
nvidia-device-plugin-daemonset-jz94c   0/1     Init:0/1   0          9s
nvidia-device-plugin-daemonset-k6p9p   0/1     Init:0/1   0          9s
nvidia-driver-daemonset-82srn              1/1     Running    0          11m
nvidia-driver-daemonset-mtlc5              1/1     Running    0          11m
nvidia-driver-daemonset-wcbzb              1/1     Running    0          11m
nvidia-driver-daemonset-xdz8s              1/1     Running    0          5m42s
```

## Reference

* https://liveaverage.com/blog/proxied-openshift-nvidia-gpu-operator/
* https://github.com/liveaverage/packer-ocp4-vsphere-upi
* 
