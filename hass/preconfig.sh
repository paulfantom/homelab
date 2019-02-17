#!/bin/bash

set -e

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

IP="$1"
USER="$2"
TMP_PASS="$3"

if [ -z "$IP" ] || [ -z "$USER" ] || [ -z "$TMP_PASS" ]; then
	echo -e "$R""You need to pass IP address of odroid device which needs to be configured as well as user and root password."
	echo -e "Execute script as:$RST '$0 IP_ADDRESS USER TEMPORARY_PASSWORD'"
	exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
	echo -e "$R""Cannot find 'sshpass' program needed by this script. Exiting."
	exit 1
fi

echo -e "$Y Enabling passwordless SSH login...$RST"
sshpass -p "$TMP_PASS" ssh-copy-id "root@$IP"
sshpass -p "$TMP_PASS" ssh-copy-id "$USER@$IP"

echo -e "$Y Enabling passwordless sudo...$RST"
ssh "root@$IP" "sed -r -i 's/(%sudo\s+ALL=\(ALL:ALL\)\s+)ALL/\1NOPASSWD:ALL/g' /etc/sudoers"

echo -e "$Y Verify ssh connection and sudo priviledge escalation...$RST"
ssh "$USER@$IP" "sudo ls / >/dev/null"

echo -e "$Y Removing default password for root and user '$USER'...$RST"
#shellcheck disable=SC2029
ssh "root@$IP" passwd -d "$USER"
ssh "root@$IP" passwd -d "root"

echo -e "$G All done! You can now ssh into your raspberry with 'ssh $USER@$IP'$RST"
