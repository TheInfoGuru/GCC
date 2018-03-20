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

up_id() {
	echo -e "ID$(expr $(cat $IDCOUNT | cut -c 3-) + 1)" > "$IDCOUNT"
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
echo -e "														     $(today_date)" >> $PRINTFILE
echo ' __________________________________________				________________' >> $PRINTFILE
echo '			  Customer Signature							   	    Date' >> $PRINTFILE
echo >> $PRINTFILE
echo >> $PRINTFILE
echo 'Computer Resource is not responsible for any lost data. We recommend you back up your data regularly.' >> $PRINTFILE
LPR $PRINTFILE > /dev/null 2>/dev/null
}

#Clear the screen
clear

#Preset the variable to a value
rightInfo=n

#User input to see if new or existing
echo '***************************************************************'
printf "Please scan or enter PCID, or type (n) for new PCID: "
read PCID
echo
if [ "$PCID" != "n" ]; then
	if [ "${PCID:0:2}" != "ID" ]; then
		PCIDLoc=$(mktemp)
		echo $PCID > $PCIDLoc
		PCID=$(sed -e 's/^/ID/' $PCIDLoc)
		rm $PCIDLoc
	fi
fi
################################################################# IF NEW PC ##################################################################

if [ "$PCID" == "n" ]; then
	#Store variables
	IDCOUNT=$(find ./* -maxdepth 6 -type f -name '.IDCOUNT')
	PCID=$(cat "$IDCOUNT")
	UPID="y"

	#Display to user the next available PC ID
	echo '***************************************************************'
	echo "Next PC ID is $PCID"
	echo

	#Type in the customer's name
	printf "Type in customer's name: "
	read CUSNAME
	echo

	#Set more variables (locations)
	CUSFOLDER=$(find ./* -maxdepth 6 -name "info.cus" -exec egrep -il "$CUSNAME" {} \;)
	CUSFOLDER=$(echo ${CUSFOLDER%/*})
	LOGSFOLDER=$(find ./* -maxdepth 6 -name 'CustomerLogs')

	#Check if customer doesn't have a folder
	if [ ! $CUSFOLDER ]; then
		#Make a directory in the correct location user customer's name, create customer info file, and open it in editor
		CUSFOLDER=$(echo "$CUSNAME" | tr -d ' ')
		CUSFOLDER="$LOGSFOLDER/$CUSFOLDER"
		mkdir "$CUSFOLDER"
		echo "$CUSNAME" >> "$CUSFOLDER/info.cus"
		echo '***************************************************************'
		printf 'Please enter customer phone number with hyphens (e.g. 251-123-4567): '
		read PHONENUMBER
		echo "$PHONENUMBER" >> "$CUSFOLDER/info.cus"
		echo
	#If they do have a folder already
	else
		#display customer info to verify if current and correct
		echo '***************************************************************'
		cat "$CUSFOLDER/info.cus"
		echo
		printf "Is this the correct customer (Y/n): "
		read rightInfo
		echo

		if [ "$rightInfo" == "n" ]; then
			echo "Try making a new customer with middle initial."
			sleep 3
			exit
		fi

		echo '***************************************************************'
		printf "Need to update customer info? (y/N): "
		read updateInfo
		echo

		#If not correct, open in editor
		[ "$updateInfo" == "y" ] && nano "$CUSFOLDER/info.cus"

		#Get Phone Number
		PHONENUMBER=$(cat "$CUSFOLDER/info.cus" | head -n 2 | tail -n 1)
	fi

	#Make new folder for new computer under PC ID name
	PCFOLDER="$CUSFOLDER/$PCID"
	mkdir "$PCFOLDER" 2> /dev/null
	chmod -R 777 "$PCFOLDER"
else

	################################################### NEXT PART ############################################################################

	#Using PC ID set the PC folder location and the Customer Folder location in variables
	PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
	CUSFOLDER=$(echo "${PCFOLDER%/*}")
	CUSNAME=$(cat "$CUSFOLDER/info.cus" | head -n 1)
	PHONENUMBER=$(cat "$CUSFOLDER/info.cus" | head -n 2 | tail -n 1)

	#if the PC ID given doesn't have a corresponding folder, show an error and exit
	if [ ! "$PCFOLDER" ]; then
		echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN"
		echo "OR CHECK IN AS NEW PC."
		sleep 3
		exit
	fi

	#if the PC ID given hasn't been checked in and, show an error and exit
	[ -f "$PCFOLDER/log" ] && echo "ERROR: PC HAS ALREADY BEEN CHECKED IN OR WASN'T CHECKED OUT LAST TIME" && sleep 3 && exit

	#display customer info to verify if current and correct
	echo '***************************************************************'
	cat "$CUSFOLDER/info.cus"
	echo
	printf "Is this the correct customer (Y/n): "
	read rightInfo
	echo

	if [ "$rightInfo" == "n" ]; then
		echo "Try making a new customer with middle initial."
		sleep 3
		exit
	fi

	echo '***************************************************************'
	printf "Need to update customer info? (y/N): "
	read updateInfo
	echo

	#If not correct, open in editor
	[ "$updateInfo" == "y" ] && nano "$CUSFOLDER/info.cus"
	CUSNAME=$(cat "$CUSFOLDER/info.cus" | head -n 1)
fi

#Make PC notes
echo '***************************************************************'
printf "What is the issue the PC is experiencing (reason for check in): "
read ISSUE
echo

#Create PC status file indicating it has been checked in, and make first line check-in and date
echo '***************************************************************'
printf "Is the computer being dropped off with a power cord (y/n): "
read CHARGER
echo

echo '***************************************************************'
printf "Does the PC power on and POST (y/n): "
read POWERON
echo

echo '***************************************************************'
printf "What is the password to the PC (press ENTER for no password): "
read PASSWORD
echo

#Write to files
echo -e "[$(c_timestamp)] Checked in computer." >> "$PCFOLDER/log"
echo -e "@@@@@ $(c_timestamp) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> "$PCFOLDER/notes"
echo "$ISSUE" >> "$PCFOLDER/notes"
echo >> "$PCFOLDER/notes"
echo $CHARGER > "$PCFOLDER/charger"
echo $POWERON > "$PCFOLDER/powerOn"
echo $PASSWORD > "$PCFOLDER/password"

#make a default location file with NA
echo "NA" > "$PCFOLDER/location"

#make a default status file
echo "NA" > "$PCFOLDER/status"

#make log check file and mark it N
echo "N" > "$PCFOLDER/ranLogs"

#make a default contact status file
echo "NA" > "$PCFOLDER/contactStatus"

#make a check in date file
date -R | awk '{print $3,$2,$4}' > "$PCFOLDER/check_in"

#FUCK IT CHMOD ALL FUCKING FILES TO 777
chmod -R 777 "$PCFOLDER"

#check to see if status file was successfully created to indicate check-in
if [ -f "$PCFOLDER/log" ]; then
	#Display to user that checkin was successful
	print_worksheet
	echo
	echo '*****************************'
	echo '** PC has been checked in. **'
	echo '*****************************'
	if [ "$UPID" == "y" ]; then
		up_id
	fi
	sleep 2
	exit
else
	#Display error that check-in was unsuccessful
	echo "ERROR: COULD NOT CHECK IN COMPUTER. PLEASE CONTACT SUPPORT."
	sleep 3
	exit
fi

exit
