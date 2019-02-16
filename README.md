[![Build Status](https://travis-ci.org/paulfantom/homelab.svg?branch=master)](https://travis-ci.org/paulfantom/homelab)

# HOMELAB

Repository contains everything I need to setup my home/cloud infrastructure.

## Hardware (local)

I don't have much hardware (yet) and right now everything is running on:
- 3x Raspberry Pi 3 B+
- 1x Raspberry Pi B (the first one)
- 1x Odroid C2
- 1x custom NAS (Ryzen 3-2200G, 8 GB RAM and various disks)
- 1x dell laptop E5440
- 1x Windows 10 box (i3-6100, nVidia GTX 1050ti, 16GB RAM)

And network is configured using Ubiquiti UniFi devices.

## Software

### Monitoring

- prometheus
- grafana
- node_exporter (on every linux box)
- wmi_exporter (on windows box)
- blackbox_exporter
- alertmanager

### Mediacenter

Whole mediacenter is dockerized, and following containers are used:
- [plexinc/pms-docker](https://hub.docker.com/plexinc/pms-docker)
- [linuxserver/plexpy](https://hub.docker.com/linuxserver/plexpy)
- [linuxserver/couchpotato](https://hub.docker.com/linuxserver/couchpotato)
- [haugene/transmission-openvpn](https://hub.docker.com/haugene/transmission-openvpn)
- ombi

### Hypervisor

For basic virtualization this is just plain libvirt with KVM.

### Home Automation

I'm running Home Assistant. (TODO)

