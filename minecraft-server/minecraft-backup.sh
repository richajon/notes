#!/bin/bash
# run as root

echo "Minecraft backup script"

# stop the server
echo "Stopping the server"
systemctl stop minecraft@server01.service

# backup
MINECRAFT_SERVER_VERSION=1.17.1
MINECRAFT_BACKUP_DATE=`date +%Y-%m-%d`
MINECRAFT_BACKUP_FILE=/home/minecraft/backups/server01-$MINECRAFT_BACKUP_DATE-$MINECRAFT_SERVER_VERSION.tar
MINECRAFT_SERVER_DIR=/home/minecraft/instances/server01

# tar gzip the server
echo "Creating backup tar.gz file"
tar cf $MINECRAFT_BACKUP_FILE $MINECRAFT_SERVER_DIR 2>/dev/null 1>/dev/null
gzip -f $MINECRAFT_BACKUP_FILE

# change rights on files
echo "Chaging rights on backup file"
chown minecraft:minecraft $MINECRAFT_BACKUP_FILE.gz

# clean backups older than 14 days
echo "Removing old backup files"
find /home/minecraft/backups/* -mtime +14 -exec rm -Rf {} \;

# start the server
echo "Starting the server"
systemctl start minecraft@server01.service