# Step-by-step installation on RPi

### Install Raspbian

1. Download [raspbian lite](https://www.raspberrypi.org/downloads/raspbian/)
2. Flash it to SD card with `dd if=raspbian_image.img of=/dev/mmcblk0 status=progress`
3. Mount first partition of SD card (`/dev/mmcblk0p1`)
4. Place empty file called `ssh` in a directory with mounted partition
5. Unmount partition (`umount /dev/mmcblk0p1`) and connect raspberry to network
6. Determine raspberry IP address
7. Run `preconfig.sh <<raspberry_IP>>` script. It will connect to RPi and enable passwordless sudo as well as 
reconfigure SSH to enable passwordless login with ssh key located in `~/.ssh/id_rsa`.
8. Verify ssh connection

### Install pi-hole

1. SSH into raspberry pi
2. Run `sudo apt-get update && sudo apt-get upgrade -y`
3. Read [next section](#configure-unifi-security-gateway)
4. Run `curl -sSL https://install.pi-hole.net | bash`

### Configure Unifi Security Gateway
1. Set raspberry to have static IP address in unifi
2. Go to Settings > Networks > [local network] > DHCP Name Server (Manual)
3. Enter RPi IP address. Additionally add some external DNS server (like `1.1.1.1`) as a secondary.

To have DNS resolution based on client hostnames following additional steps are needed:
1. Go to Settings > Networks > [external network (type WAN)]
2. Enter two external DNS servers (NOT RPi IP!) - not essential
3. Go to RPi pi-hole and point to USG DNS (probably 192.168.1.1)
4. Go to Settings > DNS > Advanced DNS Settings
5. Disable "Never forward non-FQDNs" and "Never forward reverse lookups for private IP ranges"

Source: https://www.reddit.com/r/Ubiquiti/comments/9aymzx/usg_with_pihole_whats_the_best_way_to_do_dnsdhcp/e4z71un

## TODO

- Create ansible playbook for system configuration
- Run `dev-sec.ansible-ssh-hardening` against pi-hole host
- Consider using `dev-sec.ansible-os-hardening`
- Add node-exporter installation with `cloudalchemy.node-exporter` role
- Add installation of https://github.com/nlamirault/pihole_exporter. This can be done on a different node/host
- Move `preconfig.sh` execution into ansible playbook
