#!/usr/bin/env bash

echo "Set virtualhost configs"
rm -f ${HTTPD_MAIN_CONF_D_PATH}/*
cp /opt/proxy-conf/sites/*.conf ${HTTPD_MAIN_CONF_D_PATH}

echo "Enable site(s)"
rm -f ${HTTPD_MAIN_ENABLED_D_PATH}/*
ls ${HTTPD_MAIN_CONF_D_PATH}/ -1A | a2ensite *.conf

echo "Remove pre-existing PID files"
rm -f ${HTTPD_VAR_RUN}/apache2.pid

echo "Remove existing logs before starting"
rm -f ${HTTPD_LOG_PATH}/*log

echo "Launch Apache on Foreground"
/usr/sbin/apache2ctl -D FOREGROUND
