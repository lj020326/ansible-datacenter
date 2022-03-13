FROM idealista/jdk:8u181-stretch-openjdk-headless
LABEL maintainer="idealista <labs@idealista.com>"

RUN apt-get update \
    && apt-get install -y sudo systemd systemd-sysv

EXPOSE 2181 2888 3888

CMD ["/sbin/init"]