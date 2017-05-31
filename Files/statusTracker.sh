#!/bin/bash


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
	echo "Customer Name*PC ID*Location*Status*Check-In Date*Contact Status*Got Logs?*Data Backup" >> "$TRACKERFILEFILTER"
	echo "--------------------------*-----*---------*-----------------------*-------------*---------------------*-----------*-------------" >> "$TRACKERFILEFILTER"
	grep -i "$FILTER" "$TRACKERFILE" >> "$TRACKERFILEFILTER"
#	if [ ! -s "$TRACKERFILEFILTER" ]; then
#		echo
#		echo "NO PCs FOUND WITH CHOSEN FILTER."
#		sleep 2
#		exit
#	fi
	column -s '*' -t "$TRACKERFILEFILTER" | less
	exit
fi

column -s '*' -t "$TRACKERFILE" | less
