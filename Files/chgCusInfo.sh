#!/bin/bash

CUSFOLDER=
nameArray=()
folderArray=()

c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

openInfo() {
	nano "$CUSFOLDER/info.cus"
}

openNotes() {
	nano "$CUSFOLDER/notes.cus"
}

openBoth() {
	nano "$CUSFOLDER/info.cus"
	nano "$CUSFOLDER/notes.cus"
}

openNotesInfoChoice() {
	echo
	echo '***************************************************************'
	printf 'Would you like change the customer (i)nfo, (n)otes, or (b)oth: '
	read choice1

	if [ "$choice1" == "i" -o "$choice1" == "I" ]; then
		openInfo
	elif [ "$choice1" == "n" -o "$choice1" == "N" ]; then
		openNotes
	elif [ "$choice1" == "b" -o "$choice1" == "B" ]; then
		openBoth
	else
		echo 'PLEASE EITHER CHOOSE "i" OR "n" OR "b" FOR YOUR CHOICE.'
		sleep 3
		openNotesInfoChoice
	fi
}


main() {
	clear

	echo '***************************************************************'
	printf "Please enter identifying info (name, phone #, etc...) to look for: "
	read searchTerm
	echo

	old_IFS=$IFS
	for i in $(find . -type f -name "info.cus"); do
	        IFS=
	        nameArray+=($(egrep -C 99 -i "$searchTerm" "$i" | head -n 1))
		tempVar=$(egrep -il "$searchTerm" "$i")
	        folderArray+=($(echo ${tempVar%/*}))
	done
	IFS=${old_IFS}

	if [ "${nameArray[1]}" ]; then

		PS3="Please choose a customer from the matched criteria: "

		select cusOpt in "${nameArray[@]}"; do
	        	case $cusOpt in
	                	"${nameArray[0]}")
	                        	CUSFOLDER="${folderArray[0]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[1]}")
	                        	CUSFOLDER="${folderArray[1]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[2]}")
	                        	CUSFOLDER="${folderArray[2]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[3]}")
	                        	CUSFOLDER="${folderArray[3]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[4]}")
	                        	CUSFOLDER="${folderArray[4]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[5]}")
	                        	CUSFOLDER="${folderArray[5]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[6]}")
	                        	CUSFOLDER="${folderArray[6]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[7]}")
	                        	CUSFOLDER="${folderArray[7]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[8]}")
	                        	CUSFOLDER="${folderArray[8]}"
					openNotesInfoChoice
					break;
	                        	;;
	                	"${nameArray[9]}")
	                        	CUSFOLDER="${folderArray[9]}"
					openNotesInfoChoice
					break;
	                        	;;
				*)
					echo "ERROR: YOU HAVE MADE AN INCORRECT CHOICE.";
					echo "PLEASE CHOOSE ONE OF THE OPTIONS LISTED.";
					sleep 3;
					;;
		        esac
		done
	else
		CUSFOLDER="${folderArray[0]}"
		openNotesInfoChoice
	fi
}

main

exit 0
