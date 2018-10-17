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

#source sourcefile
source ./Files/commonFunctions.source

#customer logs folder location
CUSTOMERLOGS="$(find . -maxdepth 3 -type d -name 'CustomerLogs')"
IDCOUNTFILE="$(find . -maxdepth 3 -type f -name '.IDCOUNT')"

existing_pcid() {
  #Using PC ID set the PC folder location and the Customer Folder location in variables
  pcFolderLocation=$(find . -maxdepth 4 -name "$pcid")
  customerFolder=$(echo "${pcFolderLocation%/*}")
  customerName=$(cat "${customerFolder}/info.cus" | head -n 1)
  phoneNumber=$(cat "${customerFolder}/info.cus" | head -n 2 | tail -n 1)

  #if the PC ID given doesn't have a corresponding folder, show an error and exit
  if [ ! "${pcFolderLocation}" ]; then
    echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN"
    echo "OR CHECK IN AS NEW PC."
    sleep 1
    exit 1
  fi

  #if the PC ID given hasn't been checked in and, show an error and exit
  [ -f "${pcFolderLocation}/log" ] && echo "ERROR: PC HAS ALREADY BEEN CHECKED IN OR WASN'T CHECKED OUT LAST TIME" && sleep 1 && exit

  #display customer info to verify if current and correct
  check_customer

  computer_questions
}

new_pcid() {
  #Store variables
  pcid=$(cat ${IDCOUNTFILE})
  upId="y"

  #Display to user the next available PC ID
  break_line
  echo "Next PC ID is ${pcid}."
  echo

  #Type in the customer's name
  read -ep 'Type in customers name: ' customerName
  echo

  #Set more variables (locations)
  customerFolder="${CUSTOMERLOGS}/$(echo ${customerName} | tr -d ' ')"
  #Check if customer doesn't have a folder
  if [ ! -d "${customerFolder}" ]; then
     trap remove_folders INT
     phoneNumber="$(make_customer)"
     echo
  else #If they do have a folder already
    check_customer
    #Get Phone Number
    phoneNumber=$(cat "${customerFolder}/info.cus" | head -n 2 | tail -n 1)
  fi

  #Make new folder for new computer under PC ID name
  pcFolderLocation="${customerFolder}/${pcid}"
  computer_questions
}

#Make a new customer
make_customer() {
  #Make a directory in the correct location user customer's name, create customer info file, and open it in editor
  mkdir "${customerFolder}"
  echo "$customerName" > "${customerFolder}/info.cus"
  break_line > /dev/stderr
  read -ep 'Please enter customer phone number with hyphens (e.g. 251-123-4567): ' phoneNumber
  echo "${phoneNumber}" >> "${customerFolder}/info.cus"
  echo "${phoneNumber}"
}

#Check existing customer
check_customer() {
  #display customer info to verify if current and correct
  break_line
  cat "${customerFolder}/info.cus"
  echo
  read -ep 'Is this the correct customer (Y/n): ' customerConfirmation
  echo

  if [ "${customerConfirmation}" == 'n' ]; then
    echo "Try making a new customer with middle initial."
    echo "Another customer already exists with this name."
    sleep 1
    exit 1
  fi

  break_line
  read -ep 'Need to update customer info? (y/N): ' updateCustomerInfo
  echo

  #If not correct, open in editor
  [ "${updateCustomerInfo}" == "y" ] && nano "${customerFolder}/info.cus"
}

#Ask questions about computer
computer_questions() {
  #Make PC notes
  break_line
  read -ep 'What is the issue the PC is experiencing (reason for check in): ' computerIssue
  echo

  #Create PC status file indicating it has been checked in, and make first line check-in and date
  break_line
  read -ep 'Is the computer being dropped off with a power cord (y/n): ' chargerPresent
  echo

  break_line
  read -ep 'Does the PC power on and POST (y/n): ' computerPowersOn
  echo

  break_line
  read -ep 'What is the password to the PC (press ENTER for no password): ' computerPassword
  echo

  make_tracker_files
}

make_tracker_files() {
  #Write to files
  if [ "${upId}" == 'y' ]; then
    mkdir "${pcFolderLocation}" 2> /dev/null
    chmod -R 777 "${pcFolderLocation}"
  fi

  echo -e "[$(c_timestamp)] Checked in computer." >> "${pcFolderLocation}/log"
  echo -e "@@@@@ $(c_timestamp) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> "${pcFolderLocation}/notes"
  echo "CheckIn - $computerIssue" | fold -sw 70 >> "${pcFolderLocation}/notes"
  echo >> "${pcFolderLocation}/notes"
  echo $chargerPresent > "${pcFolderLocation}/chargerPresent"
  echo $computerPowersOn > "${pcFolderLocation}/powerOn"
  echo $computerPassword > "${pcFolderLocation}/password"

  #make a default location file with NA
  echo "NA" > "${pcFolderLocation}/location"

  #make a default status file
  echo "NA" > "${pcFolderLocation}/status"

  #make log check file and mark it N
  echo "N" > "${pcFolderLocation}/ranLogs"

  #make a default contact status file
  echo "NA" > "${pcFolderLocation}/contactStatus"

  #make a check in date file
  today_date > "${pcFolderLocation}/check_in"

  #FUCK IT CHMOD ALL FUCKING FILES TO 777
  chmod -R 777 "${pcFolderLocation}"

  check_success
  return 0
}

