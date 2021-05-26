#!/usr/bin/env bash

echo "Set httpd configs"
rm -f ${HTTPD_MAIN_CONF_PATH}/*
cp /opt/proxy-conf/*.conf ${HTTPD_MAIN_CONF_PATH}

echo "Set virtualhost configs"
rm -f ${HTTPD_MAIN_CONF_D_PATH}/*
cp /opt/proxy-conf/sites/*.conf ${HTTPD_MAIN_CONF_D_PATH}

echo "Set module configs"
rm -f ${HTTPD_MAIN_CONF_MODULES_D_PATH}/*
cp /opt/proxy-conf/modules/*.conf ${HTTPD_MAIN_CONF_MODULES_D_PATH}

echo "Remove pre-existing PID files"
rm -f ${HTTPD_VAR_RUN}/httpd.pid

echo "Remove existing logs before starting"
rm -f ${HTTPD_LOG_PATH}/*log

echo "Launch Apache httpd on Foreground"
/usr/sbin/httpd -D FOREGROUND
