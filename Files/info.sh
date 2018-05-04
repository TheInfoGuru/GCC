#!/bin/bash

#source sourcefile
source ./Files/commonFunctions.source

#set adapter variable
ADAPTER=$(ifconfig -a | grep -B 1 -i "inet addr" | grep -i 'enp' | awk {'print $1'})

#check for root priveledges
if [ "$(root_check)" == 'n' ]; then
  echo "This script must be ran as root."
  exit
fi

#check prerequisite programs
check_programs() {
  netUp=$(internet_check)

  if [ ! $(which smartctl) ]; then
    if [ "$netUp" == 'y' ]; then
      echo 'Installing smartmontools. Please wait a moment ...'
      sudo apt-get install -qqy smartmontools > /dev/null 2>/dev/null #if not install it
    else
      echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 2 SECONDS$(tput sgr0)"
      sleep 2
      exit 1
    fi
  fi

  if [ ! $(which acpi) ]; then
    if [ "$netUp" == 'y' ]; then
      echo 'Installing ACPI. Please wait a moment ...'
      sudo apt-get install -qqy acpi > /dev/null 2>/dev/null #if not install it
    else
      echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 2 SECONDS$(tput sgr0)"
      sleep 2
      exit 1
    fi
  fi

  if [ ! $(which sensors) ]; then
    if [ "$netUp" == 'y' ]; then
      echo 'Installing sensors. Please wait a moment ...'
      sudo apt-get install -qqy sensors > /dev/null 2>/dev/null #if not install it
    else
      echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 2 SECONDS$(tput sgr0)"
      sleep 2
      exit 1
    fi
  fi

  if [ ! $(which hivexget) ]; then
    if [ "$netUp" == 'y' ]; then
      echo 'Installing hivexget. Please wait a moment ...'
      sudo apt-get install -qqy libhivex-bin > /dev/null 2>/dev/null #if not install it
    else
      echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 2 SECONDS$(tput sgr0)"
      sleep 2
      exit 1
    fi
  fi
}

#make the report
make_report() {
  [ "${getHddInfo}" != 'n' ] && run_hdd_sst
  clear
  echo 'Gathering info about this computer. This may take a few moments.'
  set_save_location
  make_note_header
  get_system_info
  get_cpu_info
  [ "${skipWindowsStuff,,}" != 'y' ] && get_windows_info
  get_mac_address
  [ "$(ls -A /sys/class/power_supply)" ] && get_battery_health
  get_ram_info
  [ "${checkUserData,,}" != 'n' ] && get_data_size
  [ "${getHddInfo,,}" != 'n' ] && get_hdd_info
}

#run the hdd test
run_hdd_sst() {
  sudo smartctl -t short /dev/${hddBLKID} > /dev/null 2>&1
}

#set the save location
set_save_location() {
  #Make sure Customer Logs share is mounted
  if [ "${pcID}" == "o" ]; then
    pcFolder="$PWD/Files/CustomerLogs/Other"
    otherName=$(echo "${otherName}" | tr -d ' ')
    saveLocation="${PWD}/Files/CustomerLogs/Other/${otherName}"
  else
    pcFolder=$(find "./Files/CustomerLogs" -maxdepth 2 -type d -name "${pcID}")
    saveLocation="${pcFolder}/info"
  fi
}

#make header for info note
make_note_header() {
  echo '///////////////////////////////////////////////////////////START OF INFO\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' >> "${saveLocation}"
  echo >> "${saveLocation}"
  echo "Info was grabbed on $(today_date)" >> "${saveLocation}"
  echo >> "${saveLocation}"
}

#get system info
get_system_info() {
  echo "----------------PC Info----------------" >> "${saveLocation}"
  echo 'Getting system manufacturer ...'
  echo "Computer Manufacturer .  .  .  . . $(cat /sys/devices/virtual/dmi/id/sys_vendor)" >> "${saveLocation}"
  echo 'Getting current computer model ...'
  echo "Computer Model . . . . . . . . . . $(cat /sys/devices/virtual/dmi/id/product_name)" >> "${saveLocation}"
  echo 'Getting serial number ...'
  echo "Computer Serial Number . . . . . . $(cat /sys/devices/virtual/dmi/id/product_serial)" >> "${saveLocation}"
}

#getting CPU info
get_cpu_info() {
  echo 'Getting CPU info ...'
  echo "Computer CPU . . . . . . . . . . . $(echo $(cat /proc/cpuinfo | grep -m 1 -i 'model name' | sed 's/.*: //' | sed 's:  \+: :' ) - $(grep -c 'processor' /proc/cpuinfo) Cores)" >> "${saveLocation}"
  echo 'Getting snapshot of CPU temp ...'
  echo "CPU temp is  . . . . . . . . . . . $(sensors | grep -m 1 -i 'Core 0:' | sed 's/.*://' | awk '{print $1}')" >> "${saveLocation}"
}

#get windows info
get_windows_info() {
  echo 'Trying to get BIOS WinKey ...'
  echo "Windows Bios Key . . . . . . . . . $([ -f /sys/firmware/acpi/tables/MSDM ] && strings /sys/firmware/acpi/tables/MSDM | tail -n 1)" >> "${saveLocation}"
  echo 'Getting Windows version ...'
  echo "Windows Version  .  .  .  .  .  .  $(get_windows_version ${windowsMountLocation})" >> "${saveLocation}"
}

