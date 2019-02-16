#!/bin/bash

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

# hypriotOS images:
# odroid c2: https://github.com/hypriot/image-builder-odroid-c2/releases/download/v0.3.1/hypriotos-odroid-c2-v0.3.1.img.zip
# rpi 3:  https://github.com/hypriot/image-builder-rpi/releases/download/v1.7.1/hypriotos-rpi-v1.7.1.img.zip

echo -e "${Y}Insert SD card and provide hostname${RST}"
read -r HOSTNAME
echo -e "${Y}Choose your SBC:\\n${R} oc2${G} - Odroid C2\\n${R} rpi${G} - Raspberry Pi${RST}"
read -r PLATFORM
case "${PLATFORM}" in
"oc2")
	VERSION="v0.3.1"
	IMAGE="https://github.com/hypriot/image-builder-odroid-c2/releases/download/${VERSION}/hypriotos-odroid-c2-${VERSION}.img.zip"
	echo -e "${R}login: pirate, password: hypriot${RST}"
	flash --device /dev/mmcblk0 --hostname "${HOSTNAME}" "${IMAGE}"
	;;
"rpi")
	VERSION="v1.10.0"
	IMAGE="https://github.com/hypriot/image-builder-rpi/releases/download/${VERSION}/hypriotos-rpi-${VERSION}.img.zip"
	flash --bootconf config.txt --userdata config.yml --device /dev/mmcblk0 --hostname "${HOSTNAME}" "${IMAGE}"
	;;
esac
sync
