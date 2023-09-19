#!/usr/bin/env bash

##################
## This script is a modified version of the publicly available script:
## https://raw.githubusercontent.com/moby/moby/master/contrib/download-frozen-image-v2.sh
##
## ref: https://github.com/schnatterer/docker-image-size/blob/master/scripts/docker-image-size-curl.sh
## ref: https://gitlab.com/-/snippets/2483762/raw/main/download-gitlab-frozen-docker-image.sh
##################

set -eo pipefail

## https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TMP_DIR=$(mktemp -d -p ~)

## ref: https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash
IMAGE_TAR_FILE=$(mktemp -u --suffix ".tgz")
IMAGE_TAR_FILE_SAVE=0

## keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
## echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
#trap 'rm -fr "${TMP_DIR}"' EXIT
#trap '[ "${IMAGE_TAR_FILE_SAVE}" ] || rm -fr "${IMAGE_TAR_FILE}"' EXIT'

LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

logLevel=${LOG_DEBUG}
#logLevel=${LOG_INFO}


# hacky workarounds for Bash 3 support (no associative arrays)
images=()
rm -f "${TMP_DIR}"/tags-*.tmp
manifestJsonEntries=()
doNotGenerateManifestJson=
# repositories[busybox]='"latest": "...", "ubuntu-14.04": "..."'

# bash v4 on Windows CI requires CRLF separator... and linux doesn't seem to care either way
newlineIFS=$'\n'
major=$(echo "${BASH_VERSION%%[^0.9]}" | cut -d. -f1)
if [ "$major" -ge 4 ]; then
	newlineIFS=$'\r\n'
fi

registryBase="https://index.docker.io"
#registryBase='https://registry-1.docker.io'
#registryBase="https://registry.hub.docker.com"
#registryBase="https://registry.docker.io"
#registryBase="https://hub.docker.com"

authBase='https://auth.docker.io'
authService='registry.docker.io'

## ref: https://stackoverflow.com/questions/69335984/problems-calling-dockers-v2-name-manifest-tag-api
declare -a dockerHttpHeaderArray
dockerHttpHeaderArray+=("application/vnd.docker.distribution.manifest.v2+json")
dockerHttpHeaderArray+=("application/vnd.docker.distribution.manifest.list.v2+json")
dockerHttpHeaderArray+=("application/vnd.oci.image.manifest.v1+json")
dockerHttpHeaderArray+=("application/vnd.oci.image.index.v1+json")

###################
## we substitute the minus sign in `-H` with the respective octal code (\055H)
## ref: https://superuser.com/questions/1371834/escaping-hyphens-with-printf-in-bash
#DELIM='-H Accept:'
DELIM='\055H Accept:'
printf -v dockerHttpCurlHeaders "${DELIM}%s " "${dockerHttpHeaderArray[@]}"
dockerHttpCurlHeaders="${dockerHttpCurlHeaders% }"


