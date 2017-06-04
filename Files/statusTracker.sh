#!/bin/bash

clean_up() {
	rm $TRACKERFILEFILTER 2> /dev/null
	rm $TRACKERFILE 2> /dev/null

}

CODEWORD=working
TRACKERFILE=$(mktemp)

printf "Enter or scan filter tag (e.g. Need to Call, 1 Bench, Repair Complete, etc ...) or press enter for no filter: "
read FILTER

echo >> "$TRACKERFILE"
echo "Customer Name*PC ID*Location*Status*Check-In Date*Contact Status*Got Logs?*Data Backup" >> "$TRACKERFILE"
echo "--------------------------*-----*---------*-----------------------*-------------*---------------------*-----------*-------------" >> "$TRACKERFILE"
for i in $(find ./* -maxdepth 6 -type f -name 'log'); do
	PCFOLDER=$(echo "${i%/*}")
	CUSFOLDER=$(echo "${PCFOLDER%/*}")
	CUSNAME=$(cat "$CUSFOLDER/info.cus" | head -n 1)
	PCID=$(echo "$PCFOLDER" | egrep -o "ID[0-9]?[0-9]?[0-9]?[0-9]")
	LOCATION=$(cat "$PCFOLDER/location")
	PCSTATUS=$(cat "$PCFOLDER/status")
	CHKINDATE=$(cat "$PCFOLDER/check_in")
	RANLOGS=$(cat "$PCFOLDER/ranLogs")
	CONTACTSTATUS=$(cat "$PCFOLDER/contactStatus")
	BACKUPLOCATION="$PCFOLDER/dataBackup/current"
	if [ -d "$BACKUPLOCATION" ]; then
		DATABACKUP="Y"
	else
		DATABACKUP="N"
	fi
	echo "$CUSNAME*$PCID*$LOCATION*$PCSTATUS*$CHKINDATE*$CONTACTSTATUS*$RANLOGS*$DATABACKUP" >> "$TRACKERFILE"
done

if [ "$FILTER" ]; then
	TRACKERFILEFILTER=$(mktemp)
	echo "Customer Name*PC ID*Location*Status*Check-In Date*Contact Status*Got Logs?*Data Backup" > "$TRACKERFILEFILTER"
	echo "--------------------------*-----*---------*-----------------------*-------------*---------------------*-----------*-------------" >> "$TRACKERFILEFILTER"
	if [ "${FILTER,,}" == "${CODEWORD,,}" ]; then
		grep -iv "Repair Complete" "$TRACKERFILE" >> "$TRACKERFILEFILTER"
	else
		grep -i "$FILTER" "$TRACKERFILE" >> "$TRACKERFILEFILTER"
	fi
	column -s '*' -t "$TRACKERFILEFILTER" | less
	clean_up
	exit
fi

column -s '*' -t "$TRACKERFILE" | less
clean_up
