#!/bin/bash
echo -e "---- Arch Installer ----"
read -n 1 -r -s -p $'Press enter to continue...\n'
# Configuration
USERACC="will"
DEVICE="will-laptop" #Hostname of the device
DRIVE="sda"
TIMEZONE="Australia/Sydney"
# Install Preparation
echo -e "---- Starting Installation ---- \n"
timedatectl set-ntp true
echo -e "---- Checking EFI ---- \n"
if [ -d /sys/firmware/efi/efivars ]
    then
        echo "---- EFI enabled, continuing. ----"
    else
        echo "!!!! EFI not enable, halting script !!!!" 
        exit 
fi
echo -e "---- Checking network connectivity. ----\n"
if ping -c 1 archlinux.org &> /dev/null
    then   
        echo "Internet Connectivity Working."
    else   
        echo "!!!! No Internet Connectivity. Halting script !!!!"
        exit
fi
# Drive Preparation
echo -e "---- Preparing drives and creating partitions ----"
read -n 1 -r -s -p $'Selected drive is '$DRIVE'.\n
Press enter to continue...\n'
dd if=/dev/zero of=/dev/$DRIVE  bs=512  count=1
parted /dev/$DRIVE mklabel gpt
parted -a opt /dev/$DRIVE mkpart primary fat32 2 512
parted /dev/$DRIVE set 1 esp on
parted -a opt /dev/$DRIVE mkpart primary 512 100%
mkfs.fat -F32 /dev/${DRIVE}1
mkfs.ext4 /dev/${DRIVE}2
# Updating and syncing mirrorlist
echo -e "---- Updating and syncing mirrorlist ---- \n"
pacman --noconfirm -Syy reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "Australia" -f 5 -l 5 -n 5 --save /etc/pacman.d/mirrorlist
# Installing Arch
echo -e "---- Installing Arch ---- \n"
mount /dev/sda2 /mnt
pacstrap /mnt base linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "---- Chroot into Arch ---- \n"
arch-chroot /mnt
echo -e "---- Setting up Timezones ---- \n"
echo $TIMEZONE
timedatectl set-timezone $TIMEZONE
echo -e "---- Configuring locale ---- \n"
locale-gen
echo LANG=en_AU.UTF-8 > /etc/locale.conf
export LANG=en_AU.UTF-8
echo -e "---- Configuring Hostname and Networking ---- \n"
echo $DEVICE > /etc/hostname
touch /etc/hosts
echo -e '127.0.0.1  localhost\n::1  localhost\n127.0.1.1    '$DEVICE'' > /etc/hosts
echo -e "---- Enter in root password ---- \n"
passwd
echo -e "temp end"