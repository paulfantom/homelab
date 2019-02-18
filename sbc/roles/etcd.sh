#!/bin/bash    

# Install packages
apt install -y open-iscsi nfs-common

# Get iSCSI configuration
if [ -z "${ISCSI_TARGET}" ]; then
    ISCSI_TARGET="192.168.1.3"
fi
if [ -z "${ISCSI_IQN}" ]; then
    ISCSI_IQN="iqn.2018-09.ankhmorpork.nas:$(hostname)"
fi

# Configure iSCSI
echo "InitiatorName=iqn.2018-09.ankhmorpork.k8s:$(hostname)" > /etc/iscsi/initiatorname.iscsi
iscsiadm -m discovery -t st -p "${ISCSI_TARGET}"
iscsiadm -m node -T "${ISCSI_IQN}" -o update -n node.startup -v automatic

# Create mountpoints and mount config
mkdir -p /mnt/remote
if ! grep "/dev/sda" /etc/fstab; then
	# shellcheck disable=SC2129
	echo "/dev/sda /var/lib/docker ext4 defaults,_netdev,nofail 0 0" >>/etc/fstab
	echo "nas.ankhmorpork:/mnt/ssd/raspberry/$(hostname) /mnt/remote nfs defaults,_netdev,nofail 0 0" >>/etc/fstab
	echo "/mnt/remote/kubernetes /etc/kubernetes none bind,defaults,nofail 0 0" >>/etc/fstab
fi
mount -a

# Configure time and logs
apt remove -y --purge rsyslog logrotate fake-hwclock
sed -i 's/driftfile \/var\/lib\/ntp\/ntp.drift/driftfile \/var\/tmp\/ntp.drift/' /etc/ntp.conf

# Get processor architecture
case "$(uname -m)" in
  "aarch64") CPU_ARCH="arm64";;
  "armv7l") CPU_ARCH="armv7";;
  "armv6l") CPU_ARCH="armv6";;
esac

# Get latest node_exporter version
if [ -z "${NODE_EXPORTER}" ]; then
    NODE_EXPORTER="$(curl https://api.github.com/repos/prometheus/node_exporter/releases/latest 2>/dev/null | jq .tag_name)"
    NODE_EXPORTER=${NODE_EXPORTER//\"}
    NODE_EXPORTER=${NODE_EXPORTER//v}
fi

# Install node_exporter
wget "https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER/node_exporter-$NODE_EXPORTER.linux-$CPU_ARCH.tar.gz" -P /tmp/
tar -xvf "/tmp/node_exporter-$NODE_EXPORTER.linux-$CPU_ARCH.tar.gz" -C /tmp
mv "/tmp/node_exporter-$NODE_EXPORTER.linux-$CPU_ARCH/node_exporter" /usr/local/bin/
chmod +x /usr/local/bin/node_exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:9100
SyslogIdentifier=node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable node_exporter

# Remount to Read-Only on ssh exit
cat <<EOF > /opt/pam_session.sh
#!/bin/bash
if [ "$PAM_TYPE" = "close_session" ]; then
    mount -o remount,ro /
fi
EOF
chmod +x /opt/pam_session.sh
# echo 'session     optional    pam_exec.so quiet /opt/pam_session.sh' >> /etc/pam.d/sshd
echo 'alias ro="sudo mount -o remount,ro /"' >> /etc/bash.bashrc
echo 'alias rw="sudo mount -o remount,rw /"' >> /etc/bash.bashrc

### Next lines are needed only when installing k8s

# Link k8s config from NFS
ln -s /mnt/remote/kubernetes /etc/kubernetes

# Add kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm
