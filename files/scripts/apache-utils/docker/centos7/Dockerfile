## ref: https://stackoverflow.com/questions/40948369/how-to-create-a-docker-image-of-centos-provisioned-with-apache
FROM    centos:7

MAINTAINER e071598 "lee.johnson@dettonville.com"

#RUN yum update && yum install httpd httpd-tools -y

#RUN yum install -y yum-utils && \
#    yum install -y centos-release-scl epel-release && \
#    INSTALL_PKGS="gettext hostname nss_wrapper bind-utils httpd24 httpd-tools httpd24-mod_ssl httpd24-mod_auth_mellon" && \
#    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
#    rpm -V $INSTALL_PKGS && \
#    yum clean all

RUN yum update --setopt=tsflags=nodocs -y && \
    INSTALL_PKGS="nano hostname httpd httpd-tools" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum clean all

ENV HTTPD_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/httpd/ \
    HTTPD_APP_ROOT=${APP_ROOT} \
    HTTPD_CONFIGURATION_PATH=${APP_ROOT}/etc/httpd.d \
    HTTPD_MAIN_CONF_PATH=/etc/httpd/conf \
    HTTPD_MAIN_CONF_MODULES_D_PATH=/etc/httpd/conf.modules.d \
    HTTPD_MAIN_CONF_D_PATH=/etc/httpd/conf.d \
    HTTPD_VAR_RUN=/var/run/httpd \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/opt/httpd/root/var/www \
    HTTPD_LOG_PATH=/var/log/httpd

EXPOSE  80

#Volumes
VOLUME /opt/proxy-conf

#Launch Apache2 on FOREGROUND
COPY apache-proxy-start.sh /opt/
COPY setdevenv.sh /
RUN chmod +x /opt/apache-proxy-start.sh
RUN chmod +x /setdevenv.sh

ENTRYPOINT ["/opt/apache-proxy-start.sh"]
