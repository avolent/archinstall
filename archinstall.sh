#!/bin/bash
echo Arch Installer
read -n 1 -r -s -p $'Press enter to continue...\n'
#tes
USERACC="will"
DRIVE="sda"
TIMEZONE="Australia/Sydney"
#Install Preparation
echo "Starting Installation"
echo "Checking EFI"
if -e /sys/firmware/efi/efivars
then
    echo "EFI enabled, continuing."
else
    echo "EFI not enable, halting script!" 
    exit 
fi
echo "Checking network connectivity."
if ping -c 1 archlinux.org &> /dev/null
then   
    echo "Internet Connectivity Working."
else   
    echo "No Internet Connectivity. Halting script!"
    exit
fi
echo "Setting Time"
timedatectl set-ntp true
#Drive Preparation
echo "Preparing drives and creating partitions"
dd if=/dev/zero of=/dev/$DRIVE  bs=512  count=1
parted /dev/$DRIVE mklabel gpt
parted -a opt /dev/$DRIVE mkpart primary fat32 2 512
parted /dev/$DRIVE set 1 esp on
parted -a opt /dev/$DRIVE mkpart primary 512 100%
mkfs.fat -F32 /dev/${DRIVE}1
mkfs.ext4 /dev/${DRIVE}2
#Updating and syncing mirrorlist
echo "Updating and syncing mirrorlist"
pacman -Syy
pacman -S reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "AUS" -f 5 -l 5 -n 5 --save /etc/pacman.d/mirrorlist
#Installing Arch
echo "Installing Arch"
mount /dev/sda2 /mnt
pacstrap /mnt base linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
echo "Chroot into Arch"
arch-chroot /mnt