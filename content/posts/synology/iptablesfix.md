---
title: "Iptables fix for Docker on Synology"
date: 2023-06-23T10:37:31+02:00
draft: false
tags: ['synology', 'nginx', 'iptabes', 'docker']
---
Using a Reverseproxy, or something like pihole, you might have run into the issue of not seeing the correct IPs in the log files. This is annoying if you want to use something like fail2ban for example.

Add the script to the task scheduler, or save it as script that you execute via task scheduler on your Syno. To remove it, just remove the script and reboot your Syno.

```bash
#!/bin/bash
currentAttempt=0
totalAttempts=10
delay=15

while [ $currentAttempt -lt $totalAttempts ]
do
	currentAttempt=$(( $currentAttempt + 1 ))

	echo "Attempt $currentAttempt of $totalAttempts..."

	result=$(iptables-save)

	if [[ $result =~ "-A DOCKER -i docker0 -j RETURN" ]]; then
		echo "Docker rules found! Modifying..."

		iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
		iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL ! --dst 127.0.0.0/8 -j DOCKER

		echo "Done!"

		break
	fi

	echo "Docker rules not found! Sleeping for $delay seconds..."

	sleep $delay
done
```

Source and some more detailed discussion regarding specific cases: https://gist.github.com/pedrolamas/db809a2b9112166da4a2dbf8e3a72ae9
