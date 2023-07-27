---
title: "Installing the Tun Serivce for Synology and VPN"
date: 2023-06-23T10:37:31+02:00
draft: false
tags: ['synology', 'vpn', 'wireguard', 'tun']
---
## DSM 7
Grab the tunnel service
``` bash
sudo curl -sL https://raw.githubusercontent.com/TRaSH-Guides/Synology-Templates/main/script/tun.service -o "/etc/systemd/system/tun.service"
```
Enable the service
``` bash
sudo systemctl enable /etc/systemd/system/tun.service
```
Run the service
``` bash
sudo systemctl start tun
```
Check if running with
``` bash
sudo systemctl status tun
```
Will look something like this:
``` bash
tun.service - Run tun at startup
   Loaded: loaded (/etc/systemd/system/tun.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2023-06-24 15:06:27 CEST; 1 months 2 days ago
 Main PID: 10931 (code=exited, status=0/SUCCESS)
```
As the service does a simple task it will execute and quit, it won't stay active.

Finish it up with
``` bash
sudo docker-compose up --force-recreate NAMEOFCONTAINERWITHVPN
```

## DSM 6 
In DSM 6 you needed to add a script to be started on boot in your task scheduler:
```bash
#!/bin/sh

# Create the necessary file structure for /dev/net/tun
if ( [ ! -c /dev/net/tun ] ); then
  if ( [ ! -d /dev/net ] ); then
    mkdir -m 755 /dev/net
  fi
  mknod /dev/net/tun c 10 200
fi

# Load the tun module if not already loaded
if ( !(lsmod | grep -q "^tun\s") ); then
  insmod /lib/modules/tun.ko
fi

# Load iptables mangle is not already loaded
if ( !(lsmod |grep -q "^iptable_mangle\s") ); then
  insmod /lib/modules/iptable_mangle.ko
fi
```
