#!/bin/bash

#Source sourcefile
source ./Files/commonFunctions.source #REAL SOURCE

#Clear the Screen
clear

#Hard Variables
CODELIST='./Files/statusIDs.list' #ShortCode List Location
SPACER=' - ' #Spacer for Notes

#display location moved banner
location_moved_banner() {
  echo '**********************************'
  echo '** PC Location has been changed **'
  echo '**********************************'
}

#display status changed banner
status_changed_banner() {
  echo '**************************************'
  echo '** Computer status has been changed **'
  echo '**************************************'

}

#PCID folder exist check
id_exist_check() {
  if [ ! "${pcFolder}" ]; then
    echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
    sleep 1
    exit 1
  fi

  if [ ! -f "${pcFolder}/log" ]; then
    echo "ERROR: PC NEEDS TO BE CHECKED IN BEFORE YOU CAN CHANGE ITS STATUS."
    echo "Please try again after checking PC in."
    sleep 1
    exit 1
  fi
}

#Get the pcid from user
get_pcid() {
  break_line > /dev/stderr
  read -p "Please enter the PC ID or scan it off the computer: " PCID
  echo > /dev/stderr
  set_pcid_variable "${PCID}"
}

#set the pcid variable
set_pcid_variable() {
  PCID="${1}"
  PCID=$(add_id ${PCID})
  echo "${PCID}"
}

#Make change to computer loop
make_change() {
  #Initialize variables blank
  actionID=""
  shortcode=""
  doPass=""
  choice=""

  break_line
  read -p "Please enter or scan the ActionID, press \"o\" for other location, or press enter to exit: " choice
  echo

  if [ -z "${choice}" ]; then
    make_started_note
    return 0
  fi

  choice="${choice^^}" #Make Choice Uppercase

  actionID="$(grep -w "${choice}" "${CODELIST}" | awk -F '`' '{print $2}')"
  shortcode="$(grep -w "${choice}" "${CODELIST}" | awk -F '`' '{print $1}')"
  doPass="$(grep -w "${choice}" "${CODELIST}" | awk -F '`' '{print $3}')"

  if [ "${doPass}" ]; then
    notesList+="${shortcode}${SPACER}"
  fi

  case $actionID in
    'A1'|'A2'|'A3'|'A4'|'A5'|'A6'|'A7'|'B1'|'B2'|'C1'|'C2'|'C3'|'C4'|'C5'|'C6'|'C7'|'D1'|'E1'|'E2'|'Front Counter'|'1 Bench'|'2 Bench'|'3 Bench'|'4 Bench'|'5 Bench')
      echo "${actionID}" > "${pcFolder}/location";
      echo -e "[$(c_timestamp)] Computer was moved to ${actionID}." >> "${pcFolder}/log";
      location_moved_banner ;
      echo ;
      make_change ;
      ;;

    'O')
      break_line
      read -p 'Please enter other location: ' otherLocation;
      echo "${otherLocation}" > "${pcFolder}/location";
      echo -e "[$(c_timestamp)] Computer was moved to ${otherLocation}." >> "${pcFolder}/log";
      echo ;
      location_moved_banner ;
      echo ;
      make_change ;
      ;;

    'Contacted'|'Need to Call'|'Left Voicemail'|'Could Not Reach'|'Cust Came In')
      echo "${actionID}" > "${pcFolder}/contactStatus";
      echo -e "[$(c_timestamp)] Phone log has been updated to ${actionID}." >> "${pcFolder}/log";
      echo ;
      status_changed_banner ;
      echo ;
      make_change ;
      ;;

    'In Repair'|'In Diagnostics'|'Repair Complete'|'No Repair Done'|'Waiting'|'Waiting (Part)'|'Waiting (Tech)'|'Waiting (Cust)'|'Layaway')
      echo "$actionID" > "$pcFolder/status";
      echo -e "[$(c_timestamp)] Computer status was updated to $actionID." >> "$pcFolder/log";
      echo ;
      status_changed_banner ;
      echo ;
      make_change;
      ;;

    *)
      echo "Incorrect Option. Please try again.";
      echo ;
      make_change ;
      ;;
  esac
}

#source and make new note if appropriate
make_started_note() {
  clear
  if [ "$notesList" ]; then
    source "./Files/mkNote.sh" "$notesList" "$pcFolder"
  fi
}

#Main Script
main() {
  PCID=$(get_pcid)
  pcFolder=$(find ./* -maxdepth 4 -name "$PCID")
  id_exist_check
  choice='NA'
  make_change
  exit 0
}

main
