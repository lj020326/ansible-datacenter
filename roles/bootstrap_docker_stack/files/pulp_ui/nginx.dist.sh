#!/bin/bash
# This logic enables us to have multiple servers, and check to see
# if they are scaled every 10 seconds.
# https://serverfault.com/a/821625/189494
# https://www.nginx.com/blog/dns-service-discovery-nginx-plus#domain-name-variable

# source: https://github.com/pulp/pulp-oci-images/blob/latest/images/compose/assets/bin/nginx.sh

set -e

if [ "$container" == "podman" ]; then
  # the nameserver list under podman is unreliable.
  # It will look like "10.89.1.1 192.168.1.1 192.168.1.1", but only the 1st IP works.
  # This doesn't mess up `nslookup`, but it messes up `getent hosts` and nginx.
  export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | head -n1`
else
  export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`
fi

echo "Nameserver is: $NAMESERVER"

echo "Generating nginx config"
envsubst '$NAMESERVER' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# We cannot use upstream server groups with a DNS resolver without nginx plus
# So we modifying the files to use the variables rather than the upstream server groups
for file in /etc/nginx/pulp/*.conf ; do
  echo "Modifying $file"
  sed -i 's/pulp-api/$pulp_api:24817/' "$file"
  sed -i 's/pulp-content/$pulp_content:24816/' "$file"
done

echo "Starting nginx"
exec nginx  -g "daemon off;"
