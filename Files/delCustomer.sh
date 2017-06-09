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
printf "Please type in the customer name to be deleted (WARNING: THIS WILL DELETE ALL DATA OF ALL COMPUTERS UNDER THIS CUSTOMER: "
read CUSNAME
echo
CUSFIND=$(echo "$CUSNAME" | tr -d ' ')
CUSFOLDER=$(find ./* -maxdepth 4 -type d -iname "$CUSFIND")
	[ ! "$CUSFOLDER" ] && echo "Customer not found. Going back." && sleep 2 && main
	echo "You have selected $CUSNAME located at $CUSFOLDER as the customer to delete."
	printf "Is this correct (Y/n): "
	read rightCus
	if [ "$rightCus" == "n" ]; then
		echo
		echo "Starting over in 3 seconds."
		sleep 3
		main
	fi
	echo
	echo "Deleting this customer will delete files for the following PC IDs:"
	echo
	for i in $(find "$CUSFOLDER" -maxdepth 1 -type d -iname "ID*"); do
     		echo "$i"
	done
	echo
	printf "ARE YOU SURE YOU WANT TO PERMANANTLY DELETE CUSTOMER FOLDER? RECOVERY WILL NOT BE POSSIBLE!! (y/N): "
	read DELFOLDER

	if [ "$DELFOLDER" == "y" ]; then
		rm -rf "$CUSFOLDER" 2> /dev/null
		if [ -d "$CUSFOLDER" ]; then
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
