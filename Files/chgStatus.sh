#!/bin/bash

clear
function c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

#ShortCode List Location
CODELIST='./Files/statusIDs.list'
#Spacer for Notes
SPACER=' - '

echo '***************************************************************'
printf "Please enter the PC ID or scan it off the computer: "
read PCID
echo

if [ "${PCID:0:2}" != "ID" ]; then
	PCIDLoc=$(mktemp)
	echo $PCID > $PCIDLoc
	PCID=$(sed -e 's/^/ID/' $PCIDLoc)
	rm $PCIDLoc
fi


PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
CUSFOLDER=$(echo "${PCFOLDER%/*}")

if [ ! "$PCFOLDER" ]; then
        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
        sleep 1
        exit
fi

if [ ! -f "$PCFOLDER/log" ]; then
        echo "ERROR: PC NEEDS TO BE CHECKED IN BEFORE YOU CAN CHANGE ITS STATUS."
	echo "Please try again after checking PC in."
        sleep 1
        exit
fi

actionID=NA

main() {
echo '***************************************************************'
printf "Please enter or scan the ActionID, press \"o\" for other location, or press enter to exit: "
read choice
echo

if [ -z "$choice" ]; then
	return 0
fi

choice="${choice^^}"

actionID="$(grep -w "$choice" "$CODELIST" | awk -F '`' '{print $2}')"
shortcode="$(grep -w "$choice" "$CODELIST" | awk -F '`' '{print $1}')"
doPass="$(grep -w "$choice" "$CODELIST" | awk -F '`' '{print $3}')"

if [ "$doPass" ]; then
	notesList+="$shortcode$SPACER"
fi

#if [ "$actionID" == 'WC' ]; then
#	actionID='Waiting (Cust)'
#elif [ "$actionID" == 'WP' ]; then
#	actionID='Waiting (Part)'
#elif [ "$actionID" == 'WT' ]; then
#	actionID='Waiting (Tech)'
#elif [ "$actionID" == 'NTC' ]; then
#	actionID='Need to Call'
#elif [ "$actionID" == 'LVM' ]; then
#	actionID='Left Voicemail'
#elif [ "$actionID" == 'C' ]; then
#	actionID='Contacted'
#elif [ "$actionID" == 'CNR' ]; then
#	actionID='Could Not Reach'
#elif [ "$actionID" == 'IR' ]; then
#	actionID='In Repair'
#elif [ "$actionID" == 'IDG' ]; then
#	actionID='In Diagnostics'
#elif [ "$actionID" == 'RC' ]; then
#	actionID='Repair Complete'
#elif [ "$actionID" == 'NRD' ]; then
#	actionID='No Repair Done'
#elif [ "$actionID" == 'CCI' ]; then
#	actionID='Cust Came In'
#elif [ "$actionID" == 'LW' ]; then
#	actionID='Layaway'
#elif [ "$actionID" == '1B' ]; then
#	actionID='1 Bench'
#elif [ "$actionID" == '2B' ]; then
#	actionID='2 Bench'
#elif [ "$actionID" == '3B' ]; then
#	actionID='3 Bench'
#elif [ "$actionID" == '4B' ]; then
#	actionID='4 Bench'
#elif [ "$actionID" == '5B' ]; then
#	actionID='5 Bench'
#elif [ "$actionID" == 'FC' ]; then
#	actionID='Front Counter'
#elif [ "$actionID" == 'D' ]; then
#	actionID='D1'
#fi

case $actionID in
       A1|A2|A3|A4|A5|A6|A7|B1|B2|C1|C2|C3|C4|C5|C6|C7|D1|E1|E2|"Front Counter"|"1 Bench"|"2 Bench"|"3 Bench"|"4 Bench"|"5 Bench")
		echo "$actionID" > "$PCFOLDER/location";
		echo -e "[$(c_timestamp)] Computer was moved to $actionID." >> "$PCFOLDER/log";
		echo '**********************************';
		echo '** PC Location has been changed **';
		echo '**********************************';
		echo ;
		main;
                ;;

	o|O)
		echo '***************************************************************'
		read -p "Please enter other location: " otherLocation;
		echo "$otherLocation" > "$PCFOLDER/location";
		echo -e "[$(c_timestamp)] Computer was moved to $otherLocation." >> "$PCFOLDER/log";
		echo
		echo '**********************************';
		echo '** PC Location has been changed **';
		echo '**********************************';
		echo ;
		main;
                ;;

        Contacted|"Need to Call"|"Left Voicemail"|"Could Not Reach"|"Cust Came In")
		echo "$actionID" > "$PCFOLDER/contactStatus";
		echo -e "[$(c_timestamp)] Phone log has been updated to $actionID." >> "$PCFOLDER/log";
		echo '*************************************';
		echo '** Contact status has been changed **';
		echo '*************************************';
		echo ;
		main;
		;;

	"In Repair"|"In Diagnostics"|"Repair Complete"|"No Repair Done"|"Waiting"|"Waiting (Part)"|"Waiting (Tech)"|"Waiting (Cust)"|"Layaway")
		echo "$actionID" > "$PCFOLDER/status";
		echo -e "[$(c_timestamp)] Computer status was updated to $actionID." >> "$PCFOLDER/log";
		echo '**************************************';
		echo '** Computer status has been changed **';
		echo '**************************************';
		echo ;
		main;
		;;

       "")
		main;
                ;;

        *)
		echo "Incorrect Option. Please try again.";
		echo ;
		main;
		;;
esac
}

main

if [ "$notesList" ]; then
	source "./Files/mkNote.sh" "$notesList" "$PCFOLDER"
fi

exit 0
