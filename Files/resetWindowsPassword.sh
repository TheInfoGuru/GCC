#!/bin/bash

choose_partition() {
	winDir='NA'
	echo '********************************************************************'
	printf 'Could not automount Windows Partition. Would you like to type in the BLKID of the partition (/dev/sdX1) now? [y/n]'
	read -p ': ' ans1
	if [ $ans1 == y ]; then
		lsblk
		echo
		printf 'Please enter partition BLKID: '
		read  winMount
		echo "Making a mount directory ..."
		mkdir ~/winMount 2>/dev/null
		printf "Attempting to mount partition with write access ... "
		sudo ntfsfix $winMount 2> /dev/null
		sudo ntfs-3g -o remove_hiberfile,rw $winMount ~/winMount 2>/dev/null
		winDir=$(mount | grep "$winMount" | awk '{print $3}')
		hddID=${winMount%?}
		if [ -d "$winDir/Users" ]; then
			echo "SUCCESS"
		else 
			echo "FAIL"
			echo "COULD NOT MOUNT WINDOWS PARTION!"
			sleep 1
			sudo umount $winMount
			choose_HDD
		fi
	elif [ $ans1 == n ]; then
		echo 'Exiting script ...'
		sleep 3
		exit 1
	else
		echo "Invalid Choice. Choose Again."
		sleep 2
		choose_partition
	fi
	echo '********************************************************************'

}

#check for root priveledges
#if [ "$EUID" -ne 0 ]
#	then echo "This script must be ran as root."
#	exit
#fi

echo "Trying to mount Windows partition with write capabilities ..."

#Try to auto mount Windows Partition
  #declare HDD specific variables
winMount=$(sudo fdisk -l | grep -v '*' | grep -iE '(HPFS/NTFS/exFAT|Microsoft basic data)' | awk {'print $1'})
if [ -d $HOME/winMount/Users ]; then
	winDir=$HOME/winMount
else
	winDir=$(mount | grep "$winMount" | awk '{print $3}')
fi

strCheck=${#winMount}

if [ -z "$winDir" ]; then
	printf "Is there a possible windows drive ... "
	if [ $strCheck -eq 9 ] || [ $strCheck -eq 14 ]; then
		if [ "$winMount" ]; then
			echo "yes"
			printf "Is a windows partition mounted ... "
			if [ ! "$winDir" ]; then
				echo "no"
				echo "Making a mount directory ..."
				mkdir ~/winMount 2>/dev/null
				printf "Attempting to automount Windows partition with write support ... "
				sudo ntfsfix $winMount 2> /dev/null
				sudo ntfs-3g -o remove_hiberfile,rw $winMount ~/winMount 2>/dev/null
				winDir=$(mount | grep "$winMount" | awk '{print $3}')
				if [ -d "$winDir/Users" ]; then
					echo "successful"
				else 
					echo "failed"
					sudo umount -l $winMount
					choose_partition
				fi
			else echo "yes"
			fi
		else 
			echo "no"
			choose_partition
		fi
	else
		echo yes
		choose_partition
	fi
fi

echo "Checking for SAM file location ..."

samLocation=$(find "$winDir" -type f -ipath '*/windows/system32/config/sam' | grep -iv 'windows.old')

if [ -z "$samLocation" ]; then
	echo "Could not find SAM file automatically. Please do password reset manually."
	sleep 3
	exit 1
fi

chntpw -i "$samLocation"

echo
echo "Thank you for using this utility."
sleep 2
exit 0
