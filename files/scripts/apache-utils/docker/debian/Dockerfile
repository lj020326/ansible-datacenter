#Choose Debian
FROM debian:latest

MAINTAINER e071598 "lee.johnson@dettonville.com"

#Don't ask questions during install
ENV DEBIAN_FRONTEND noninteractive

#Install apache2 and enable proxy mode
RUN apt update && \
    INSTALL_PKGS="nano apache2" && \
    apt install -y $INSTALL_PKGS

RUN a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod proxy_connect && \
    a2enmod proxy_wstunnel && \
    a2enmod ssl && \
    a2enmod rewrite && \
    service apache2 stop

ENV HTTPD_MAIN_CONF_PATH=/etc/apache2/conf \
    HTTPD_MAIN_CONF_MODULES_D_PATH=/etc/apache2/conf.modules.d \
    HTTPD_MAIN_CONF_D_PATH=/etc/apache2/sites-available \
    HTTPD_MAIN_ENABLED_D_PATH=/etc/apache2/sites-enabled \
    HTTPD_VAR_RUN=/var/run/apache2 \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/opt/apache2/root/var/www \
    HTTPD_LOG_PATH=/var/log/apache2

#Ports
EXPOSE 80

#Volumes
VOLUME /opt/proxy-conf

#Launch Apache2 on FOREGROUND
COPY apache-proxy-start.sh /opt/
COPY setdevenv.sh /
RUN chmod +x /opt/apache-proxy-start.sh
RUN chmod +x /setdevenv.sh

ENTRYPOINT ["/opt/apache-proxy-start.sh"]
