---
title: "Update pihole lists"
date: 2023-06-23T10:33:11+02:00
draft: true
tags: ['pihole', 'discord']
---
I like to keep my pihole lists updated. "Jacklul" has made a nice script to handle that. pihole-updatelists from https://github.com/jacklul/pihole-updatelists\
Here we will:
- Installs requirements
- Adds a cronjob
- Setup a daily notification with the update fetch of the lists, if Pihole has an update available and used disk space. 
Tested as VM and LXC container on proxmox with Dietpi.

Install required apt packages
```bash
apt-get install -y php-cli php-sqlite3 php-intl php-curl
```
Install pihole-updatelists
```bash
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | bash
```
Download the script and make it executable
```bash
curl -o /opt/updatelists https://raw.githubusercontent.com/quorn23/pihole-setup/main/updatelists
chmod +x /opt/updatelists
```
Make sure to add your discord webhook url.
Fetching my default config
```bash
curl -o /etc/pihole-updatelists.conf https://raw.githubusercontent.com/quorn23/pihole-setup/main/pihole-updatelists.conf
```
The config uses the lists from https://v.firebog.net and whitelists fitting to my usage. Configure this with the lists you're using. 