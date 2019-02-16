#!/bin/bash

set -e

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

IP="$1"

if [ -z "$IP" ]; then
	echo -e "$R""You need to pass IP address of raspberry which needs to be configured."
	echo -e "Execute script as:$RST '$0 IP_ADDRESS'"
	exit 1
fi

if command -v sshpass >/dev/null 2>&1; then
	echo -e "$R""Cannot find 'sshpass' program needed by this script. Exiting."
	exit 1
fi

echo -e "$Y Enabling passwordless SSH login...$RST"
sshpass -p raspberry ssh-copy-id "pi@$IP"

# Passwordless sudo is enabled by default
#echo -e "$Y Enabling passwordless sudo...$RST"

echo -e "$Y Removing default password for user 'pi'...$RST"
ssh "pi@$IP" sudo passwd -d pi

echo -e "$G All done! You can now ssh into your raspberry with 'ssh pi@$IP'$RST"
