#!/bin/bash
set -e

if [ "$container" == "podman" ]; then
  export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | head -n1`
else
  # Safely extract strictly the first nameserver IP address, ignoring trailing options/comments
  export NAMESERVER=`cat /etc/resolv.conf | grep -m1 "nameserver" | awk '{print $2}'`
fi

echo "Nameserver is: $NAMESERVER"

echo "Generating nginx config"
envsubst '$NAMESERVER' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# We cannot use upstream server groups with a DNS resolver without nginx plus
# So we modifying the files to use the variables rather than the upstream server groups
for file in /etc/nginx/pulp/*.conf ; do
  if [ -f "$file" ]; then
    echo "Modifying $file"
    sed -i 's/pulp-api/$pulp_api:24817/' "$file"
    sed -i 's/pulp-content/$pulp_content:24816/' "$file"
  fi
done

echo "Starting nginx"
exec nginx  -g "daemon off;"
