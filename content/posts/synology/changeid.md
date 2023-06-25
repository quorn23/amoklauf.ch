---
title: "Change the ID of an user on Synology"
date: 2022-11-01T13:05:36+01:00
draft: false
tags: ['synology', 'user id', 'nfs']
---
I tried to change the user ID of a Synology user, during my nightmare of streamlining user ids for NFS shares.
usermod resulted in a command not found, what a surprise. Anyways to change an ID:

* edit `/etc/passwd` and swap the ID
* edit `/etc/group` in case you want to change a group ID

```bash
synouser --rebuild all
```

to synchronize the changes to the system.
