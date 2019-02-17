#!/bin/bash

set -e

#COLORS
RST='\e[0m'
Y='\e[33m'
G='\e[32m'
R='\e[31m'

USER="paulfantom"

if [[ $EUID -ne 0 ]]; then
	echo -e "$R This script must be run as root. Exiting...$RST"
	exit 1
fi

echo -e "$Y Update system and install dependencies...$RST"
apt-get update
apt-get upgrade -y
apt-get install -y python3-pip python3-venv build-essential libssl-dev libffi-dev python3-dev nfs-kernel-server

# TODO: remove it
echo -e "$Y Create persistent mount config for remote resources and mount it...$RST"
mkdir -p /mnt/remote
if ! grep "/tmp" /etc/fstab; then
	echo "tmpfs /tmp tmpfs defaults,nosuid 0 0" >>/etc/fstab
	echo "nas.ankhmorpork:/mnt/sbc/vetinari /mnt/remote nfs rw,defaults,_netdev 0 0" >>/etc/fstab
fi
mount -a

echo -e "$Y Create homeassistant installation script...$RST"
cat <<EOF >/opt/hass_install.sh
#!/bin/bash
set -e
python3 -m venv homeassistant
cd homeassistant
source bin/activate
python3 -m pip install wheel
python3 -m pip install homeassistant
EOF
chmod +x /opt/hass_install.sh

echo -e "$Y Create homeassistant upgrade script...$RST"
cat <<EOF >/opt/hass_upgrade.sh
#!/bin/bash
set -e
cd /opt/homeassistant
source bin/activate
python3 -m pip install --upgrade homeassistant
EOF
chmod +x /opt/hass_upgrade.sh

echo -e "$Y Install homeassistant as $USER...$RST"
cd /opt
mkdir -p homeassistant
chown "$USER":"$USER" homeassistant
sudo -u "$USER" ./hass_install.sh

echo -e "$Y Create homeassistant systemd config...$RST"
cat <<EOF >/etc/systemd/system/hass.service
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=$USER
ExecStartPre=sleep 10
ExecStart=/opt/homeassistant/bin/hass -c "/mnt/remote/homeassistant"

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hass.service

echo -e "$Y Waiting for Home Assitant to finish first boot procedure...$RST"
while ! lsof -i :8123; do
	echo -n "."
	sleep 2
done

echo
echo -e "$G All done! You can now connect to home assistant on port 8123.$RST"
