
# Dockerfile ARG FROM ARG trouble with Docker

Using a dynamic [Dockerfile](https://docs.docker.com/engine/reference/builder/) can have great benefits when used in your CI/CD pipeline. You can use the `ARG` statement in your `Dockerfile` to pass in a variable at build time. Even use a variable in the `FROM` statement! Dockerfile ARG FROM ARG. That will make more sense later.

This post is about [Container virtualization technology](https://rancher.com/learning-paths/what-are-containers/), and problems when building a container image using [Docker Engine](https://www.docker.com/products/container-runtime).  
For some background on a dynamic Dockerfile, check out [Jeff Geerling’s post](https://www.jeffgeerling.com/blog/2017/use-arg-dockerfile-dynamic-image-specification).

One problem I’ve come across with this, is the `Dockerfile` `ARG` variable usage isn’t intuitive. It is actually kind of weird. And I’m not alone on this! There’s lots of feedback in [GitHub Issue #34129](https://github.com/moby/moby/issues/34129).

## What’s the Problem?

A variable declared at the top of the `Dockerfile` using `ARG` doesn’t work if you try to use it after the `FROM` statement. Not by default at least. It only works if used in the `FROM` statement.

```dockerfile
ARG TAG=latest
FROM myimage:$TAG # <------ This works!
LABEL BASE_IMAGE="myimage:$TAG" # <------ Does not work!
```

The `FROM` above will use the `TAG` passed in from a build-arg, or default to use the string “latest”.  
But the `LABEL` won’t work. The `TAG` portion will be empty!

This was tested with the most recent version of Docker Engine (version: 19.03.5).

## How Does it Work?

To use a variable in the `FROM` section, you need to put the `ARG` before the `FROM`. So far so good. But, now let’s use that variable again after the `FROM`? No you can’t. It’s not there. Unless you use another `ARG` statement after the `FROM`.  

Wait, it gets more weird. Any `ARG` before the FIRST `FROM`, can be used in any `FROM` (for multi-stage builds). In fact the `ARG` must be above the first `FROM` even if you only want to use it in a later `FROM`. Wow, that’s a lot of `ARG`s and `FROM`s. The `ARG` is kind of “global” but only if you declare it again inside the build stage.

Let’s look at an example to make it easier. Below is not a useful Dockerfile. It’s only an example to illustrate this.

```dockerfile
#These ARGs are used in the FROM statements
#Or as global variables if declared again (without the default value)
ARG BUILDER_TAG=latest
ARG BASE_TAG=latest
ARG APP="app.go"

#First build stage
FROM mybuildapp:$BUILDER_TAG AS builder
ARG APP
RUN compile_my_app $APP

#Second build stage
FROM registry.access.redhat.com/ubi8/ubi-minimal:$BASE_TAG
ARG BASE_TAG
ARG APP
LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:$BASE_TAG"
COPY --from=builder $APP .
```

Now, let’s run the example build:

```shell
docker build . \
  --pull
  --build-arg BUILDER_TAG="2.0" \
  --build-arg BASE_TAG="8.1" \
  --build-arg APP="the_best_app.go" \
  -t image_tag
```

Once the Docker build finishes, this is the result of your command line argument usage inside the docker image:

```dockerfile
BUILDER_TAG="2.0"
BASE_TAG="8.1"
APP="the_best_app.go"
```

## Results

The `BUILDER_TAG` and `BASE_TAG` will be used in the `FROM` statements. `BASE_TAG` is also used inside the second build stage. And `APP` will be used in both build stages. `ARG APP="app.go"` only needs to be declared if you want to set a default value. In my example we don’t really need that since we are passing in a build argument.

## Conclusion

Remember that `ARG`s at the top of the `Dockerfile` can be used in the `FROM` statements. They are “global” only if you declare the `ARG` again in each build stage (after `FROM` (and before the next `FROM` if using a multi-stage build)).  

You can remember it this way: `Dockerfile` `ARG` `FROM` `ARG`  
But, after wasting an hour on this, it was more like: Dockerfile _Arrggh!_ FROM _Arrggh!_

You can use something like this in your CI/CD, for automatic docker image building.

**Side note**: Building an image using [Podman](https://podman.io/) does not have the same issue as Docker Engine (tested with Podman version 1.4.4, 1.6.3, and 1.7.0). You do not need to specify the `ARG` again inside the build stage when Podman creates the container image!

## Reference

- [Dockerfile Reference: Understand how ARG and FROM interact](https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)
- [Dockerfile Reference: Scope](https://docs.docker.com/engine/reference/builder/#scope)
- [Multi-Stage Builds](https://docs.docker.com/develop/develop-images/multistage-build)
- [Docker FROM with args](https://ryandaniels.ca/blog/docker-dockerfile-arg-from-arg-trouble/)
