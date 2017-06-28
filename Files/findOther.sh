#!/bin/bash

PCFOLDER="$PWD/CustomerLogs/Other"

c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

find_archive() {
echo $PCFOLDER
read -p 'top of func' nul
	old_IFS=$IFS
	for i in $(find "$PCFOLDER" -maxdepth 6 -type f); do
	                read -p 'in for loop' nul
			IFS=
			echo "$i"
	                archiveArray+=($i)
        done
	IFS=${old_IFS}

	if [ ! $archiveArray ]; then
	echo "ERROR: NO INFO FILES FOUND."
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


show_archive() {
cat $ARCHIVEFILE | less
}

find_archive

exit 0
