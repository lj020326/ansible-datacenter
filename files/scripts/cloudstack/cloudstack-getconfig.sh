#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

source ${SCRIPT_DIR}/.env

configFile=~/cloudstack-config.txt

echo "archiving last config"
snap_date=$(date +%Y%m%d_%H%M)

if [ -e ${configFile} ]; then
  mv ${configFile} ${configFile}.${snap_date}
fi

#echo "clearing out last config"
#cat /dev/null > ${configFile}

#listAlerts
#listConfigurations
#listInternalLoadBalancerElements
#listIpForwardingRules
#listLoadBalancers
#listNetworkDevice
#listPortableIpRanges
#listPublicIpAddresses
#listRouters
#listTrafficTypes physicalnetworkid=8d0ef6cc-9847-4408-8d12-d734969306f6
#listTrafficTypes physicalnetworkid=${physNetworkId}
#listNics

physicalNetworkIdList=$(cs listPhysicalNetworks | jq -r '.physicalnetwork|.[]|.id')

listTrafficTypeCommandList=()

for physicalNetworkId in ${physicalNetworkIdList}
do
  listTrafficTypeCommandList+=("listTrafficTypes physicalnetworkid=${physicalNetworkId}")
done

apiCommandList="
listNetworks
listNetworkServiceProviders
listPhysicalNetworks
${listTrafficTypeCommandList[@]}
listPods
listSecurityGroups
listVirtualRouterElements
listVlanIpRanges
listVPCs
listZones
"

#apiCommandList=( $(eval echo ${apiCommandList[@]}) )
#apiCommandList=("${apiCommandList[@]//\'/}")

run_api_command() {

  api_command="${@}"
#  api_command="${1}"
#  api_command="${api_command[@]//\"/}"

  echo "api_command=${api_command}"
  echo "**********************" >> $configFile
  echo "${api_command}" >> $configFile
  eval "cs ${api_command}" >> $configFile

}

IFS=$'\n'
for apiCommand in ${apiCommandList}
do
  echo "apiCommand=${apiCommand}"
  run_api_command ${apiCommand}
done

exit ${?}

