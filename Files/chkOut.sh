#!/bin/bash
clear
function c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

echo '***************************************************************'
printf "Please enter the PC ID or scan it off the computer: "
read PCID
echo

PCFOLDER=$(find ./* -name "$PCID")
CUSFOLDER=$(echo "${PCFOLDER%/*}")

if [ ! "$PCFOLDER" ]; then
	echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN"
	echo "OR CHECK IN AS NEW PC."
	sleep 3
	exit
fi

if [ ! -f "$PCFOLDER/log" ]; then
	echo "ERROR: PC HAS NOT BEEN CHECKED IN YET."
	sleep 3
	exit
fi

echo -e "[$(c_timestamp)] Checked out computer." >> "$PCFOLDER/log"

ARCHIVEFILE=$(date --rfc-3339=seconds | tr ' ' '_' | tr ':' '.')
ARCHIVEFILE=$(echo ${ARCHIVEFILE%-*} | rev | cut -c 4- | rev)
ARCHIVEFILE="$PCFOLDER/$ARCHIVEFILE"
NOTESFILE="$PCFOLDER/notes"
INFOFILE="$PCFOLDER/info"
LOGFILE="$PCFOLDER/log"
LOCATIONFILE="$PCFOLDER/location"
CUSINFOFILE="$CUSFOLDER/info.cus"
CHKINFILE="$PCFOLDER/check_in"
STATUSFILE="$PCFOLDER/status"
RANLOGSFILE="$PCFOLDER/ranLogs"
CONTACTSTATUSFILE="$PCFOLDER/contactStatus"

echo '***************************CUSTOMER INFO***************************' >> "$ARCHIVEFILE"
cat "$CUSINFOFILE" >> "$ARCHIVEFILE"
echo >> "$ARCHIVEFILE"

if [ -f "$NOTESFILE" ]; then
echo '*******************************NOTES*******************************' >> "$ARCHIVEFILE"
cat "$NOTESFILE" >> "$ARCHIVEFILE"
echo >> "$ARCHIVEFILE"
rm -f "$NOTESFILE"
fi

echo '*******************************LOG**********************************' >> "$ARCHIVEFILE"
cat "$LOGFILE" >> "$ARCHIVEFILE"
echo >> "$ARCHIVEFILE"
rm -f "$LOGFILE"

if [ -f "$INFOFILE" ]; then
echo >> "$ARCHIVEFILE"
cat "$INFOFILE" | tail -n 60 >> "$ARCHIVEFILE"
echo >> "$ARCHIVEFILE"
rm -f "$INFOFILE"
fi

rm -f "$STATUSFILE"
rm -f "$LOCATIONFILE"
rm -f "$CHKINFILE"
rm -f "$RANLOGSFILE"
rm -f "$CONTACTSTATUSFILE"

DATABACKUPFOLDER="$PCFOLDER/dataBackup/current"
CURRENTDATE=$(date "+%m%d%y")

[ -d "$DATABACKUPFOLDER" ] && mv "$DATABACKUPFOLDER" "$PCFOLDER/dataBackup/$CURRENTDATE"

echo
echo '******************************'
echo '** PC has been checked out. **'
echo '******************************'
sleep 2
exit

