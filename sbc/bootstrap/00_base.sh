#!/bin/bash    

# Configure time and logs
apt remove -y --purge rsyslog logrotate fake-hwclock
sed -i 's/driftfile \/var\/lib\/ntp\/ntp.drift/driftfile \/var\/tmp\/ntp.drift/' /etc/ntp.conf
