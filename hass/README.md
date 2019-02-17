# Home Assistant deployment on Odroid-C2

### Install Armbian

1. Download [Armbian Stretch](https://www.armbian.com/odroid-c2/) (Armbian 5.75 while writing this doc)
2. Unpack with `7z e armbian_image_archive`
3. Flash it to SD card with `dd if=armbian_image.img of=/dev/mmcblk0 status=progress bs=512`
4. login as `root` with password `1234`. First login forces password change and user creation. Create the same password
for `root` and for new user. Those passwords will be removed in next step.
5. Run `preconfig.sh` script. It will connect to Odroid and enable passwordless sudo as well as reconfigure SSH to
enable passwordless login with ssh key located in `~/.ssh/id_rsa`

### Install Home Assistant

1. SSH into odroid
2. Run `deploy.sh` script as root. It updates system, installs dependencies and installs Home Assistant.

## TODO

- Use git to store HA config and stop using remotely mounted config
- Create ansible playbook for system configuration (replace `deploy.sh` with ansible)
- Run `dev-sec.ansible-ssh-hardening` against host
- Consider using `dev-sec.ansible-os-hardening`
- Add node-exporter installation with `cloudalchemy.node-exporter` role
- Move `preconfig.sh` execution into ansible playbook
- Self updating home assistant?
