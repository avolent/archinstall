#!/bin/bash
set -x

echo -e "---- Arch Installer ----"

# Install Preparation
echo -e "\n---- Starting Installation ----"
# timedatectl set-ntp true &>/dev/null 
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
# DRIVE="sda"
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
dd if=/dev/zero of=/dev/$DRIVE  bs=512  count=1
parted /dev/$DRIVE mklabel gpt &>/dev/null 
parted -a opt /dev/$DRIVE mkpart primary fat32 2 512 &>/dev/null
parted /dev/$DRIVE set 1 esp on &>/dev/null 
parted -a opt /dev/$DRIVE mkpart primary 512 100% &>/dev/null 
mkfs.fat -F32 /dev/${DRIVE}1 &>/dev/null 
mkfs.ext4 /dev/${DRIVE}2 &>/dev/null 

# Updating and syncing mirrorlist
echo -e "\n---- Updating and syncing mirrorlist ----"
pacman --noconfirm -Syy reflector &>/dev/null 
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &>/dev/null 
reflector -c "Australia" -f 5 -l 5 -n 5 --save /etc/pacman.d/mirrorlist &>/dev/null 
 
# Installing Arch
echo -e "\n---- Installing Arch ----"
mount /dev/${DRIVE}2 /mnt &>/dev/null 
pacstrap /mnt base linux linux-firmware vim nano zip unzip bash-completion networkmanager sudo openssh &>/dev/null 
genfstab -U /mnt >> /mnt/etc/fstab &>/dev/null 

#Chrooting into Arch
echo -e "\n---- Chroot into Arch ----"
curl -sL https://raw.githubusercontent.com/avolent/archinstall/master/post-chroot.sh -o post-chroot.sh &>/dev/null 
mkdir /mnt/scripts &>/dev/null 
cp post-chroot.sh /mnt/scripts &>/dev/null 
chmod -x /mnt/scripts/post-chroot.sh &>/dev/null 
arch-chroot /mnt /scripts/post-chroot.sh