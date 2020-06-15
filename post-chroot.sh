#!/bin/bash

# Configuration
USERACC="will"
DEVICE="will-laptop" #Hostname of the device
TIMEZONE="Australia/Sydney"

# Current Variable Check
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
echo -e "Password is now set"

# Setting up bootloader
echo -e "\n---- Configuring the bootloader ----"
pacman -S grub efibootmgr intel-ucode
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# Installing packages 
pacman -Syu yay light-dm rxvt-unicode ranger intel-ucode networkmanager nm-connection-editor network-manager-applet i3-gaps i3status i3lock dmenu i3-scrot i3exit