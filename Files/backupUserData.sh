#!/bin/bash
clear

c_timestamp() {
	date | awk '{print $2,$3,$4}'
}

printf "Enter or scan the PC ID, or type (o) for other: "
read PCID

#if [ "$PCID" == 'o' ]; then

#fi

printf "Skip backing up AppData folders (Y/n): "
read SKIPAPPDATA

[ "$SKIPAPPDATA" != "y" ] && [ "$SKIPAPPDATA" != "n" ] && [ "$SKIPAPPDATA" != '' ] && echo 'You must say either "y" or "n"!' && sleep 2 && exit
[ "$SKIPAPPDATA" == '' ] && SKIPAPPDATA=y
choose_partition() {
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
	if [ -d $winDir/Users ]; then
		echo "SUCCESS"
	else
		echo "FAIL"
		echo "Now exiting ..."
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
if [ -d $HOME/winMount/Users ]; then
	winDir=$HOME/winMount
else
	winDir=$(mount | grep "$winMount" | awk '{print $3}')
fi

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
                echo "Could not find a Window Drive. Now Exiting ..."
		sleep 2
		exit
        fi
else
	echo yes
	choose_partition
fi

echo "Accumulating data size of backup. Please wait."
if [ "$SKIPAPPDATA" == "y" ]; then
	SOURCESIZE=$(du -sh --exclude='AppData*' $winDir/Users | awk '{print $1}' 2>/dev/null)
elif [ "$SKIPAPPDATA" == "n" ]; then
	SOURCESIZE=$(du -sh $winDir/Users | awk '{print $1}' 2>/dev/null)
else
	echo "How the hell did you get here?"
	sleep 2
	exit
fi

echo "Approximate size of user data is $SOURCESIZE."
printf "Do you wish to continue with the network backup (y/n): "
read CONTINUE

[ "$CONTINUE" == 'n' -o "$CONTINUE" == 'N' ] && echo "Cancelling backup. Now exiting ..." && sleep 2 && exit

[ ! -d "$PCFOLDER/dataBackup" ] && mkdir "$PCFOLDER/dataBackup"
BACKUPLOCATION="$PCFOLDER/dataBackup/current"
mkdir "$BACKUPLOCATION" 2>/dev/null
echo

if [ "$SKIPAPPDATA" == "y" ]; then
	sudo rsync -rht --exclude 'AppData' --info=progress2 "$winDir/Users/" "$BACKUPLOCATION" 2>/dev/null
	sudo rsync -rht --exclude 'AppData' --info=progress2 "$winDir/Windows/System32/config/SOFTWARE" "$BACKUPLOCATION" 2>/dev/null
	sudo rsync -rht --exclude 'AppData' --info=progress2 "$winDir/Windows/System32/config/software" "$BACKUPLOCATION" 2>/dev/null
elif [ "$SKIPAPPDATA" == "n" ]; then
	sudo rsync -rht --info=progress2 "$winDir/Users/" "$BACKUPLOCATION" 2>/dev/null
	sudo rsync -rht --info=progress2 "$winDir/Windows/System32/config/SOFTWARE" "$BACKUPLOCATION" 2>/dev/null
	sudo rsync -rht --info=progress2 "$winDir/Windows/System32/config/software" "$BACKUPLOCATION" 2>/dev/null
else
	echo "How the hell did you get here?"
	sleep 2
	exit
fi

sudo chmod -R 777 "$BACKUPLOCATION"
echo "Comparing sizes between source and destination."
DESTSIZE=$(du -sh $BACKUPLOCATION | awk '{print $1}' 2>/dev/null)
echo
echo "Source was $winDir/Users/, size $SOURCESIZE; Destination was $BACKUPLOCATION, size $DESTSIZE."
read -p 'Press enter to finish.' nul
echo -e "[$(c_timestamp)] Backup of user data was completed." >> "$PCFOLDER/log";
echo
echo "Data transfer complete."
sleep 2
exit

