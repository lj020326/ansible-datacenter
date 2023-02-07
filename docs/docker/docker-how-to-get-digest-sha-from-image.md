
# How to get the digest sha256 from local container image

```shell
$ docker manifest inspect lj020326/centos8-systemd-python:latest
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 2260,
         "digest": "sha256:6a4af078f06fe3e6e93ae20cc2cc6b78b83fd507dd6126f745972b5217ab4e8f",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 2260,
         "digest": "sha256:4348e70d616c8d180c70a66ba54451167cb9235b5e4b787146ba972169b68dd6",
         "platform": {
            "architecture": "arm64",
            "os": "linux"
         }
      }
   ]
}
```


To get the digest for the amd64 instance (first element in the example array):

```shell
$ docker manifest inspect lj020326/centos8-systemd-python:latest | jq .manifests[0].digest
"sha256:6a4af078f06fe3e6e93ae20cc2cc6b78b83fd507dd6126f745972b5217ab4e8f"
```


## Reference

* https://www.howtogeek.com/devops/what-is-a-docker-image-manifest/
* https://github.com/docker/hub-feedback/issues/2043#issuecomment-1161578466
* https://github.com/docker/hub-feedback/issues/2043
* https://github.com/docker/hub-feedback/issues/1925
* 
