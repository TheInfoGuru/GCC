#!/bin/bash

clear
function c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

echo '***************************************************************'
printf "Please enter the PC ID or scan it off the computer: "
read PCID
echo

PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
CUSFOLDER=$(echo "${PCFOLDER%/*}")

if [ ! "$PCFOLDER" ]; then
        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
        sleep 3
        exit
fi

if [ ! -f "$PCFOLDER/log" ]; then
        echo "ERROR: PC NEEDS TO BE CHECKED IN BEFORE YOU CAN CHANGE ITS STATUS."
	echo "Please try again after checking PC in."
        sleep 3
        exit
fi

actionID=NA

main() {
[ ! "$actionID" ] && exit
echo '***************************************************************'
printf "Please enter or scan the ActionID, or press enter to exit: "
read actionID
echo

case $actionID in
       A1|A2|A3|A4|A5|A6|A7|B1|B2|C1|C2|C3|C4|C5|C6|C7|D|E1|E2|"Front Counter"|"1 Bench"|"2 Bench"|"3 Bench"|"4 Bench"|"5 Bench")
		echo "$actionID" > "$PCFOLDER/location";
		echo -e "[$(c_timestamp)] Computer was moved to $actionID." >> "$PCFOLDER/log";
		echo '**********************************';
		echo '** PC Location has been changed **';
		echo '**********************************';
		echo ;
		sleep 1;
		main;
                ;;

	OtherLocation)
		echo '***************************************************************'
		read -p "Please enter other location: " otherLocation;
		echo "$otherLocation" > "$PCFOLDER/location";
		echo -e "[$(c_timestamp)] Computer was moved to $otherLocation." >> "$PCFOLDER/log";
		echo '**********************************';
		echo '** PC Location has been changed **';
		echo '**********************************';
		echo ;
		sleep 1;
		main;
                ;;

        Contacted|"Need to Call"|"Left Voicemail"|"Could Not Reach"|"Customer Came In")
		echo "$actionID" > "$PCFOLDER/contactStatus";
		echo -e "[$(c_timestamp)] Phone log has been updated to $actionID." >> "$PCFOLDER/log";
		echo '*************************************';
		echo '** Contact status has been changed **';
		echo '*************************************';
		echo ;
		sleep 1;
		main;
		;;

	"In Repair"|"In Diagnostics"|"Repair Complete"|"No Repair Done"|"Waiting")
		echo "$actionID" > "$PCFOLDER/status";
		echo -e "[$(c_timestamp)] Computer status was updated to $actionID." >> "$PCFOLDER/log";
		echo '**************************************';
		echo '** Computer status has been changed **';
		echo '**************************************';
		echo ;
		sleep 1;
		main;
		;;

       "")
		main;
                ;;

        *)
		echo "Incorrect Option. Please try again.";
		echo ;
		sleep 1;
		main;
		;;
esac
}
main
