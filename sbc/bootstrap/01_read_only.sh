#!/bin/bash    

# Configure time and logs
apt remove -y --purge rsyslog logrotate fake-hwclock
sed -i 's/driftfile \/var\/lib\/ntp\/ntp.drift/driftfile \/var\/tmp\/ntp.drift/' /etc/ntp.conf

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
