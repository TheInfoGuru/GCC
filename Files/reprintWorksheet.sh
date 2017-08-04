#!/bin/bash
###############################################################################
####									   ####
####				CHECK-IN SCRIPT				   ####
####				 DEVELOPED BY:				   ####
####			   STEVEN CATES & JON COFFEY			   ####
####									   ####
####	   	 *NOTE* Any empty echo commands are used soley		   ####
####	           for the readability of information given.		   ####
####									   ####
####		   !!ANY AND ALL INHERENT AND IMPLIED RIGHTS!!		   ####
####		 !!ARE FULLY AND SOLEY OWNED BY THE DEVELOPERS!!	   ####
####									   ####
###############################################################################

#function to get current datetime
function c_timestamp() {
	date | awk '{print $2,$3,$4}'
}

today_date() {
	date | awk '{print $2,$3,$6}'
}

LPR() {
[ ! command -v enscript ] && echo "Installing enscript. Please wait." && sudo apt install -qqy enscript
ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
export ENSCRIPT
/usr/bin/enscript -p - $1 | /usr/bin/lpr
}

print_worksheet() {
####################################################### ACTUAL PRINTING OF THE DROPOFF SHEET #######################################################################

PRINTFILE=$(mktemp)

echo '							                Computer Resource' >> $PRINTFILE
echo '					   "Your Computer Resource for All Your Computer Needs"' >> $PRINTFILE
echo '								          Hwy 90 Location' >> $PRINTFILE
echo "									       PC ID: $PCID" >> $PRINTFILE
echo '------------------------------------------------------------------------------------------------------------------------------------' >> $PRINTFILE
echo >> $PRINTFILE
echo "Customer Name:   $CUSNAME" >> $PRINTFILE
echo '			     -----------------------------			Repair Recommended: _________________________' >> $PRINTFILE
echo "Phone Number:   $PHONENUMBER" >> $PRINTFILE
echo '                           -------------------				     			            	      _________________________' >> $PRINTFILE
echo "Does it power on and POST:   $POWERON" >> $PRINTFILE
echo '					        ---						   Estimated Price: _________________________' >> $PRINTFILE
echo "Dropping off the charger:   $CHARGER" >> $PRINTFILE
echo '				           ---					  Customer Confirmed Date: _________________________' >> $PRINTFILE
echo "Computer Password:   $PASSWORD" >> $PRINTFILE
echo '				   ------------------------		   Finish Date & Final Price: _________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '-----------------------' >> $PRINTFILE
echo ' INITIAL ISSUES' >>$PRINTFILE
echo '-----------------------' >> $PRINTFILE
echo >> $PRINTFILE
echo "$ISSUE" >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '--------------------' >> $PRINTFILE
echo ' TECH NOTES' >>$PRINTFILE
echo '--------------------' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo '________________________________________________________________________________________' >> $PRINTFILE
echo >> $PRINTFILE
echo >> $PRINTFILE
echo '**All computers left over 30 days will become property of Computer Resource**' >> $PRINTFILE
echo '**A $45 fee may apply if we have to disassemble your laptop to find the problem**' >> $PRINTFILE
echo '**BY SIGNING THIS PAPER, YOU ARE AGREEING TO OUR TERMS AND CONDITIONS**' >> $PRINTFILE
echo >> $PRINTFILE
echo >> $PRINTFILE
echo -e "														     $DATE" >> $PRINTFILE
echo ' __________________________________________				________________' >> $PRINTFILE
echo '			  Customer Signature							   	    Date' >> $PRINTFILE
echo >> $PRINTFILE
echo >> $PRINTFILE
echo 'Computer Resource is not responsible for any lost data. We recommend you back up your data regularly.' >> $PRINTFILE
LPR $PRINTFILE > /dev/null 2>/dev/null
}

#Clear the screen
clear

#User input to get PCID
echo '***************************************************************'
printf "Enter the PCID of the computer worksheet to reprint: "
read PCID

if [ "${PCID:0:2}" != "ID" ]; then
	PCIDLoc=$(mktemp)
	echo $PCID > $PCIDLoc
	PCID=$(sed -e 's/^/ID/' $PCIDLoc)
	rm $PCIDLoc
fi

echo

################################################################# IF NEW PC ##################################################################

	#Using PC ID set the PC folder location and the Customer Folder location in variables
	PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
	CUSFOLDER=$(echo "${PCFOLDER%/*}")
	CUSNAME=$(cat "$CUSFOLDER/info.cus" | head -n 1)
	PHONENUMBER=$(cat "$CUSFOLDER/info.cus" | head -n 2 | tail -n 1)
	ISSUE=$(cat "$PCFOLDER/notes" | head -n 2 | tail -n 1)
	POWERON=$(cat "$PCFOLDER/powerOn" 2> /dev/null)
	CHARGER=$(cat "$PCFOLDER/charger" 2> /dev/null)
	DATE=$(cat "$PCFOLDER/check_in")
	#if the PC ID given doesn't have a corresponding folder, show an error and exit
	if [ ! "$PCFOLDER" ]; then
		echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN"
		echo "OR CHECK IN AS NEW PC."
		sleep 3
		exit
	fi

	#Display to user that checkin was successful
	print_worksheet
	echo
	echo '***********************************'
	echo '** Worksheet has been reprinted. **'
	echo '***********************************'
	sleep 2
	exit
