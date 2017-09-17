#!/bin/bash

idDisplayArray=()
idFolderArray=()
CUSFOLDER=
PCFOLDER=
IDNUMBER=
nameArray=()
folderArray=()

c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

find_PC() {
	echo
	old_IFS=$IFS
	for i in $(find "$CUSFOLDER" -maxdepth 6 -type f -name "log")
	        do
	                IFS=
	                idDisplayArray+=($(echo $i | egrep -o "ID[0-9][0-9]?[0-9]?"))
	                idFolderArray+=($(echo ${i%/*}))
	        done
	IFS=${old_IFS}

	if [ "${idDisplayArray[1]}" ]; then

		PS3="Please choose a PCID from the matched customer search: "

		select pcOpt in "${idDisplayArray[@]}"; do
			case $pcOpt in
				"${idDisplayArray[0]}")
					PCFOLDER="${idFolderArray[0]}";
					IDNUMBER="${idDisplayArray[0]}"
					make_report;
					break;
					;;
				"${idDisplayArray[1]}")
					PCFOLDER="${idFolderArray[1]}";
					IDNUMBER="${idDisplayArray[1]}"
					make_report;
					break;
					;;
				"${idDisplayArray[2]}")
					PCFOLDER="${idFolderArray[2]}";
					IDNUMBER="${idDisplayArray[2]}"
					make_report;
					break;
					;;
				"${idDisplayArray[3]}")
					PCFOLDER="${idFolderArray[3]}";
					IDNUMBER="${idDisplayArray[3]}"
					make_report;
					break;
					;;
				"${idDisplayArray[4]}")
					PCFOLDER="${idFolderArray[4]}";
					IDNUMBER="${idDisplayArray[4]}"
					make_report;
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
		PCFOLDER="${idFolderArray[0]}"
		IDNUMBER="${idDisplayArray[0]}"
		make_report
	fi
}

make_report() {
	TMPREPORT=$(mktemp)
	echo '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&' >> "$TMPREPORT"
	echo "&&&&&&&&&&&&&&&&& REPORT FOR COMPUTER LABEL $IDNUMBER &&&&&&&&&&&&&&&&&&&&" >> "$TMPREPORT"
	echo '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&' >> "$TMPREPORT"
	echo >> "$TMPREPORT"
	echo '****************************CUSTOMER INFO****************************' >> "$TMPREPORT"
	cat "$CUSFOLDER/info.cus" >> "$TMPREPORT"
	echo >> "$TMPREPORT"

	if [ -f "$PCFOLDER/location" ]; then
		echo '******************************LOCATION*******************************' >> "$TMPREPORT"
		cat "$PCFOLDER/location" >> "$TMPREPORT"
		echo >> "$TMPREPORT"
	fi

	if [ -f "$PCFOLDER/log" ]; then
		echo '********************************LOG**********************************' >> "$TMPREPORT"
		cat "$PCFOLDER/log" >> "$TMPREPORT"
		echo >> "$TMPREPORT"
	fi

	if [ -f "$PCFOLDER/notes" ]; then
		echo '*******************************NOTES*********************************' >> "$TMPREPORT"
		cat "$PCFOLDER/notes" >> "$TMPREPORT"
		echo >> "$TMPREPORT"
	fi

	if [ -f "$PCFOLDER/info" ]; then
		cat "$PCFOLDER/info" >> "$TMPREPORT"
	fi

	cat "$TMPREPORT" | less
}

main() {
clear
echo '***************************************************************'
printf "Please type or scan PC ID, or type (c) for search by customer name: "
read PCID
echo

if [ "${PCID,,}" != "c" ] && [ "${PCID:0:2}" != "ID" ]; then
		PCIDLoc=$(mktemp)
		echo $PCID > $PCIDLoc
		PCID=$(sed -e 's/^/ID/' $PCIDLoc)
		rm $PCIDLoc
fi

if [ "$PCID" == "c" ]; then
	echo '***************************************************************'
	printf "Please enter the customer name to look for: "
	read searchName
	echo

	old_IFS=$IFS
	for i in $(find . -maxdepth 6 -type f -name "info.cus"); do
	        IFS=
	        nameArray+=($(egrep -i "$searchName" "$i"| head -n 1))
		tempVar=$(egrep -il "$searchName" "$i")
	        folderArray+=($(echo ${tempVar%/*}))
	done
	IFS=${old_IFS}

	if [ "${nameArray[1]}" ]; then

		PS3="Please choose a customer from the match search: "

		select cusOpt in "${nameArray[@]}"; do
	        	case $cusOpt in
	                	"${nameArray[0]}")
	                        	CUSFOLDER="${folderArray[0]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[1]}")
	                        	CUSFOLDER="${folderArray[1]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[2]}")
	                        	CUSFOLDER="${folderArray[2]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[3]}")
	                        	CUSFOLDER="${folderArray[3]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[4]}")
	                        	CUSFOLDER="${folderArray[4]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[5]}")
	                        	CUSFOLDER="${folderArray[5]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[6]}")
	                        	CUSFOLDER="${folderArray[6]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[7]}")
	                        	CUSFOLDER="${folderArray[7]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[8]}")
	                        	CUSFOLDER="${folderArray[8]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[9]}")
	                        	CUSFOLDER="${folderArray[9]}"
					find_PC
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
		find_PC
	fi
exit 0
fi

PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
CUSFOLDER=$(echo "${PCFOLDER%/*}")
IDNUMBER=$PCID

if [ ! "$PCFOLDER" ]; then
        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
        sleep 3
        exit
fi

if [ ! -f "$PCFOLDER/log" ]; then
        echo "ERROR: PC HAS NOT BEEN CHECKED IN YET."
        sleep 3
        exit
fi

make_report

}

main

exit 0
