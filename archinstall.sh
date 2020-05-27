#!/bin/bash
echo Arch Installer
#Variables
USERACC="will"
DRIVE="sda"
TIMEZONE="Sydney/Europe"
#Install Preparation
echo "Starting Installation"
echo "Checking EFI"
#ls /sys/firmware/efi/efivars
echo "Checking Network"
#ping archlinux.org
echo "Setting Time"
#timedatectl set-ntp true
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