#!/bin/bash
echo -e "---- Arch Installer ----"

# Configuration
USERACC="will"
DEVICE="will-laptop" #Hostname of the device
DRIVE="sda"
TIMEZONE="/Australia/Sydney"

#Current Variable Check
echo "---- Current Variables ----"
echo "User Account: $USERACC"
echo "Hostname: $DEVICE"
echo "Drive: $DRIVE"
echo -e "Timezone: $TIMEZONE \n"
read -r -p "Are you happy with the current variables? [yes/no] " answer
case "$answer" in
    [yY][eE][sS]|[yY]) 
        echo "---- Proceeding with script ----"
        ;;
    *)
        echo "!!!! Edit the variables at the start of the script to adjust the install !!!!"
        exit
        ;;
esac

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
echo -e "\n---- Preparing drives and creating partitions ----"
printf 'Selected drive is '$DRIVE'.\n Press enter to continue...\n'
read _
dd if=/dev/zero of=/dev/$DRIVE  bs=512  count=1
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
pacstrap /mnt base linux linux-firmware vim nano zip unzip bash-completion
genfstab -U /mnt >> /mnt/etc/fstab

#Chrooting into Arch
echo -e "\n---- Chroot into Arch ----"
curl -sL https://raw.githubusercontent.com/avolent/archinstall/master/post-chroot.sh -o post-chroot.sh
mkdir /mnt/scripts
cp post-chroot.sh /mnt/scripts
arch-chroot /mnt /scripts/post-chroot.sh