function main() {

  checkRequiredCommands curl jq

  while getopts "f:hx" opt; do
      case "${opt}" in
          f)
              IMAGE_TAR_FILE="${OPTARG}"
              IMAGE_TAR_FILE_SAVE=1
              ;;
          x) LOG_LEVEL=$LOG_DEBUG ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          :)
              echo "Option -$OPTARG requires an argument." >&2
              usage
              ;;
          *)
              usage
              ;;
      esac
  done
  shift $((OPTIND-1))

  if [ $# -lt 1 ]; then
      echo "required image[:tag][@digest] argument(s) not specified" >&2
      usage
  fi

  while [ $# -gt 0 ]; do
    queryManifest "${1}"
    shift
  done

  echo -n '{' > "${TMP_DIR}/repositories"
  firstImage=1
  for image in "${images[@]}"; do
    imageFile="${image//\//_}" # "/" can't be in filenames :)
    image="${image#library\/}"

    [ "$firstImage" ] || echo -n ',' >> "${TMP_DIR}/repositories"
    firstImage=
    echo -n $'\n\t' >> "${TMP_DIR}/repositories"
    echo -n '"'"$image"'": { '"$(cat "${TMP_DIR}/tags-$imageFile.tmp")"' }' >> "${TMP_DIR}/repositories"
  done
  echo -n $'\n}\n' >> "${TMP_DIR}/repositories"

  rm -f "${TMP_DIR}"/tags-*.tmp

  if [ -z "$doNotGenerateManifestJson" ] && [ "${#manifestJsonEntries[@]}" -gt 0 ]; then
    echo '[]' | jq --raw-output ".$(for entry in "${manifestJsonEntries[@]}"; do echo " + [ $entry ]"; done)" > "${TMP_DIR}/manifest.json"
  else
    rm -f "${TMP_DIR}/manifest.json"
  fi

  #echo "Download of images into '${TMP_DIR}' complete."
  #echo "Use something like the following to load the result into a Docker daemon:"
  #echo "  tar -cC '${TMP_DIR}' . | docker load"

  echo "Creating tar file [${IMAGE_TAR_FILE}] for docker load"
  tar -c -C "${TMP_DIR}" -f "${IMAGE_TAR_FILE}" .

  echo "Loading image into docker"
  docker load < "${IMAGE_TAR_FILE}"

}


logError() {
  if [ $logLevel -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ${1}"
  fi
}
logWarn() {
  if [ $logLevel -ge $LOG_WARN ]; then
  	echo -e "[WARN]: ${1}"
  fi
}
logInfo() {
  if [ $logLevel -ge $LOG_INFO ]; then
  	echo -e "[INFO]: ${1}"
  fi
}
logTrace() {
  if [ $logLevel -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ${1}"
  fi
}
logDebug() {
  if [ $logLevel -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ${1}"
  fi
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"
    do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done

    if [[ ! -z "${missingCommands}" ]]; then
        fail "checkRequiredCommands(): Please install the following commands required by this script:${missingCommands}"
    fi
}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}


usage() {
  echo "Usage: ${0} [options] image[:tag][@digest] ..."
  echo ""
  echo "  Options:"
  echo "     -f image_tar_file.tgz : Image tar (tgz) file to be created from downloaded image(s)."
  echo "                             Default will create a temporary file for `docker load` and removed after complete."
  echo ""
  echo "  Required:"
  echo "     image[:tag][@digest]"
  echo ""
  echo "  Examples:"
	echo "       ${0} alpine:latest"
  echo "       ${0} -f testimage.tgz build alpine:latest"
	echo "       ${0} nginx/nginx-ingress:latest"
	echo "       ${0} hello-world:latest"
	echo "       ${0} hello-world:latest@sha256:8be990ef2aeb16dbcb9271ddfe2610fa6658d13f6dfb8bc72074cc1ca36966a7"
	[ -z "$1" ] || exit "$1"
}

# https://github.com/moby/moby/issues/33700
function fetch_blob() {
	local token="$1"
	shift
	local image="$1"
	shift
	local digest="$1"
	shift
	local targetFile="$1"
	shift
	local curlArgs=("$@")

	local curlHeaders
	curlHeaders="$(
		curl -S "${curlArgs[@]}" \
			-H "Authorization: Bearer $token" \
			"$registryBase/v2/$image/blobs/$digest" \
			-o "$targetFile" \
			-D-
	)"
	curlHeaders="$(echo "$curlHeaders" | tr -d '\r')"
	if grep -qE "^HTTP/[0-9].[0-9] 3" <<< "$curlHeaders"; then
		rm -f "$targetFile"

		local blobRedirect
		blobRedirect="$(echo "$curlHeaders" | awk -F ': ' 'tolower($1) == "location" { print $2; exit }')"
		if [ -z "$blobRedirect" ]; then
			echo >&2 "error: failed fetching '$image' blob '$digest'"
			echo "$curlHeaders" | head -1 >&2
			return 1
		fi

		curl -fSL "${curlArgs[@]}" \
			"$blobRedirect" \
			-o "$targetFile"
	fi
}

# handle 'application/vnd.docker.distribution.manifest.v2+json' manifest
function handle_single_manifest_v2() {
	local manifestJson="$1"
	shift

	local configDigest
	configDigest="$(echo "$manifestJson" | jq --raw-output '.config.digest')"
	local imageId="${configDigest#*:}" # strip off "sha256:"

	local configFile="$imageId.json"
	fetch_blob "$token" "$image" "$configDigest" "${TMP_DIR}/$configFile" -s

	local layersFs
	layersFs="$(echo "$manifestJson" | jq --raw-output --compact-output '.layers[]')"
	local IFS="$newlineIFS"
	local layers
	mapfile -t layers <<< "$layersFs"
	unset IFS

	echo "Downloading '$imageIdentifier' (${#layers[@]} layers)..."
	local layerId=
	local layerFiles=()
	for i in "${!layers[@]}"; do
		local layerMeta="${layers[$i]}"

		local layerMediaType
		layerMediaType="$(echo "$layerMeta" | jq --raw-output '.mediaType')"
		local layerDigest
		layerDigest="$(echo "$layerMeta" | jq --raw-output '.digest')"

		# save the previous layer's ID
		local parentId="$layerId"
		# create a new fake layer ID based on this layer's digest and the previous layer's fake ID
		layerId="$(echo "$parentId"$'\n'"$layerDigest" | sha256sum | cut -d' ' -f1)"
		# this accounts for the possibility that an image contains the same layer twice (and thus has a duplicate digest value)

		mkdir -p "${TMP_DIR}/$layerId"
		echo '1.0' > "${TMP_DIR}/$layerId/VERSION"

		if [ ! -s "${TMP_DIR}/$layerId/json" ]; then
			local parentJson
			parentJson="$(printf ', parent: "%s"' "$parentId")"
			local addJson
			addJson="$(printf '{ id: "%s"%s }' "$layerId" "${parentId:+$parentJson}")"
			# this starter JSON is taken directly from Docker's own "docker save" output for unimportant layers
			jq "$addJson + ." > "${TMP_DIR}/$layerId/json" <<- 'EOJSON'
				{
					"created": "0001-01-01T00:00:00Z",
					"container_config": {
						"Hostname": "",
						"Domainname": "",
						"User": "",
						"AttachStdin": false,
						"AttachStdout": false,
						"AttachStderr": false,
						"Tty": false,
						"OpenStdin": false,
						"StdinOnce": false,
						"Env": null,
						"Cmd": null,
						"Image": "",
						"Volumes": null,
						"WorkingDir": "",
						"Entrypoint": null,
						"OnBuild": null,
						"Labels": null
					}
				}
			EOJSON
		fi

		case "$layerMediaType" in
			*"application/vnd.docker.image.rootfs.diff.tar.gzip"* | *"application/vnd.oci.image.layer.v1.tar+gzip"*)
				local layerTar="$layerId/layer.tar"
				layerFiles=("${layerFiles[@]}" "$layerTar")
				# TODO figure out why "-C -" doesn't work here
				# "curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume."
				# "HTTP/1.1 416 Requested Range Not Satisfiable"
				if [ -f "${TMP_DIR}/$layerTar" ]; then
					# TODO hackpatch for no -C support :'(
					echo "skipping existing ${layerId:0:12}"
					continue
				fi
				local token
				token="$(curl -fsSL "$authBase/token?service=$authService&scope=repository:$image:pull" | jq --raw-output '.token')"
				fetch_blob "$token" "$image" "$layerDigest" "${TMP_DIR}/$layerTar" --progress-bar
				;;

			*)
				echo >&2 "error: unknown layer mediaType ($imageIdentifier, $layerDigest): '$layerMediaType'"
				exit 1
				;;
		esac
	done

	# change "$imageId" to be the ID of the last layer we added (needed for old-style "repositories" file which is created later -- specifically for older Docker daemons)
	imageId="$layerId"

	# munge the top layer image manifest to have the appropriate image configuration for older daemons
	local imageOldConfig
	imageOldConfig="$(jq --raw-output --compact-output '{ id: .id } + if .parent then { parent: .parent } else {} end' "${TMP_DIR}/$imageId/json")"
	jq --raw-output "$imageOldConfig + del(.history, .rootfs)" "${TMP_DIR}/$configFile" > "${TMP_DIR}/$imageId/json"

	local manifestJsonEntry
	manifestJsonEntry="$(
		echo '{}' | jq --raw-output '. + {
			Config: "'"$configFile"'",
			RepoTags: ["'"${image#library\/}:$tag"'"],
			Layers: '"$(echo '[]' | jq --raw-output ".$(for layerFile in "${layerFiles[@]}"; do echo " + [ \"$layerFile\" ]"; done)")"'
		}'
	)"
	manifestJsonEntries=("${manifestJsonEntries[@]}" "$manifestJsonEntry")
}

