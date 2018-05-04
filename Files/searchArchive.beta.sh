#!/bin/bash

#source sourcefile
source ./Files/commonFunctions.source

#set prefix
PREFIX="Files/CustomerLogs"

#function to get archive from customer name
get_archive_list_with_name() {
  findLocation="${1}" #location to search in with find command
  findType="${2}" #Either 'f' for file or 'd' for directory
  findName="${3}" #Actual search term to look for
  currentList=() #Initialize list array
  declare -i ITERATION #declare iteration var as integer
  ITERATION=0 #Start var at 0
  while read -r foundMatch; do
    currentList+=("${foundMatch}")
  done < <(find "${findLocation}" -maxdepth 1 -type "${findType}" -name "*${findName}*") #This while loop runs the actual find command and adds each item to the array

  for listItem in "${currentList[@]}"; do
    currentList["${ITERATION}"]="$(echo ${listItem} | sed 's:^.*\/\+\(.*$\):\1:')"
    ITERATION+=1
  done #This for loop normalizes the data in the array to suite our needs

  select opt in "${currentList[@]}"; do
    chosenItem="${opt}"
    break
  done #This displays all of the items in the array and lets the user choose one
  echo "${chosenItem}" #return the user chosen option
}

get_archive_list_with_id() {
  chosenID="${1}"
  oIFS="${IFS}"
  oCOLUMNS="${COLUMNS}"
  IFS=$'\n'
  COLUMNS=1
  archiveList=()

  declare -i ITERATION #declare iteration var as integer
  ITERATION=0 #Start var at 0

  idFolder="$(find ${PREFIX} -maxdepth 2 -type d -name *${chosenID})"

  while read -r foundMatch; do
    archiveList+=("$foundMatch")
  done < <(find "${idFolder}" -maxdepth 1 -type f -name "*[0-9]")

  for listItem in "${archiveList[@]}"; do
    archiveList["${ITERATION}"]="$(echo ${listItem} | sed 's:^.*\/\+\(.*$\):\1:')"
    ITERATION+=1
  done #This for loop normalizes the data in the array to suite our needs

  select opt in ${archiveList[@]}; do
    chosenArchive="${opt}"
    break
  done #This displays all of the items in the array and lets the user choose one

  IFS="${oIFS}"
  COLUMNS="${oCOLUMNS}"

  echo "${idFolder}/${chosenArchive}"
}

main() {
echo
}

#main
#exit 0





############################################################
