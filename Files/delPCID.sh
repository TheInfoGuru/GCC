#!/bin/bash

#source sourcefile
source ./Files/commonFunctions.source

#locate and confirm PCID
find_pc_folder() {
  pcIdFolder=$(find . -maxdepth 4 -type d -name "${PCID}")
  [ ! "${pcIdFolder}" ] && echo "PCID not found. Going back." && sleep 2 && main

  echo "You have selected ${PCID} located at ${pcIdFolder} as the PCID to delete."
  read -p "Is this correct (Y/n): " confirmPCID

  if [ "${confirmPCID}" == "n" ]; then
    echo
    echo "Starting over."
    sleep 1
    find_pc_folder
  fi

  echo

  confirm_and_delete
}

#confirm and delete pcid folder
confirm_and_delete() {
  read -p  "ARE YOU SURE YOU WANT TO PERMANANTLY DELETE PCID FOLDER? RECOVERY WILL NOT BE POSSIBLE!! (y/N): " confirmDelete

  #confirm deletion
  if [ "${confirmDelete}" == "y" ]; then
    rm -rf "${pcIdFolder}" 2> /dev/null
  else
    echo
    echo "Going back"
    sleep 1
    main
  fi


  #Make sure folder was deleted
  if [ -d "${pcIdFolder}" ]; then
    echo
    echo "Failed to delete customer folder. Now exiting ..."
    sleep 1
    exit 1
  else
    echo
    echo "Successfully deleted customer folder."
    sleep 1
  fi
}

main() {
  clear

  #get PCID from user
  break_line
  read -p 'Please type in the PCID to be deleted (WARNING: THIS WILL DELETE ALL DATA UNDER CHOSEN PCID): ' PCID
  echo

  add_id "${PCID}"

  find_pc_folder

  exit 0
}

main
