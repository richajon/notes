# Minecraft Linux Server Setup

## Target Linux distribution
Raspberry PI 4 or Debian 9+ distribution

## Install requirements
```
apt install openjdk-17-jdk screen
```

## The minecraft user home

### The folder structure
```
useradd -m -s /bin/bash minecraft
su - minecraft
mkdir /home/minecraft/backups
mkdir /home/minecraft/bin
mkdir -p /home/minecraft/instances/server01
```

### The minecraft server jar

visit: https://www.minecraft.net/en-us/download/server to obtain the Minecraft server.jar (URL_OF_THE_CURRENT_VERSION)

```
cd /home/minecraft
wget [URL_OF_THE_CURRENT_VERSION]

```

### The server01 instance
```
cd /home/minecraft
mv server.jar minecraft_server.1.17.1.jar
ls -s /home/minecraft/minecraft_server.1.17.1.jar /home/minecraft/instances/server01/minecraft_server.jar
```

### Starting server01 instance for the first time

Start the server using the java command
```
cd /home/minecraft/instances/server01
java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui
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

Download on your server or copy the content following file on your server: [minecraft@.service](./minecraft@.service)

Then adjust the variables according to your Minecraft server environment.

```
su -
nano /etc/systemd/system/minecraft@.service
```

### Enabling, disabling, starting, stopping the service
```
# registering the service from statup
systemctl enable minecraft@server01.service

# removing the service from statup
systemctl disable minecraft@server01.service

# starting the service
systemctl start minecraft@server01.service

# stopping the service
systemctl stop minecraft@server01.service
```

## The backups

### The backup script

Download on your server or copy the content following script on your server: [minecraft-backup.sh](./minecraft-backup.sh)

Then adjust the variables according to your Minecraft server environment.

```
chmod u+x /home/minecraft/bin/minecraft-backup.sh
```

### The backup schedule

As root, add crontab entry.
```
crontab -e
```

Add the following line in the crontab to run everyday at 5 am
```
0 5 * * * /home/minecraft/bin/minecraft-backup.sh
```
