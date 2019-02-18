# Step-by-step setup of etcd cluster (WIP)

## Prerequisities

- 3x Raspberry Pi 3
- 1x iSCSI target (optional)

## Install debian buster (64bit preview version)

Most of it is described in debian wiki page: https://wiki.debian.org/RaspberryPi3

1. Download [image](https://people.debian.org/~gwolf/raspberrypi3/20190206/20190206-raspberry-pi-3-buster-PREVIEW.img.xz)
2. Flash it to SD card with `dd if=20190206-raspberry-pi-3-buster-PREVIEW.img of=/dev/mmcblk0 status=progress`
3. Insert card to RPi, wait for it to boot and determine its IP address
4. Run `preconfig.sh <<raspberry_IP>> <<hostname>>` script. This script does following things on target host:
   - enable passwordless SSH login with ssh key located in `~/.ssh/id_rsa`.
   - create a user with the same name as a user running this script
   - passwordless sudo
   - remove password for root user
   - change hostname
   - reboot
   - wait for RPi to come back

## Configure iSCSI initiator (optional)

1. Login via SSH to RPi instance (`ssh <<raspberry_IP>>`)
2. Install deps `apt install -y open-iscsi`
3. Set initiator name (`echo "InitiatorName=iqn.$(date +%Y-%M).xyz.thaum.ankhmorpork:$(hostname)" > /etc/iscsi/initiatorname.iscsi`)
4. Discover target luns (`iscsiadm -m discovery -t st -p "${ISCSI_TARGET}"`)
5. Set lun to be automatically discovered (`iscsiadm -m node -T "${ISCSI_IQN}" -o update -n node.startup -v automatic`)
6. Configure etcd persistent mountpoint by adding following line to `/etc/fstab`: 
```
/dev/sda /var/lib/etcd ext4 defaults,_netdev,nofail 0 0
```

Variables:
- `ISCSI_TARGET` - ip address of iSCSI target
- `ISCSI_IQN` - iSCSI target iqn name

## Install etcd (TODO)

References:
- https://kubernetes.io/docs/setup/independent/high-availability/#external-etcd-nodes
- https://kubernetes.io/docs/setup/independent/setup-ha-etcd-with-kubeadm/
- https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

1. ???

## TODO

- Create ansible playbook for system configuration
- Run dev-sec.ansible-ssh-hardening against pi-hole host
- Consider using dev-sec.ansible-os-hardening
- Add node-exporter installation with cloudalchemy.node-exporter role