check_success() {
  #check to see if status file was successfully created to indicate check-in
  if [ -f "${pcFolderLocation}/log" ]; then

    #Print off the worksheet
    print_worksheet

    #Display to user that checkin was successful
    echo
    echo '*****************************'
    echo '** PC has been checked in. **'
    echo '*****************************'

    if [ "${upId}" == "y" ]; then
      up_id
    fi

    sleep 1
    return 0
  else
    #Display error that check-in was unsuccessful
    echo "ERROR: COULD NOT CHECK IN COMPUTER. PLEASE CONTACT SUPPORT."
    sleep 1
    exit 1
  fi
}

#function to setup print parameters
LPR() {
  [ ! $(command -v enscript) ] && echo "Installing enscript. Please wait." && $(sudo apt install -qqy enscript)
  ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
  export ENSCRIPT
  /usr/bin/enscript -p - ${1} | /usr/bin/lpr
}

#Actually compile and make worksheet
print_worksheet() {

  #create temp file holding worksheet
  PRINTFILE=$(mktemp)

  echo '							                Computer Resource' >> ${PRINTFILE}
  echo '					   "Your Computer Resource for All Your Computer Needs"' >> ${PRINTFILE}
  echo '								          Hwy 90 Location' >> ${PRINTFILE}
  echo "									       PC ID: $pcid" >> ${PRINTFILE}
  echo '------------------------------------------------------------------------------------------------------------------------------------' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo "Customer Name:   ${customerName}" >> ${PRINTFILE}
  echo '			     -----------------------------			Repair Recommended: _________________________' >> ${PRINTFILE}
  echo "Phone Number:   ${phoneNumber}" >> ${PRINTFILE}
  echo '                           -------------------				     			            	      _________________________' >> ${PRINTFILE}
  echo "Does it power on and POST:   ${computerPowersOn}" >> ${PRINTFILE}
  echo '					        ---						   Estimated Price: _________________________' >> ${PRINTFILE}
  echo "Dropping off the charger:   ${chargerPresent}" >> ${PRINTFILE}
  echo '				           ---					  Customer Confirmed Date: _________________________' >> ${PRINTFILE}
  echo "Computer Password:   ${computerPassword}" >> ${PRINTFILE}
  echo '				   ------------------------		   Finish Date & Final Price: _________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '-----------------------' >> ${PRINTFILE}
  echo ' INITIAL ISSUES' >>${PRINTFILE}
  echo '-----------------------' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo "${computerIssue}" >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '--------------------' >> ${PRINTFILE}
  echo ' TECH NOTES' >>${PRINTFILE}
  echo '--------------------' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '________________________________________________________________________________________' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo '**All computers left over 30 days will become property of Computer Resource**' >> ${PRINTFILE}
  echo '**A $45 fee may apply if we have to disassemble your laptop to find the problem**' >> ${PRINTFILE}
  echo '**BY SIGNING THIS PAPER, YOU ARE AGREEING TO OUR TERMS AND CONDITIONS**' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo -e "														     $(today_date)" >> ${PRINTFILE}
  echo ' __________________________________________				________________' >> ${PRINTFILE}
  echo '			  Customer Signature							   	    Date' >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo >> ${PRINTFILE}
  echo 'Computer Resource is not responsible for any lost data. We recommend you back up your data regularly.' >> ${PRINTFILE}
  LPR ${PRINTFILE} > /dev/null 2>/dev/null
}

#make the id count go up by one
up_id() {
  echo -e "ID$(bc < <(echo $(cat ${IDCOUNTFILE} | cut -c 3-) + 1))" > "${IDCOUNTFILE}"
}

main() {
  #Clear the screen
  clear

  #Declare the variable to a value
  rightInfo=n

  #Get PCID from user
  pcid=$(get_pcid ", or type (n) for new PCID")

  trap remove_folders INT

  if [ "$pcid" == "n" ]; then
    new_pcid
  else
    existing_pcid
  fi
  return 0
}

remove_folders() {
  if [ "${customerFolder}" ]; then
    if [ ! $(find ${customerFolder}/* -type d) ]; then
      rm -rf "${customerFolder}"
    fi
  fi
  exit 1
}

main
exit 0
