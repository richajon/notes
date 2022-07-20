#!/bin/bash

###############################################################################
# run as root check
###############################################################################
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

###############################################################################
# variables
# if you change the MINECRAFT_SERVER_USERNAME you need to adjust the following
# files:
#   - minecraft@.service
#   - minecraft-backup.sh
#   - optionally: minecraft-backup-remote.sh
###############################################################################
MINECRAFT_SERVER_SCRIPTS_DIR=`pwd`
MINECRAFT_SERVER_USERNAME=minecraft
MINECRAFT_SERVER_VERSION=1.17.1
MINECRAFT_SERVER_INSTANCE=server01
MINECRAFT_SERVER_JAR_URL=https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar

###############################################################################
# install the required libraries to run the server
###############################################################################
apt install openjdk-11-jdk screen

###############################################################################
# create the minecraft server user and the minimum directory structure in the
# user's home
###############################################################################

# add the minecraft user if it does not exists
if id -u name "$MINECRAFT_SERVER_USERNAME" &>/dev/null; then
    echo "user minecraft already exists"
else
    echo "adding $MINECRAFT_SERVER_USERNAME user to the system"
    # add the minecraft server user
    useradd -m -s /bin/bash $MINECRAFT_SERVER_USERNAME
fi

# create the instances directory structure
if [ -d "/home/$MINECRAFT_SERVER_USERNAME/instances" ]
then
    echo "directory /home/$MINECRAFT_SERVER_USERNAME/instances exists."
else
    echo "creating the /home/$MINECRAFT_SERVER_USERNAME/instances directory"
    mkdir /home/$MINECRAFT_SERVER_USERNAME/instances
fi

# create the instances directory structure
if [ -d "/home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE" ]
then
    echo "directory /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE exists."
else
    echo "creating the /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE directory"
    mkdir /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE
fi

###############################################################################
# obtain the minecraft server jar
###############################################################################

cd /home/$MINECRAFT_SERVER_USERNAME
wget $MINECRAFT_SERVER_JAR_URL
mv server.jar minecraft_server.$MINECRAFT_SERVER_VERSION.jar
ls -s /home/$MINECRAFT_SERVER_USERNAME/minecraft_server.$MINECRAFT_SERVER_VERSION.jar /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE/minecraft_server.jar

###############################################################################
# generate the eula.txt file
###############################################################################

# auto accept the eula.txt
if [ ! -e /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE/eula.txt ]; then
    echo "# Generated via minecraft-server-setup.sh on $(date)" > /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE/eula.txt
    echo "eula=true" >> /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE/eula.txt
fi

###############################################################################
# start the server for the first time
###############################################################################

# cd /home/$MINECRAFT_SERVER_USERNAME/instances/$MINECRAFT_SERVER_INSTANCE
# java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui

###############################################################################
# make minecraft server user the owner of the file created as root under the
# home directory of the user
###############################################################################
chown -R minecraft:minecraft /home/$MINECRAFT_SERVER_USERNAME

###############################################################################
# install the service to start and stop minecraft automatically on boot and
# shutdown
###############################################################################
cp $MINECRAFT_SERVER_SCRIPTS_DIR/minecraft@.service /etc/systemd/system/minecraft@.service
systemctl enable minecraft@$MINECRAFT_SERVER_INSTANCE.service
systemctl start minecraft@$MINECRAFT_SERVER_INSTANCE.service

###############################################################################
# setup the minecraft server backup script in the root home directory and
# register crontab schedule
###############################################################################
if [ -d "/home/$MINECRAFT_SERVER_USERNAME/backups" ]
then
    echo "directory /home/$MINECRAFT_SERVER_USERNAME/backups exists."
else
    echo "creating the $MINECRAFT_SERVER_USERNAME directory"
    mkdir /home/$MINECRAFT_SERVER_USERNAME/backups
fi

# create bin directory in the root user home
if [ -d "/root/bin" ]
then
    echo "directory /root/bin exists."
else
    echo "creating the /root/bin directory"
    mkdir /root/bin
fi

# copy the minecraft server backup.sh in the /root/bin directory and make it executable
cp $MINECRAFT_SERVER_SCRIPTS_DIR/minecraft-backup.sh /root/bin/minecraft-backup.sh
chmod u+x /root/bin/minecraft-backup.sh

# load the backup schedule into the crontab
crontab $MINECRAFT_SERVER_SCRIPTS_DIR/minecraft-backup-crontab.txt