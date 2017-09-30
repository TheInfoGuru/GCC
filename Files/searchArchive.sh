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

find_archive() {
	old_IFS=$IFS
	for i in $(find "$PCFOLDER" -maxdepth 6 -type f | grep -v -E '(location|notes|log|status|check_in|dataBackup|info)'); do
	                IFS=
	                archiveArray+=($i)
	        done
	IFS=${old_IFS}

	if [ ! $archiveArray ]; then
	echo "ERROR: NO ARCHIVE FILES FOUND."
	sleep 3
	exit
	fi


	PS3="Please choose an archive file from the list: "

	select archiveOpt in "${archiveArray[@]}"; do
		case $archiveOpt in
			"${archiveArray[0]}")
				ARCHIVEFILE="${archiveArray[0]}";
				show_archive;
				break;
				;;
			"${archiveArray[1]}")
				ARCHIVEFILE="${archiveArray[1]}";
				show_archive;
				break;
				;;
			"${archiveArray[2]}")
				ARCHIVEFILE="${archiveArray[2]}";
				show_archive;
				break;
				;;
			"${archiveArray[3]}")
				ARCHIVEFILE="${archiveArray[3]}";
				show_archive;
				break;
				;;
			"${archiveArray[4]}")
				ARCHIVEFILE="${archiveArray[4]}";
				show_archive;
				break;
				;;
			"${archiveArray[5]}")
				ARCHIVEFILE="${archiveArray[5]}";
				show_archive;
				break;
				;;
			"${archiveArray[6]}")
				ARCHIVEFILE="${archiveArray[6]}";
				show_archive;
				break;
				;;
			"${archiveArray[7]}")
				ARCHIVEFILE="${archiveArray[7]}";
				show_archive;
				break;
				;;
			"${archiveArray[8]}")
				ARCHIVEFILE="${archiveArray[8]}";
				show_archive;
				break;
				;;
			"${archiveArray[9]}")
				ARCHIVEFILE="${archiveArray[9]}";
				show_archive;
				break;
				;;
			"${archiveArray[10]}")
				ARCHIVEFILE="${archiveArray[10]}";
				show_archive;
				break;
				;;
			"${archiveArray[11]}")
				ARCHIVEFILE="${archiveArray[11]}";
				show_archive;
				break;
				;;
			"${archiveArray[12]}")
				ARCHIVEFILE="${archiveArray[12]}";
				show_archive;
				break;
				;;
			"${archiveArray[13]}")
				ARCHIVEFILE="${archiveArray[13]}";
				show_archive;
				break;
				;;
			"${archiveArray[14]}")
				ARCHIVEFILE="${archiveArray[14]}";
				show_archive;
				break;
				;;
			"${archiveArray[15]}")
				ARCHIVEFILE="${archiveArray[15]}";
				show_archive;
				break;
				;;
			"${archiveArray[16]}")
				ARCHIVEFILE="${archiveArray[16]}";
				show_archive;
				break;
				;;
			"${archiveArray[17]}")
				ARCHIVEFILE="${archiveArray[17]}";
				show_archive;
				break;
				;;
			"${archiveArray[18]}")
				ARCHIVEFILE="${archiveArray[18]}";
				show_archive;
				break;
				;;
			"${archiveArray[19]}")
				ARCHIVEFILE="${archiveArray[19]}";
				show_archive;
				break;
				;;
			"${archiveArray[20]}")
				ARCHIVEFILE="${archiveArray[20]}";
				show_archive;
				break;
				;;
			"${archiveArray[21]}")
				ARCHIVEFILE="${archiveArray[21]}";
				show_archive;
				break;
				;;
			"${archiveArray[22]}")
				ARCHIVEFILE="${archiveArray[22]}";
				show_archive;
				break;
				;;
			"${archiveArray[23]}")
				ARCHIVEFILE="${archiveArray[23]}";
				show_archive;
				break;
				;;
			"${archiveArray[24]}")
				ARCHIVEFILE="${archiveArray[24]}";
				show_archive;
				break;
				;;
			*)
				echo "ERROR: YOU HAVE MADE AN INCORRECT CHOICE.";
				echo "PLEASE CHOOSE ONE OF THE OPTIONS LISTED.";
				sleep 3;
				;;
		esac
	done
}

find_PC() {
	echo
	old_IFS=$IFS
	for i in $(find "$CUSFOLDER" -maxdepth 1  | grep 'ID'); do
	                IFS=
	                idDisplayArray+=($(echo $i | grep -o 'ID[0-9]'))
	                idFolderArray+=($(echo ${i%/*}))
	        done
	IFS=${old_IFS}

	if [ "${idDisplayArray[1]}" ]; then

		PS3="Please choose a PCID from the matched customer search: "

		select pcOpt in "${idDisplayArray[@]}"; do
			case $pcOpt in
				"${idDisplayArray[0]}")
					PCFOLDER="${idFolderArray[0]}";
					find_archive;
					break;
					;;
				"${idDisplayArray[1]}")
					PCFOLDER="${idFolderArray[1]}";
					find_archive;
					break;
					;;
				"${idDisplayArray[2]}")
					PCFOLDER="${idFolderArray[2]}";
					find_archive;
					break;
					;;
				"${idDisplayArray[3]}")
					PCFOLDER="${idFolderArray[3]}";
					find_archive;
					break;
					;;
				"${idDisplayArray[4]}")
					PCFOLDER="${idFolderArray[4]}";
					find_archive;
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
		find_archive
	fi
}

show_archive() {
cat $ARCHIVEFILE | less
}

main() {
clear
echo '****************************************************************************************************'
printf "Please enter or scan PC ID, or type (c) to search by customer name: "
read PCID

#if [ "${PCID:0:2}" != "ID" ]; then
#	PCIDLoc=$(mktemp)
#	echo $PCID > $PCIDLoc
#	PCID=$(sed -e 's/^/ID/' $PCIDLoc)
#	rm $PCIDLoc
#fi

echo

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
if [ ! "$PCFOLDER" ]; then
        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
        sleep 3
        exit
fi

find_archive
}

main

exit 0
