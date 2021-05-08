# Minecraft Linux Server Setup

## Target Linux distribution
Raspberry PI 4 or Debian 9+ distribution

## Install requirements
```
sudo apt install openjdk-11-jdk screen
```

## The minecraft user home

### The folder structure
```
useradd -m -s /bin/bash
mkdir /home/minecraft/backups
mkdir /home/minecraft/bin
mkdir -p /home/minecraft/instances/server01
```

### The minecraft server jar
```
cd /home/minecraft
wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar
```

### The server01 instance
```
ls -s /home/minecraft/minecraft_server.1.16.5.jar /home/minecraft/instances/server01/minecraft_server.jar
```

### Starting server01 instance for the first time

Start the server using the java command
```
cd /home/minecraft/instances/server01
java -Xmx1024M -Xms1024M -jar minecraft_server.1.16.5.jar nogui
```

The server will start then stop so you accept the EULA.
```
nano /home/minecraft/instances/server01/eula.txt
```

Set the eula variable to `true`
```
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/docume$#Wed Sep 16 18:59:15 EDT 2020
eula=true
```

## The minecraft service

### Creating the service file

```
nano /etc/systemd/system/minecraft@.service
```

```
[Unit]
Description=Minecraft Server: %i
After=network.target

[Service]
WorkingDirectory=/home/minecraft/instances/%i

User=minecraft
Group=minecraft

Restart=always

ExecStart=/usr/bin/screen -DmS mc-%i /usr/bin/java -Xmx2400m -jar minecraft_server.jar nogui

ExecStop=/usr/bin/screen -p 0 -S mc-%i -X eval 'stuff "say SERVER SHUTTING DOWN IN 15 SECONDS..."\015'
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -p 0 -S mc-%i -X eval 'stuff "say SERVER SHUTTING DOWN IN 10 SECONDS..."\015'
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -p 0 -S mc-%i -X eval 'stuff "say SERVER SHUTTING DOWN IN 5 SECONDS..."\015'
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -p 0 -S mc-%i -X eval 'stuff "save-all"\015'
ExecStop=/usr/bin/screen -p 0 -S mc-%i -X eval 'stuff "stop"\015'

[Install]
WantedBy=multi-user.target
```

### Enabling, disabling, starting, stopping the service
```
# registering the service from statup
systemctl enable minecraft@server01.service

# removing the service from statup
systemctl disable minecraft@server01.service

# starting the service from statup
systemctl start minecraft@server01.service

# stopping the service from statup
systemctl stop minecraft@server01.service
```

## The backups

### The backup script
```
nano /home/minecraft/bin/backup.sh
```

```
#!/bin/bash
# run as root

echo "Minecraft backup script"

# stop the server
echo "Stopping the server"
systemctl stop minecraft@server01.service

# backup
MINECRAFT_SERVER_VERSION=1.16.5
MINECRAFT_BACKUP_DATE=`date +%Y-%m-%d`
MINECRAFT_BACKUP_FILE=/home/minecraft/backups/server01-$MINECRAFT_BACKUP_DATE-$MINECRAFT_SERVER_VERSION.tar
MINECRAFT_BACKUP_SERVER_DIR=/home/minecraft/instances/server01

# tar gzip the server
echo "Creating backup tar.gz file"
tar cf $MINECRAFT_BACKUP_FILE $MINECRAFT_BACKUP_SERVER_DIR 2>/dev/null 1>/dev/null
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
```

### The backup schedule

As root, add crontab entry.
```
crontab -e
```

Add the following line in the crontab to run everyday at 5 am
```
0 5 * * * /home/minecraft/bin/backup.sh
```
