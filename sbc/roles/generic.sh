#!/bin/bash    

# Configure time and logs
apt remove -y --purge rsyslog logrotate fake-hwclock
sed -i 's/driftfile \/var\/lib\/ntp\/ntp.drift/driftfile \/var\/tmp\/ntp.drift/' /etc/ntp.conf

# Get latest node_exporter version
if [ -z "${NODE_EXPORTER}" ]; then
    NODE_EXPORTER="$(curl -L https://api.github.com/repos/prometheus/node_exporter/releases/latest 2>/dev/null | grep '.tag_name' | cut -d'"' -f4)"
    NODE_EXPORTER=${NODE_EXPORTER//\"}
    NODE_EXPORTER=${NODE_EXPORTER//v}
fi

# Get processor architecture
case "$(uname -m)" in
  "aarch64") CPU_ARCH="arm64";;
  "armv7l") CPU_ARCH="armv7";;
  "armv6l") CPU_ARCH="armv6";;
esac

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
