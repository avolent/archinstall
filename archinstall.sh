#!/bin/bash
echo Arch Installer

#Variables
USERACC="Will"
DRIVE="sdX"

#Install Preparation
ls /sys/firmware/efi/efivars 

ping archlinux.org 

timedatectl set-ntp true 

#Drive Preparation

dd if=/dev/zero of=/dev/$DRIVE  bs=512  count=1

parted /dev/$DRIVE mklabel gpt
parted -a opt /dev/$DRIVE mkpart primary fat32 2 512
parted /dev/$DRIVE set 1 esp on
parted -a opt /dev/$DRIVE mkpart primary 512 100%

mkfs.fat -F32 /dev/${DRIVE}1 
mkfs.ext4 /dev/${DRIVE}2

#Updating and syncing mirrorlist
pacman -Syy
pacman -S reflector

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector -c "AUS" -f 5 -l 5 -n 5 --save /etc/pacman.d/mirrorlist

#Installing Arch

mount /dev/sda2 /mnt

pacstrap /mnt base linux linux-firmware vim nano 

