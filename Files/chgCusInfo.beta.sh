#!/bin/bash

source "./Files/commonFunctions.source"
LOGFOLDER="./Files/CustomerLogs"
PS3=$'\nPlease enter your choice: '
COLUMNS=1
dontSearch='estimate|location|notes|log|status|check_in|dataBackup|info|chargerPresent|charger|contactStatus|password|powerOn|ranLogs'

function get_archive_list() {
  break_line
  echo 'List of possible archive files'
  echo
  select opt in $(find "${pcidFolder}" -maxdepth 1 -type f | grep -v -E "(${dontSearch})" | sed 's/^.*\///g'); do
    archiveFile="${opt}"
    break
  done

  if [ -z "${archiveFile}" ]; then
    echo "No archive files found for that PCID."
    sleep 1.5
    exit 1
  fi

  cat "${pcidFolder}/${archiveFile}" | less

}

function search_by_name() {
  name=$(echo "${choice}" | sed 's/ //g')
  break_line
  echo 'List of possible customers'
  echo
  select opt in $(find "${LOGFOLDER}" -maxdepth 1 -type d | grep -i "${name}" | sed 's/^.*\///g'); do
    customer="${opt}"
    break
  done

  if [ -z "${customer}" ]; then
    echo "No customers found by that name."
    sleep 1.5
    exit 1
  fi

  customerFolder="${LOGFOLDER}/${customer}"
  echo
  break_line
  echo 'List of possible PCIDs'
  echo
  select opt in $(find "${customerFolder}" -maxdepth 1 -type d | grep 'ID' | sed 's/^.*\///g'); do
    pcid="${opt}"
    break
  done

  pcidFolder="${customerFolder}/${pcid}"
  echo
  get_archive_list
}

function search_by_pcid() {
  pcid="${choice}"

  pcidFolder=$(find "${LOGFOLDER}" -maxdepth 2 -type d | grep -i "${pcid}")

  if [ -z "${pcidFolder}" ]; then
    echo "No customers found with that PCID."
    sleep 1.5
    exit 1
  fi

  get_archive_list
}

function main() {
  choice=$(get_pcid ', or enter name to search for')
  if [ "${choice:0:2}" == 'ID' ]; then
    search_by_pcid
  else
    search_by_name
  fi
}

main
