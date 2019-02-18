#!/bin/bash
# shellcheck disable=SC2029

set -e

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

IP="$1"
NODENAME="$2"

if [ -z "$IP" ] || [ -z "$USER" ] || [ -z "$NODENAME" ]; then
	echo -e "${R}You need to pass IP address of rpi device which needs to be configured as well as its hostname."
	echo -e "Execute script as:$RST '$0 IP_ADDRESS HOSTNAME'"
	exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
	echo -e "$R""Cannot find 'sshpass' program needed by this script. Exiting."
	exit 1
fi

echo -e "$Y Enabling passwordless SSH login as root...$RST"
sshpass -p "raspberry" ssh-copy-id "root@$IP"

echo -e "$Y Install sudo...$RST"
ssh "root@$IP" "apt-get update && apt-get install -y sudo"

echo -e "$Y Create user $USER and copy ssh public key...$RST"
ssh "root@$IP" "useradd -m -s /bin/bash -G sudo $USER"
ssh "root@$IP" "mkdir -p /home/$USER/.ssh"
ssh "root@$IP" "cp /root/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys"
ssh "root@$IP" "chown -R $USER:$USER /home/$USER/.ssh"

echo -e "$Y Enabling passwordless sudo...$RST"
ssh "root@$IP" "sed -r -i 's/(%sudo\s+ALL=\(ALL:ALL\)\s+)ALL/\1NOPASSWD:ALL/g' /etc/sudoers"

echo -e "$Y Removing default password for root...$RST"
ssh "root@$IP" passwd -d "root"

echo -e "$Y Change hostname to $NODENAME...$RST"
ssh "root@$IP" "hostnamectl set-hostname $NODENAME"

echo -e "$Y Reboot...$RST"
ssh "root@$IP" "reboot" || :
sleep 4

echo -e "$Y Wait for host to come back, verify ssh connection and sudo priviledge escalation...$RST"
until ssh "$USER@$IP" "sudo ls / >/dev/null"; do
	sleep 1
	echo -n '.'
done

echo -e "$G All done! You can now ssh into your raspberry with 'ssh $USER@$IP'$RST"
