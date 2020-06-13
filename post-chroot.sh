#!/bin/bash

# Configuration
USERACC="will"
DEVICE="will-laptop" #Hostname of the device
TIMEZONE="/Australia/Sydney"

#Current Variable Check
echo "---- Current Variables ----"
echo "User Account: $USERACC"
echo "Hostname: $DEVICE"
echo -e "Timezone: $TIMEZONE \n"
read -r -p "Are you happy with the current variables? [yes/no]: " ANSWER
case "$ANSWER" in
    [yY][eE][sS]|[yY]) 
        echo "---- Proceeding with script ----"
        ;;
    *)
        echo "!!!! Edit the variables at the start of the script to adjust the install !!!!"
        exit
        ;;
esac

# Configuring Arch
echo -e "\n---- Setting up Timezones ----"
echo $TIMEZONE
timedatectl set-timezone $TIMEZONE
echo -e "\n---- Configuring locale ----"
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
export LANG=en_AU.UTF-8
echo -e "\n---- Configuring Hostname and Networking ----"
echo $DEVICE > /etc/hostname
touch /etc/hosts
echo -e '127.0.0.1  localhost\n::1  localhost\n127.0.1.1    '$DEVICE'' > /etc/hosts
echo -e "\n---- Enter in root password ----"
passwd
echo -e "\ntemp end"