#!/bin/bash

set -e

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

get_image_url() {
	local VER="$1"
	if [ -z "$VER" ] || [ "$VER" == "latest" ]; then
		VER=$(curl --silent "https://api.github.com/repos/hypriot/image-builder-rpi/releases/latest" | jq -r .tag_name)
	fi
	if [ "$VER" == "arm64" ]; then
		echo "https://github.com/DieterReuter/image-builder-rpi64/releases/download/v20180429-184538/hypriotos-rpi64-v20180429-184538.img.zip"
		return
	fi
	echo "https://github.com/hypriot/image-builder-rpi/releases/download/${VER}/hypriotos-rpi-${VER}.img.zip"
	return
}

install_flash() {
	curl -O https://raw.githubusercontent.com/hypriot/flash/master/flash
	chmod +x flash
	mv flash /tmp/flash
	export PATH="/tmp:$PATH"
}

while getopts ":h:i:d:v:" opt; do
	case $opt in
	d)
		DEVICE=$OPTARG
		;;
	h)
		DEV_HOSTNAME=$OPTARG
		;;
	i)
		IMAGE=$OPTARG
		;;
	v)
		VERSION=$OPTARG
		[ "$VERSION" == "latest" ] && unset VERSION
		;;
	\?)
		echo -e "${R}Invalid option: -$OPTARG"
		echo -e "${Y}options:"
		echo -e "  -d - sd card device (default: /dev/mmcblk0)"
		echo -e "  -h - hostname"
		echo -e "  -r - role (default: generic). Choses bootstrap file from roles/ dir"
		echo -e "  -i - path or url to image. Takes precedence over '-v'"
		echo -e "  -v - HypriotOS version (default: latest). For rpi-arm64 use 'arm64'$RST"
		exit 1
		;;
	:)
		echo -e "${R}Option -$OPTARG requires an argument.${RST}" >&2
		exit 1
		;;
	esac
done

DEVICE="${DEVICE:-/dev/mmcblk0}"
VERSION="${VERSION:-latest}"
if [ -z "$IMAGE" ]; then
	IMAGE=$(get_image_url "$VERSION")
	REMOTE_IMAGE=y
fi
if [ -z "$DEV_HOSTNAME" ]; then
	echo -e "${R}No hostname specified (-h). Exiting.${RST}"
	exit 1
fi

echo -e "${G}Using following options:"
echo -e "  - DEVICE: $DEVICE"
echo -e "  - HOSTNAME: $DEV_HOSTNAME"
echo -e "  - IMAGE: ${IMAGE}${RST}"
if [ -n "$REMOTE_IMAGE" ]; then
	echo -e "${G}  - OS VERSION: ${VERSION}${RST}"
fi

echo -en "${Y}"
read -p "Do you want to proceed? [y/Y] " -n 1 -r
echo -e "${RST}"
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo -e "${R}Stopping...${RST}"
	exit 1
fi

command -v flash >/dev/null 2>&1 || install_flash

cp "config.yml" "/tmp/config.yml.tmp"
sed -i "s/<<HOSTNAME>>/$DEV_HOSTNAME/g" /tmp/config.yml.tmp

#flash --bootconf "config.txt" --userdata /tmp/config.yml.tmp --file "bootstrap/00_base.sh" --device "${DEVICE}" --hostname "${DEV_HOSTNAME}" "${IMAGE}"
flash --bootconf "config.txt" --userdata /tmp/config.yml.tmp --device "${DEVICE}" --hostname "${DEV_HOSTNAME}" "${IMAGE}"
rm /tmp/config.yml.tmp

sync
echo -e "${G}Flashing completed.${RST}"
echo -e "${G}Finished.${RST}"
sync
