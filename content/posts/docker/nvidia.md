---
title: "Installing Nvidia Driver on Debian 11 for passthrough to docker (Emby, Plex, etc)"
date: 2022-11-01T13:05:36+01:00
draft: false
tags: ['nvidia', 'proxmox', 'debian', 'docker']
---

## I already tried to install drivers

In case you already installed some drivers, purge them:

``` bash
sudo apt-get -s purge 'nvidia-*'
```

and update initramfs:

``` bash
sudo update-initramfs -u
```

## Clean install

### Driver installation

Add contrib and non-free repo:

``` bash
sudo nano /etc/apt/sources.list
```

and change the line

``` bash
deb http://deb.debian.org/debian/ bullseye main
```

so it looks like

``` bash
deb http://deb.debian.org/debian/ bullseye main contrib non-free
```

Ctrl +x to save, hit Y for yes
Now install the Debian 11 driver:

``` bash
sudo apt update
sudo apt -y install nvidia-driver firmware-misc-nonfree
sudo shutdown -r now
```

!!! note
    You might get a screen that nouveau is enabled and that you need to reboot, which we gonna do anyways, last command will make your instance reboot.
Once rebooted and back logged in give

``` bash
nvidia-smi
```

a try. If this fails, make sure you don't have any repos, that might cause issues, purge and start over. If you're in a Debian VM, make sure the GPU passthrough to the VM is working first.

### Docker Setup for Nvidia

This will install and setup the needed keys, repo, software and configure docker to use Nvidia.

``` bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Finally proceed with adding your gpu properly to your compose as per Docker specs.

``` yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu] 
```

Docker-compose up and voila, you're able to use your GPU in an Emby or Plex container.

## Side note

If nvidia-smi doesn't show your card, it might be related to secure boot, have a read here <https://wiki.debian.org/NvidiaGraphicsDrivers#Debian_11_.22Bullseye.22>
I had the issue on proxmox as the vm bios had it enabled, i ended up disabling secure boot for the vm as i don't need it, but mentioning it in case someone struggles.
(Both, barebone and proxmox vm, tested with lscr.io/linuxserver/emby:latest)
