#!/bin/bash

set -x
echo -e "---- Arch Installer ----"

# Install Preparation
echo -e "\n---- Starting Installation ----"
timedatectl set-ntp true
echo -e "\n---- Checking EFI ----"
if [[ -d /sys/firmware/efi/efivars ]]
    then
        echo "---- EFI enabled, continuing. ----"
    else
        echo "!!!! EFI not enable, halting script !!!!"
        exit    
fi

# Drive Preparation
echo -e "---- Preparing drives and creating partitions ----"
lsblk
while true; do
    read -p "What drive would you like to partition? [sdx/nvmeXnX]: " DRIVE
        case "$DRIVE" in
            sd*|nvme*n*) 
                echo -e "Selected drive is '$DRIVE', continue with enter...";
                read _;
                break
                ;;
            *)
                echo "!!!! Try, again !!!!"
                ;;
        esac
done
dd if=/dev/zero of=/dev/$DRIVE bs=512 count=1
parted /dev/$DRIVE mklabel gpt 
parted -a opt /dev/$DRIVE mkpart primary fat32 2 512
parted /dev/$DRIVE set 1 esp on 
parted -a opt /dev/$DRIVE mkpart primary 512 100% 
mkfs.fat -F32 /dev/${DRIVE}1 
mkfs.ext4 /dev/${DRIVE}2 

# Updating and syncing mirrorlist
echo -e "\n---- Updating and syncing mirrorlist ----"
pacman --noconfirm -Syy reflector 
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 
reflector -c "Australia" -f 5 -l 5 -n 5 --save /etc/pacman.d/mirrorlist 
 
# Installing Arch
echo -e "\n---- Installing Arch ----"
mount /dev/${DRIVE}2 /mnt 
pacstrap /mnt base linux linux-firmware vim nano zip unzip bash-completion networkmanager sudo openssh 
genfstab -U /mnt >> /mnt/etc/fstab 

#Chrooting into Arch
echo -e "\n---- Chroot into Arch ----"
curl -sL https://raw.githubusercontent.com/avolent/archinstall/master/post-chroot.sh -o post-chroot.sh 
mkdir /mnt/scripts 
cp post-chroot.sh /mnt/scripts 
arch-chroot /mnt /scripts/post-chroot.sh