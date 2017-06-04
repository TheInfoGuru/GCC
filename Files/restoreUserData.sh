#!/bin/bash
clear

c_timestamp() {
	date | awk '{print $2,$3,$4}'
}

printf "Enter or scan the PC ID, or type (o) for other: "
read PCID

#if [ "$PCID" == 'o' ]; then

#fi

choose_partition() {
	echo '********************************************************************'
	echo 'Could not automount Windows Partition. Please manually enter the BLKID of the partition (/dev/sdX1) now'
	lsblk
	echo
	printf 'Please enter partion BLKID: '
	read BLKID
	echo "Making a mount directory ..."
	mkdir ~/winMount 2>/dev/null
	printf "Attempting to mount partion with write access ... "
	sudo ntfsfix $BLKID > /dev/null 2>/dev/null
	sudo ntfs-3g -o remove_hiberfile,rw $BLKID ~/winMount 2>/dev/null
	winDir=$(mount | grep "$BLKID" | awk '{print $3}')
	if [ "$winDir/Users" ]; then
		echo "SUCCESS"
	else
		echo "FAIL"
		echo "Could not mount HDD with write access. Now exiting ..."
		sleep 2
		exit
	fi
}

#Using PC ID set the PC folder location and the Customer Folder location in variables
PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
CUSFOLDER=$(echo "${PCFOLDER%/*}")
echo

#if the PC ID given doesn't have a corresponding folder, show an error and exit
if [ ! "$PCFOLDER" ]; then
        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN"
        echo "OR CHECK IN AS NEW PC."
        sleep 3
        exit
fi

#Try to auto mount Windows Partion
  #declare HDD specific variables
winMount=$(sudo fdisk -l | grep -v '*' | grep -iE '(HPFS/NTFS/exFAT|Microsoft basic data)' | awk {'print $1'})
winDir=$(mount | grep "$winMount" | awk '{print $3}')
strCheck=${#winMount}

printf "Is there a possible windows drive ... "
if [ $strCheck -eq 9 ] || [ $strCheck -eq 14 ]; then
        if [ "$winMount" ]; then
                echo "yes"
                printf "Is a windows partition mounted ... "
                if [ ! "$winDir" ]; then
                        echo "no"
                        echo "Making a mount directory ..."
                        mkdir ~/winMount 2>/dev/null
                        printf "Attempting to automount Windows partion with write access ... "
			sudo ntfsfix $winMount
                        sudo ntfs-3g -o remove_hiberfile,rw $winMount ~/winMount 2>/dev/null
                        winDir=$(mount | grep "$winMount" | awk '{print $3}')
                        if [ -d "$winDir/Users" ]; then
                                echo "successful"
                        else
				echo "failed"
				sudo umount $winMount
				choose_partition
                        fi
                else echo "yes"
                fi
        else
                echo "no"
                echo "Could not find a Window Drive. Now Exiting ..."
		sleep 2
		exit
        fi
else
	echo yes
	choose_partition
fi

echo 'Starting backup restoration to folder "BACKUP" on the root of the windows partition'

RESTORESOURCE="$PCFOLDER/dataBackup/current/"
mkdir "$winDir/BACKUP" 2>/dev/null
RESTOREDESTINATION="$winDir/BACKUP"
echo

sudo rsync -rht --info=progress2 "$RESTORESOURCE" "$RESTOREDESTINATION" 2>/dev/null

echo
echo "Comparing source and destination sizes. Please wait."
SOURCESIZE=$(du -sh "$RESTORESOURCE" | awk '{print $1}' 2>/dev/null)
DESTSIZE=$(du -sh "$RESTOREDESTINATION" | awk '{print $1}' 2>/dev/null)
echo "Source location is $RESTORESOURCE, size $SOURCESIZE; Destination location is $RESTOREDESTINATION, size $DESTSIZE."
read -p 'Press enter to finish.' nul
echo -e "[$(c_timestamp)] Restore of user data was completed." >> "$PCFOLDER/log";
echo
echo "Data restore complete."
sleep 2
exit