function get_target_arch() {
	if [ -n "${TARGETARCH:-}" ]; then
		echo "${TARGETARCH}"
		return 0
	fi

	if type "go" > /dev/null 2>&1; then
		go env GOARCH
		return 0
	fi

	if type "dpkg" > /dev/null 2>&1; then
		debArch="$(dpkg --print-architecture)"
		case "${debArch}" in
			armel | armhf)
				echo "arm"
				return 0
				;;
			*64el)
				echo "${debArch%el}le"
				return 0
				;;
			*)
				echo "${debArch}"
				return 0
				;;
		esac
	fi

	if type "uname" > /dev/null 2>&1; then
		uArch="$(uname -m)"
		case "${uArch}" in
			x86_64)
				echo amd64
				return 0
				;;
			arm | armv[0-9]*)
				echo arm
				return 0
				;;
			aarch64)
				echo arm64
				return 0
				;;
			mips*)
				echo >&2 "I see you are running on mips but I don't know how to determine endianness yet, so I cannot select a correct arch to fetch."
				echo >&2 "Consider installing \"go\" on the system which I can use to determine the correct arch or specify it explicitly by setting TARGETARCH"
				exit 1
				;;
			*)
				echo "${uArch}"
				return 0
				;;
		esac

	fi

	# default value
	echo >&2 "Unable to determine CPU arch, falling back to amd64. You can specify a target arch by setting TARGETARCH"
	echo amd64
}

