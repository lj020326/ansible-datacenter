
# How the docker pull command works under the covers (with HTTP headers to illustrate the process)

I talked previously about needing to [decode docker HTTP headers to debug a registry issue](https://prefetch.net/blog/2020/07/16/using-the-sslsplit-mitm-proxy-to-capture-docker-registry-communications/). That debugging session was super fun, but I had a few questions about how that interaction actually works. So I started to decode all of the HTTP requests and responses from a $(docker pull), which truly helped me solidify how the docker daemon (dockerd) talks to a container registry. I figured I would share my notes here so I (as well as anyone else on the ‘net) can reference them in the future.

Here are the commands I ran prior to reviewing the client / server interactions:

$ `docker login harbor`

$ `docker pull harbor/nginx/ingress:v1.0.0`

There are a couple of interesting bits in these commands. First, the docker CLI utility doesn’t actually retrieve a container image. That job is delegated to the docker server daemon (dockerd). Second, when you type docker login, it will authenticate to the registry and cache your credentials in $HOME/.docker/config.json by default. Those are then used in future requests to the container registry.

Now on to the HTTP requests and responses. The first GET issued by dockerd is to the [/v2/ registry API endpoint](https://docs.docker.com/registry/spec/api/):

```
GET /v2/ HTTP/1.1
Host: harbor
User-Agent: docker/19.03.12
Accept-Encoding: gzip
Connection: close
```

The Harbor registry responds with a 401 unauthorized when we try to retrieve the URI /v2/. It also adds a Www-Authenticate: header with the path to the [registry’s token server](https://docs.docker.com/registry/spec/auth/jwt/):

```
HTTP/1.1 401 Unauthorized
Server: nginx
Date: Thu, 16 Jul 2020 18:59:45 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 87
Connection: close
Docker-Distribution-Api-Version: registry/2.0
Set-Cookie: beegosessionID=XYZ; Path=/; HttpOnly
Www-Authenticate: Bearer realm="https://harbor/service/token",service="harbor-registry"

{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":null}]}
```

Next, we try to retrieve an access token (a JWT in this case) from the token server:

```
GET /service/token?scope=repository%3Anginx%2Fingress%3Apull&service=harbor-registry HTTP/1.1
Host: harbor
User-Agent: docker/19.03.12
Accept-Encoding: gzip
Connection: close
```

The server responds with a 200 and an entity body (not included below) containing the access token (a JWT):

```
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 16 Jul 2020 18:59:45 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 959
Connection: close
Content-Encoding: gzip
Set-Cookie: beegosessionID=XYZ; Path=/; HttpOnly
```

The scope in the JWT controls what you can do, and to which repositories. So now that we have an access token, we can retrieve the manifest for the container image:

```
GET /v2/nginx/ingress/manifests/v1.0.0 HTTP/1.1
Host: harbor
User-Agent: docker/19.03.12
Accept: application/vnd.docker.distribution.manifest.v1+prettyjws
Accept: application/json
Accept: application/vnd.docker.distribution.manifest.v2+json
Accept: application/vnd.docker.distribution.manifest.list.v2+json
Accept: application/vnd.oci.image.index.v1+json
Accept: application/vnd.oci.image.manifest.v1+json
Authorization: Bearer JWT.JWT.JWT
Accept-Encoding: gzip
Connection: close
```

If you aren’t familiar with [manifests](https://docs.docker.com/registry/spec/manifest-v2-2/), they are JSON files that describe the container and the layers that make up the image. There is a schema which defines the manifest, and the following response shows an actual manifest sent back from the container registry:

```
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 16 Jul 2020 18:59:45 GMT
Content-Type: application/vnd.docker.distribution.manifest.v2+json
Content-Length: 1154
Connection: close
Docker-Content-Digest: sha256:a7425073232ed3fb26b45ec6b26482e53984692ce6265b64f85c6c68b72c3cc5
Docker-Distribution-Api-Version: registry/2.0
Etag: "sha256:a7425073232ed3fb26b45ec6b26482e53984692ce6265b64f85c6c68b72c3cc5"
Set-Cookie: beegosessionID=XYZ; Path=/; HttpOnly

{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
   "config": {
      "mediaType": "application/vnd.docker.container.image.v1+json",
      "size": 2556,
      "digest": "sha256:53a19cd1924db72bd427b3792cf8ee5be6f969caa33c7a32ed104a1561f37bb2"
   },
   "layers": [
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 701123,
         "digest": "sha256:2ea20e1f93179438e0f481d2f291580b0fd6808ce2c716e5f9fc961b2b038e4e"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 32,
         "digest": "sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 525239,
         "digest": "sha256:5c59e002a478e367ed6aa3c1d0b22b98abbb8091378ef4c273dbadb368b735b1"
      },
      {
         "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
         "size": 2087201,
         "digest": "sha256:d1d2b2330ff21c60d278fb02908491f59868b942c6433e8699e405764bca5645"
      }
   ]
```

In the manifest above, you can see the manifest version, the media type, and the image layers that make up the container image. This is all described in the [official documentation](https://docs.docker.com/registry/spec/manifest-v2-2/). Now that dockerd knows the container image layout, if will retrieve one or more image layers in parallel (how many images to retrieve in parallel is controlled with the “–max-concurrent-download” option):

```
GET /v2/nginx/ingress/blobs/sha256:2ea20e1f93179438e0f481d2f291580b0fd6808ce2c716e5f9fc961b2b038e4e HTTP/1.1
Host: harbor
User-Agent: docker/19.03.12
Accept-Encoding: identity
Authorization: Bearer JWT.JWT.JWT
Connection: close
```

And that’s it. After all of the image layers are pulled, the next step would typically be to start a [docker container](https://prefetch.net/blog/2019/11/11/how-the-docker-container-creation-process-works-from-docker-run-to-runc/)\`. Had a blast looking into this!


## Reference

* https://prefetch.net/blog/2020/07/22/how-the-docker-pull-command-works-under-the-covers-with-http-headers-to-illustrate-the-process/
