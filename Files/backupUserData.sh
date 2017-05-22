#!/bin/bash
clear
printf "Enter or scan the PC ID, or type (o) for other: "
read PCID

#if [ "$PCID" == 'o' ]; then

#fi

#Using PC ID set the PC folder location and the Customer Folder location in variables
PCFOLDER=$(find ./* -name "$PCID")
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
                        printf "Attempting to automount Windows partion read-only ... "
                        sudo mount -r $winMount ~/winMount 2>/dev/null
                        winDir=$(mount | grep "$winMount" | awk '{print $3}')
                        if [ "$winDir/Users" ]; then
                                echo "successful"
                        else echo "failed"
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
	echo '********************************************************************'
	echo 'Could not automount Windows Partition. Please manually enter the BLKID of the partition (/dev/sdX1) now'
	lsblk
	echo
	printf 'Please enter partion BLKID: '
	read BLKID
	echo "Making a mount directory ..."
	mkdir ~/winMount 2>/dev/null
	printf "Attempting to mount partion read-only ... "
	sudo mount -r $BLKID ~/winMount 2>/dev/null
	winDir=$(mount | grep "$BLKID" | awk '{print $3}')
	if [ "$winDir/Users" ]; then
		echo "SUCCESS"
	else
		echo "FAIL"
		echo "Now exiting ..."
		sleep 2
		exit
	fi
fi
echo Accumulating data size of backup. Please wait.
echo -e "Approximate size of user data is $(du -sh $winDir/Users | awk '{print $1}')."
printf "Do you wish to continue with the network backup (y/n): "
read CONTINUE

[ "$CONTINUE" == 'n' -o "$CONTINUE" == 'N' ] && echo "Cancelling backup. Now exiting ..." && sleep 2 && exit

[ ! -d "$PCFOLDER/dataBackup" ] && mkdir "$PCFOLDER/dataBackup"
BACKUPLOCATION="$PCFOLDER/dataBackup/current"
sudo -u \#999 mkdir "$BACKUPLOCATION"
echo

sudo rsync -rhPt --links --info=progress2 "$winDir/Users/" "$BACKUPLOCATION"
sudo chmod -R 777 "$BACKUPLOCATION"
echo
echo "Data transfer complete."
sleep 2
exit

