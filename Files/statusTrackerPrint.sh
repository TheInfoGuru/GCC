#!/bin/bash

LPR() {
#[ ! command -v enscript ] && echo "Installing enscript. Please wait." && sudo apt install -qqy enscript
ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
export ENSCRIPT
/usr/bin/enscript -p - $1 | /usr/bin/lpr
}


clean_up() {
	rm $TRACKERFILEFILTER 2> /dev/null
	rm $TRACKERFILE 2> /dev/null

}

CODEWORD=working
TRACKERFILE=$(mktemp)


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

LPR $TRACKERFILE
clean_up
