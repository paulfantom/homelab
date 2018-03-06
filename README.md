[![Build Status](https://travis-ci.org/paulfantom/homelab.svg?branch=master)](https://travis-ci.org/paulfantom/homelab)

# HOMELAB

Repository contains ansible playbooks to setup my home infrastructure.

## Hardware

I don't have much hardware (yet) and right now everything is running on:
- 1x Raspberry Pi 2
- 1x Odroid C2
- 1x custom PC (i3-6100, GTX1050ti, some RAM and various disks)

And network is configured on ASUS RT-AC66U with [Asuswrt-merlin](https://asuswrt.lostrealm.ca/) firmware.

## Software

### Monitoring

[cloudalchemy](https://demo.cloudalchemy.org) all the way, so I'm running:
- prometheus
- grafana
- node_exporter (on every box)
- blackbox_exporter
- alertmanager

### NAS

Simple NFS setup + some synchronization to external nextcloud server with [toughiq/owncloud-client](https://hub.docker.com/toughiq/owncloud-client) docker containers.

### Mediacenter

Whole mediacenter is dockerized, and following containers are used:
- [plexinc/pms-docker](https://hub.docker.com/plexinc/pms-docker)
- [linuxserver/plexpy](https://hub.docker.com/linuxserver/plexpy)
- [linuxserver/couchpotato](https://hub.docker.com/linuxserver/couchpotato)
- [haugene/transmission-openvpn](https://hub.docker.com/haugene/transmission-openvpn)

### Hypervisor

For basic virtualization this is just plain libvirt with KVM. However I do GPU passthrough of nvidia GTX1050 ti for my gaming VM, more on this setup is in another repository: [paulfantom/vfio-nvidia-pass](https://github.com/paulfantom/vfio-nvidia-pass)

### Home Automation

I'm running Home Assistant. (TODO)

