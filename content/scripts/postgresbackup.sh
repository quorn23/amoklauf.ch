# bin/bash

###################
## Configuration ##
###################

docker=postgres14 #container name of the PG databases
admin=admin_user #admin user of PG
bu_keep_days=7 #number of days to keep
db_path=/PATH TO DB BACKUPS/ #path to save backups
today=$(date +"%Y%m%d%H%M") #Date to name backups - YearMonthDayHourMinute
user=user_id #for backup perms
group=group_id #for backup perms
disccolor=65280 #color of discord embed
botname="PGSQL Backup" #Name that shows as bot name in Discord
author_url=https://amoklauf.ch/img/postgresql.png #URL for Bot image
discord_webhook='https://discord.com/api/webhooks/xxxxxx' #Discord Webhook URL

backup() {
printf "Backup Postgres Database '%s'\n" "${db_path}${today}.postgres-backup.sql.gz"


docker exec -i ${docker} /usr/bin/pg_dumpall \
 -U ${admin}  | gzip -9 > ${db_path}${today}.postgres-backup.sql.gz

chown -R $user:$group ${db_path}

size=$(du -m "${db_path}${today}.postgres-backup.sql.gz" | cut -f1)
printf  "${size}MB \n"
}

housecleaning() {
find $db_path -name "20??????????.postgres-backup.sql.gz" -mtime +$bu_keep_days -type f -delete
printf "Deleting all backups older than ${bu_keep_days} days\n"

}

    send_discord_notification() {
        author_url="${author_url}"
        json='{
        "embeds": [
            {
            "color": "'${disccolor}'",
            "fields": [
                {
                "name": "Backup created:",
                "value": "```'${today}.postgres-backup.sql.gz'```"
                },
				{
				"name": "Compressed Size:",
				"value": "'${size}'MB"
				},
				{
				"name": "Housecleaning:",
				"value": ":white_check_mark:"
				}
            ],
            "author": {
                "name": "'${botname}'",
                "icon_url": "'${author_url}'"
            },
            "footer": {
                "text": "Made by Gabe"
            },
            "timestamp": "'$(date -u +'%FT%T.%3NZ')'"
            }
        ],
        "username": "'${botname}'",
        "avatar_url": "'${author_url}'"
        }'
        curl -fsSL -H "User-Agent: Gabe" -H "Content-Type: application/json" -d "${json}" $discord_webhook > /dev/null
		printf "Sending Discord Notification...\n"
}


backup
housecleaning
send_discord_notification "$discord_webhook"

