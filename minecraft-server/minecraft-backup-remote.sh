#!/bin/bash
#
# minecraft-safety-backup.sh
#
# Author: Jonathan Richard
# Mail: richajon@gmail.com
# Latest change: 2021-07-09
#
# Script that copies today's backup from a remote Minecraft linux server and
# transfers it locally. It then removes local safety backups older than 7 days.
#
# You need to use ssh-keygen to generate a private and public key for ssh
# authentication
#
# Then copy your the public key to the remote server using ssh-copy-id user@host
#

# params
MINECRAFT_SERVER_USERNAME=op
MINECRAFT_SERVER_IP=192.168.0.50
MINECRAFT_SERVER_VERSION=1.17.1
MINECRAFT_BACKUP_DATE=`date +%Y-%m-%d`
MINECRAFT_BACKUP_FILE=server01-$MINECRAFT_BACKUP_DATE-$MINECRAFT_SERVER_VERSION.tar.gz
MINECRAFT_BACKUP_LOCAL_FOLDER=/home/pi/minecraft-backups
MINECRAFT_BACKUP_LOCAL_FILE=$MINECRAFT_BACKUP_LOCAL_FOLDER/$MINECRAFT_BACKUP_FILE
MINECRAFT_BACKUP_REMOTE_FOLDER=/home/minecraft/backups
MINECRAFT_BACKUP_REMOTE_FILE=$MINECRAFT_BACKUP_REMOTE_FOLDER/$MINECRAFT_BACKUP_FILE

# copy today's backup from remote server to local machine
echo "Copying today's backup file"
scp $MINECRAFT_SERVER_USERNAME@$MINECRAFT_SERVER_IP:$MINECRAFT_BACKUP_REMOTE_FILE $MINECRAFT_BACKUP_LOCAL_FILE

# clean backups older than 7 days from local machine
echo "Removing old backup files"
find $MINECRAFT_BACKUP_LOCAL_FOLDER/ -mtime +7 -exec rm -Rf {} \;
