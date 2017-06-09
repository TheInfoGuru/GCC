#!/bin/bash

CUSFOLDER=
PCFOLDER=
nameArray=()
folderArray=()

c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

main() {
clear
echo '***************************************************************'
printf "Please type in the PCID to be deleted (WARNING: THIS WILL DELETE ALL DATA UNDER CHOSEN PCID: "
read PCID
echo
PCIDFOLDER=$(find ./* -maxdepth 4 -type d -iname "$PCID")
	[ ! "$PCIDFOLDER" ] && echo "PCID not found. Going back." && sleep 2 && main
	echo "You have selected $PCID located at $PCIDFOLDER as the PCID to delete."
	printf "Is this correct (Y/n): "
	read rightPCID
	if [ "$rightPCID" == "n" ]; then
		echo
		echo "Starting over in 3 seconds."
		sleep 3
		main
	fi
	echo
	printf "ARE YOU SURE YOU WANT TO PERMANANTLY DELETE PCID FOLDER? RECOVERY WILL NOT BE POSSIBLE!! (y/N): "
	read DELFOLDER

	if [ "$DELFOLDER" == "y" ]; then
		rm -rf "$PCIDFOLDER" 2> /dev/null
		if [ -d "$PCIDFOLDER" ]; then
			echo
			echo "Failed to delete customer folder. Now exiting ..."
			sleep 3
			exit 2
		else
			echo
			echo "Successfully deleted customer folder."
			sleep 2
		fi
	else
		echo
		echo "Going back"
		sleep 1
		main
	fi
exit 0

}

main

exit 0