#for getting mac address
get_mac_address() {
  echo >> "${saveLocation}"
  echo 'Getting MAC address ...'
  echo "MAC Address is $(ip addr | grep link/ether | awk '{print $2}' | tr "\n" " ")" >> "${saveLocation}"
  echo >> "${saveLocation}"
}

#get battery health
get_battery_health() {
  echo "Getting battery health ..."
  echo "Estimate Battery health is $(acpi -i | grep -v 'charg' | awk '{print $13}' | tr -d '\n')" >> "${saveLocation}"
  echo >> "${saveLocation}"
}

#get info about ram and amount
get_ram_info() {
  echo 'Calculating approximate RAM amount ...'
  echo "Approximate amount of system memory is $(free -h | grep 'Mem:' | awk '{print $2}')." >> "${saveLocation}"
  echo >> "${saveLocation}"
}

#get size of user data
get_data_size() {
  echo 'Trying to calculate approximate user data size ...'
  echo "Approximate size of user data is $(du -sh ${windowsMountLocation}/Users/ 2> /dev/null | awk '{print $1}')." >> "${saveLocation}"
  echo >> "${saveLocation}"
}

#get size of hdd
get_hdd_info() {
  #make temp file with smart data in it
  smartReport=$(mktemp)
  sudo smartctl -a /dev/${hddBLKID} >> "${smartReport}"
  #get HDD size
  echo 'Getting HDD size ...'
  echo "--------------HDD section--------------" >> "${saveLocation}"
  echo "HDD size:        $(cat ${smartReport} | grep -i 'User Capacity:' | awk '{print $5, $6}')" | tr "[]" " " >> "${saveLocation}"
  #get HDD model
  echo 'Getting HDD model ...'
  cat "${smartReport}" | grep 'Device Model' >> "${saveLocation}"
  echo >> "${saveLocation}"
  #get HDD smart pass/fail
  echo 'Getting SMART pass/fail ...'
  cat "${smartReport}" | grep 'test result' >> "${saveLocation}"
  echo >> "${saveLocation}"
  #display error found warning
  if [ ! "$(cat ${smartReport} | grep -i 'no errors logged')" ]; then
    echo "THERE ARE ERRORS FOUND IN THE LOG!" >> "${saveLocation}"
    echo >> "${saveLocation}"
  fi
  #get chosen smart attributes
  echo 'Getting SMART attributes ...'
  cat "${smartReport}" | grep -iE '(Raw_Read_Error_Rate|Reallocated_sector|Reported_Uncorrec|spin_retry|power_on|power_cycle|Current_Pending_Sector|Uncorrectable_Error_Cnt|Offline_Uncorrectable)' | awk '{ print $10, "\t", $2 }' >> "${saveLocation}"
  echo

  if [ "sudo smartctl -a /dev/${hddBLKID} | grep -i 'test remaining.' > /dev/null" ]; then
    #display if waiting on hdd test
    echo "Waiting for short HDD smart test to run. Average is 2 minutes."
    echo "Log will be pulled up after running."
    while sudo smartctl -a /dev/${hddBLKID} | grep -i 'test remaining.' > /dev/null; do
      sleep 5
    done
  fi

  echo >> "${saveLocation}"	# We need a blank line for pretty printing
  echo "Here are the last five SMART test results:" >> "${saveLocation}"
  echo >> "${saveLocation}"
  sudo smartctl -l selftest /dev/${hddBLKID} | grep -E '(Test_Description|# 1|# 2|# 3|# 4|# 5)' >> "${saveLocation}"	# show results
  echo >> "${saveLocation}"
}

main() {
  #clear the screen
  clear

  check_programs

  #get pcid from user
  pcID=$(get_pcid ", or type (o) for noncustomer PC")

  #if noncustomer name file
  if [ "${pcID}" == 'o' ]; then
    read -p 'Enter a name for this file (will be located under Other in Customer Logs): ' otherName
  fi

  #Get input from user if they want tests done
  echo
  read -p 'Do you wish to get hdd info (Y/n): ' getHddInfo
  echo
  read -p 'Do you want to get user data size (Y/n): ' checkUserData
  echo
  read -p 'Do you want to skip Windows stuff (y/N): ' skipWindowsStuff

  #clear screen for info
  clear

  #If need windows location, mount and get it
  if [ "${skipWindowsStuff,,}" != 'y' -o ! "${checkUserData,,}" != 'n' ]; then
    echo #added for readability
    windowsMountLocation="$(mount_windows ro)"
  fi

  if [ "${getHddInfo,,}" != 'n' ]; then
    if [ -z "${windowsMountLocation}" ]; then
      #get hdd blkid
      echo 'Choose the hdd to test.'
      echo
      hddBLKID=$(choose_blkid h)
    else
      hddBLKID=$(mount | grep "${windowsMountLocation}" | awk '{print $1}' | sed 's/.*\/\(.*\)[0-9]\+/\1/')
    fi
  fi

  #start actually making report
  make_report

  #cuz fuck
  chmod 777 "${saveLocation}"

  if [ ! "${pcID}" == "o" ]; then
    sudo echo "Y" > "${pcFolder}/ranLogs"
  fi

  #Show log
  cat "${saveLocation}" | less
}

main
exit 0