function get_target_variant() {
	echo "${TARGETVARIANT:-}"
}

function queryManifest() {
  imageTag="${1}"

	image="${imageTag%%[:@]*}"
	imageTag="${imageTag#*:}"
	digest="${imageTag##*@}"
	tag="${imageTag%%@*}"

	# add prefix library if passed official image
	if [[ "$image" != *"/"* ]]; then
		image="library/$image"
	fi

	imageFile="${image//\//_}" # "/" can't be in filenames :)

	token="$(curl -fsSL "$authBase/token?service=$authService&scope=repository:$image:pull" | jq --raw-output '.token')"

	manifestJson="$(
		curl -fsSL \
			-H "Authorization: Bearer $token" \
			${dockerHttpCurlHeaders} \
			"$registryBase/v2/$image/manifests/$digest"
	)"
	if [ "${manifestJson:0:1}" != '{' ]; then
		echo >&2 "error: /v2/$image/manifests/$digest returned something unexpected:"
		echo >&2 "  $manifestJson"
		exit 1
	fi

	imageIdentifier="$image:$tag@$digest"

	schemaVersion="$(echo "$manifestJson" | jq --raw-output '.schemaVersion')"
	case "$schemaVersion" in
		2)
			mediaType="$(echo "$manifestJson" | jq --raw-output '.mediaType')"

			case "$mediaType" in
				*"application/vnd.docker.distribution.manifest.v2+json"* \
				| *"application/vnd.oci.image.manifest.v1+json"* )
					handle_single_manifest_v2 "$manifestJson"
					;;
        *"application/vnd.docker.distribution.manifest.list.v2+json"* \
        | *"application/vnd.oci.image.index.v1+json"*)
					layersFs="$(echo "$manifestJson" | jq --raw-output --compact-output '.manifests[]')"
					IFS="$newlineIFS"
					mapfile -t layers <<< "$layersFs"
					unset IFS

					found=""
					targetArch="$(get_target_arch)"
					targetVariant="$(get_target_variant)"
					# parse first level multi-arch manifest
					for i in "${!layers[@]}"; do
						layerMeta="${layers[$i]}"
						maniArch="$(echo "$layerMeta" | jq --raw-output '.platform.architecture')"
						maniVariant="$(echo "$layerMeta" | jq --raw-output '.platform.variant')"
						if [[ "$maniArch" = "${targetArch}" ]] && [[ -z "${targetVariant}" || "$maniVariant" = "${targetVariant}" ]]; then
							digest="$(echo "$layerMeta" | jq --raw-output '.digest')"
							# get second level single manifest
							submanifestJson="$(
								curl -fsSL \
									-H "Authorization: Bearer $token" \
            			${dockerHttpCurlHeaders} \
									"$registryBase/v2/$image/manifests/$digest"
							)"
							handle_single_manifest_v2 "$submanifestJson"
							found="found"
							break
						fi
					done
					if [ -z "$found" ]; then
						echo >&2 "error: manifest for ${targetArch}${targetVariant:+/${targetVariant}} is not found"
						exit 1
					fi
					;;
				*)
					echo >&2 "error: unknown manifest mediaType ($imageIdentifier): '$mediaType'"
					exit 1
					;;
			esac
			;;

		1)
			if [ -z "$doNotGenerateManifestJson" ]; then
				echo >&2 "warning: '$imageIdentifier' uses schemaVersion '$schemaVersion'"
				echo >&2 "  this script cannot (currently) recreate the 'image config' to put in a 'manifest.json' (thus any schemaVersion 2+ images will be imported in the old way, and their 'docker history' will suffer)"
				echo >&2
				doNotGenerateManifestJson=1
			fi

			layersFs="$(echo "$manifestJson" | jq --raw-output '.fsLayers | .[] | .blobSum')"
			IFS="$newlineIFS"
			mapfile -t layers <<< "$layersFs"
			unset IFS

			history="$(echo "$manifestJson" | jq '.history | [.[] | .v1Compatibility]')"
			imageId="$(echo "$history" | jq --raw-output '.[0]' | jq --raw-output '.id')"

			echo "Downloading '$imageIdentifier' (${#layers[@]} layers)..."
			for i in "${!layers[@]}"; do
				imageJson="$(echo "$history" | jq --raw-output ".[${i}]")"
				layerId="$(echo "$imageJson" | jq --raw-output '.id')"
				imageLayer="${layers[$i]}"

				mkdir -p "${TMP_DIR}/$layerId"
				echo '1.0' > "${TMP_DIR}/$layerId/VERSION"

				echo "$imageJson" > "${TMP_DIR}/$layerId/json"

				# TODO figure out why "-C -" doesn't work here
				# "curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume."
				# "HTTP/1.1 416 Requested Range Not Satisfiable"
				if [ -f "${TMP_DIR}/$layerId/layer.tar" ]; then
					# TODO hackpatch for no -C support :'(
					echo "skipping existing ${layerId:0:12}"
					continue
				fi
				token="$(curl -fsSL "$authBase/token?service=$authService&scope=repository:$image:pull" | jq --raw-output '.token')"
				fetch_blob "$token" "$image" "$imageLayer" "${TMP_DIR}/$layerId/layer.tar" --progress-bar
			done
			;;

		*)
			echo >&2 "error: unknown manifest schemaVersion ($imageIdentifier): '$schemaVersion'"
			exit 1
			;;
	esac

	echo

	if [ -s "${TMP_DIR}/tags-$imageFile.tmp" ]; then
		echo -n ', ' >> "${TMP_DIR}/tags-$imageFile.tmp"
	else
		images=("${images[@]}" "$image")
	fi
	echo -n '"'"$tag"'": "'"$imageId"'"' >> "${TMP_DIR}/tags-$imageFile.tmp"
}

main "$@"
