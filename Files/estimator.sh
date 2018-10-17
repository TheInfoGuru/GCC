#!/bin/bash

#source commonFunctions
source "./Files/commonFunctions.source"
source "./Files/prices.source"

#First set values
TAX='.1'
BANNER=`echo "\033[1;37m"`
NORMAL=`echo "\033[m"`
MENU=`echo "\033[36m"` #Blue
MENUITEM=`echo "\033[1;36m"` #BrightBlue
NUMBER=`echo "\033[33m"` #yellow
FGRED=`echo "\033[41m"`
RED_TEXT=`echo "\033[31m"`
ENTER_LINE=`echo "\033[1;32m"` #bright green
INFO=`echo "\033[1;34m"` #blue
MENUTITLE=`echo "\033[1;35m"` #Bright Pink
LIGHTRED=`echo "\033[1;31m"`
############ESTIMATE FUNCTIONS###############
function add_hdd_service() {
  addHDDService=
  read -p 'Would you like to add H/W and OS install (Y/n): ' addHddService
  if [ "${addHddService,,}" != 'n' ]; then
    echo "${HARDWARE_INSTALL}" >> "${fileLocation}"
    echo "${OS_INSTALL}" >> "${fileLocation}"
    echo
    echo 'Install Service Added.'
  fi
}

function add_screen_service() {
  addScreenService=
  read -p 'Would you like to add screen install service (Y/n): ' addScreenService
  if [ "${addScreenService,,}" != 'n' ]; then
    echo "${SCREEN_INSTALL}" >> "${fileLocation}"
    echo
    echo 'Install Service Added.'
  fi
}

function add_motherboard_service() {
  addMotherboardService=
  read -p 'Would you like to add motherboard install service (Y/n): ' addMotherboardService
  if [ "${addMotherboardService,,}" != 'n' ]; then
    echo "${MOTHERBOARD_INSTALL}" >> "${fileLocation}"
    echo
    echo 'Install Service Added.'
  fi
}

function display_current_estimate() {
  if [ ! -s "${fileLocation}" ]; then
    echo "Estimate has not been started yet."
    echo "Please start the estimate first then try again."
    sleep 1.5
    return
  fi
  cat "${fileLocation}" | less;
}

function total_taxable_amount() {
  grep '@' "${fileLocation}" | awk '{print $1}' | cut -c 2- | numsum
}

function estimate_total() {
  estimateTotal=$(printf "%0.2f\n" $(echo $(python -c "import math;print(math.floor($(awk '{print $1}' ${fileLocation} | cut -c 2- | numsum) * 10 ** 2) / 10 ** 2)")))
  echo "\$${estimateTotal} ..... TOTAL" >> "${fileLocation}"
}

function tax_total() {
  taxTotal=$(printf "%0.2f\n" $(echo $(python -c "import math;print(math.floor(($(total_taxable_amount) * .1 + .005) * 10 ** 2) / 10 ** 2)")))
  echo "\$${taxTotal} ..... TAX" >> "${fileLocation}"
}

function delete_tax_total() {
  sed -i '/\(TAX\|TOTAL\)/d' "${fileLocation}"
}

function retotal() {
  delete_tax_total;
  tax_total;
  estimate_total;
  echo "Tax and total updated."
  sleep .5
}

function delete_estimate_item() {
  if [ ! -s "${fileLocation}" ]; then
    echo "Estimator file not started yet. No lines to delete."
    echo "Returning to Estimator Menu."
    sleep 2
    return
  fi
  echo
  cat -n "${fileLocation}" | grep -vE '(TAX|TOTAL)'
  echo
  echo 'Which lines would you like to delete?'
  read -ep 'Please seperate lines with a semicolon, no spaces (e.g. 1;3;4): ' lines
  if [ -z "${lines}" ]; then
    echo
    echo "Canceling line deletion."
    sleep 1
    return
  fi
  (
  echo "$lines" | tr \; \\n | while read linenum; do
    if [ "${linenum}" -gt "$(cat ${fileLocation} | grep -vE '(TAX|TOTAL)' | wc -l)" ]; then 
      echo
      echo "Line option was incorrect. Option out of scope."
      sleep 1
      clear
      exit 2
    fi
  done
  )
  if [ "$?" == '2' ]; then
    delete_estimate_item
  fi

  lines="$(echo ${lines} | sed 's/\;/d\;/g')"

  echo
  sed "${lines}d" "${fileLocation}" | grep -vE '(TAX|TOTAL)'
  echo

  writeChanges=
  read -p 'Is this the correct new estimate (y/N): ' writeChanges
  writeChanges="${writeChanges,,}"
  if [ "${writeChanges}" == 'y' ]; then
    sed -i "${lines}d" "${fileLocation}"
    retotal
  else
    echo "Canceling changes ..."
    sleep 1
    main_menu
  fi
}

##########INITIAL START FUNCTIONS###############
function get_user_id() {
  #get id or option
  echo "$(get_pcid ', enter a name to save in other folder, or leave blank to not save')"
}

function set_file_location() {
  if [ "${userChoice:0:2}" == 'ID' ]; then
    pcFolder=$(find "./Files/CustomerLogs" -maxdepth 2 -type d -name "${userChoice}")
    echo "${pcFolder}"
  elif [ -z "${userChoice}" ]; then
    echo "$(mktemp)"
  else
    pcFolder="$PWD/Files/CustomerLogs/Other/ESTIMATES"
    otherName=$(echo "${userChoice}" | tr -d ' ')
    echo "${PWD}/Files/CustomerLogs/Other/ESTIMATES/${otherName}"
  fi
}

function id_exist_check() {
  if [ ! "${folderLocation}" ]; then
    echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
    sleep 1
    exit 1
  fi

  if [ ! -f "${folderLocation}/log" ]; then
    echo "ERROR: PC NEEDS TO BE CHECKED IN BEFORE YOU CAN CHANGE ITS STATUS."
    echo "Please try again after checking PC in."
    sleep 1
    exit 1
  fi
}

###########BANNER FUNCTIONS################
function display_banner() {
  echo -e "${BANNER} __                   __                  "
  echo "/__ |  _ |_  _  |    /   _ __ __  _ __  _|"
  echo "\_| | (_)|_)(_| |    \__(_)||||||(_|| |(_|"
  echo -e "${NORMAL}"
}

function display_name_id() {
  name="$(echo ${fileLocation} | sed 's/.*CustomerLogs\/\(.*\)\?\/ID\?.*/\1/')"
  pcid="$(echo ${fileLocation} | sed 's/^.*\/\(ID\?.*\)\/.*$/\1/')"
  if [ -z "${userChoice}" ]; then
    name="Temp Estimate"
    pcid="No ID"
  elif [ "${userChoice:0:2}" != 'ID' ]; then
    name="$(echo ${fileLocation} | sed 's/^.*ESTIMATES\/\(.*$\)/\1/')"
    pcid="No ID"
  fi
  echo -e "${LIGHTRED}Customer Name: ${MENUTITLE}${name}${NORMAL}"
  echo -e "${LIGHTRED}PCID: ${MENUTITLE}${pcid}${NORMAL}"
}

##########CLEANUP FUNCTIONS################
function cleanup_and_exit() {
  if [ -z "${userChoice}" ]; then
    rm "${fileLocation}"
  fi
  exit 0
}

#################################ROOT ESTIMATE MENU############################################
function main_menu(){
#  trap "interrupt_reset; trap interrupt_reset INT" INT
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ************************** ESTIMATOR TOOL ****************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} HDDs/SSDs ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} Laptop Screens ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} Services & Labor ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} DC Jack ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 5)${MENUITEM} Motherboard ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 6)${MENUITEM} Misc Part ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 7)${MENUITEM} Misc Service ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 8)${MENUITEM} Discount ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 9)${MENUITEM} Delete Estimate Item ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 10)${MENUITEM} Display Current Estimate ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 11)${MENUITEM} Print Current Estimate ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 12)${MENUITEM} Erase Current Estimate ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 13)${MENUITEM} Part Price Lookup ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Exit Estimator Tool ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        hdd_main_menu;
        main_menu;
        ;;

      2) clear;
        screen_menu;
        main_menu;
        ;;

      3) clear;
        services_labor_menu;
        main_menu;
        ;;

      4) clear;
        dc_jack_choice;
        main_menu;
        ;;

      5) clear;
        part_choice 'y';
        main_menu;
        ;;

      6) clear;
        part_choice 'n';
        main_menu;
        ;;

      7) clear;
        misc_service_choice;
        main_menu;
        ;;

      8) clear;
        add_discount;
        main_menu;
        ;;

      9) clear;
        delete_estimate_item;
        main_menu;
        ;;

      10) clear;
        display_current_estimate;
        main_menu;
        ;;

      11) clear;
        print_current_estimate;
        main_menu;
        ;;

      12) clear;
        erase_current_estimate;
        main_menu;
        ;;

      13) clear;
        part_price_lookup;
        main_menu;
        ;;

      99) clear;
        cleanup_and_exit;
        ;;

      *)clear;
        main_menu;
        ;;
    esac
  done
}

##############################HDD MAIN MENU#########################################
function hdd_main_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ************************* HDD/SSD ESTIMATES **************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 2.5\" HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 3.5\" HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} SSD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        laptop_hdd_menu;
        ;;

      2) clear;
        desktop_hdd_menu;
        ;;

      3) clear;
        ssd_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        hdd_main_menu;
        ;;
    esac
  done
}

############################LAPTOP HDD MENU###################################
function laptop_hdd_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} **************************** 2.5\" HDDs *******************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 80GB HDD${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 160GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 250GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 320GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 5)${MENUITEM} 500GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 6)${MENUITEM} 1TB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 7)${MENUITEM} 2TB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to HDD Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${LAPTOP_80GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${LAPTOP_160GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${LAPTOP_250GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        echo "${LAPTOP_320GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      5) clear;
        echo "${LAPTOP_500GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      6) clear;
        echo "${LAPTOP_1TB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      7) clear;
        echo "${LAPTOP_2TB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        hdd_main_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        laptop_hdd_menu;
        ;;
    esac
  done
}

#################SSD MENU#####################
function ssd_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ******************************* SSDs *********************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 120GB SSD${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 240GB SSD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 500GB SSD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 1TB SSD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to HDD Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${SSD_120GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${SSD_240GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${SSD_500GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        echo "${SSD_1TB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        hdd_main_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        ssd_menu;
        ;;
    esac
  done
}

############################DESKTOP HDD MENU###################################
function desktop_hdd_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ******************************* 3.5\" HDDs ****************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 80GB HDD${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 160GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 250GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 320GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 5)${MENUITEM} 500GB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 6)${MENUITEM} 1TB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 7)${MENUITEM} 2TB HDD ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to HDD Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${DESKTOP_80GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${DESKTOP_160GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${DESKTOP_250GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        echo "${DESKTOP_320GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      5) clear;
        echo "${DESKTOP_500GB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      6) clear;
        echo "${DESKTOP_1TB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      7) clear;
        echo "${DESKTOP_2TB}" >> "${fileLocation}";
        add_hdd_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        hdd_main_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        desktop_hdd_menu;
        ;;
    esac
  done
}

##############################SCREEN MENU######################################
function screen_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ******************************** Screens *****************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 10.1\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 11.6\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 13.3\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 14\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 5)${MENUITEM} 15.4\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 6)${MENUITEM} 15.6\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 7)${MENUITEM} 16\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 8)${MENUITEM} 17.1\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 9)${MENUITEM} 17.3\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${SCREEN_101}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${SCREEN_116}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${SCREEN_133}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        14_screen_menu;
        ;;

      5) clear;
        echo "${SCREEN_154}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      6) clear;
        156_screen_menu;
        ;;

      7) clear;
        echo "${SCREEN_16}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      8) clear;
        echo "${SCREEN_171}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      9) clear;
        173_screen_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        screen_menu;
        ;;
    esac
  done
}

function 14_screen_menu() {
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ****************************** 14\" Screens ***************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 14\" LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 14\" Slim 40pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 14\" Slim 30pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to Screen Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${SCREEN_14}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${SCREEN_14_SLIM_40PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${SCREEN_14_SLIM_30PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        screen_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        14_screen_menu;
        ;;
    esac
  done
}

function 156_screen_menu() {
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ***************************** 15.6\" Screens **************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 15.6\" 40pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 15.6\" 30pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 15.6\" Slim 40pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 15.6\" Slim 30pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to Screen Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${SCREEN_156_40PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${SCREEN_156_30PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${SCREEN_156_SLIM_40PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        echo "${SCREEN_156_SLIM_30PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        screen_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        156_screen_menu;
        ;;
    esac
  done
}

function 173_screen_menu() {
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} ***************************** 17.3\" Screens **************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} 17.3\" 40pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} 17.3\" 30pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} 17.3\" Slim 40pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} 17.3\" Slim 30pin LED Screen${NORMAL}"
  echo -e "${MENU}**${NUMBER} 98)${MENUITEM} Return to Screen Main Menu ${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${SCREEN_173_40PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      2) clear;
        echo "${SCREEN_173_30PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      3) clear;
        echo "${SCREEN_173_SLIM_40PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      4) clear;
        echo "${SCREEN_173_SLIM_30PIN}" >> "${fileLocation}";
        add_screen_service;
        retotal;
        main_menu;
        ;;

      98) clear;
        screen_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        156_screen_menu;
        ;;
    esac
  done

}

##############################SERVICES LABOR MENU####################################
function services_labor_menu(){
  clear
  display_banner
  display_name_id
  echo
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${ENTER_LINE} *************************** Services & Labor *************************${NORMAL}"
  echo -e "${MENU}************************************************************************${NORMAL}"
  echo -e "${MENU}**${NUMBER} 1)${MENUITEM} OS Installation/Reinstallation${NORMAL}"
  echo -e "${MENU}**${NUMBER} 2)${MENUITEM} Data Recovery${NORMAL}"
  echo -e "${MENU}**${NUMBER} 3)${MENUITEM} Optimization${NORMAL}"
  echo -e "${MENU}**${NUMBER} 4)${MENUITEM} Virus Removal${NORMAL}"
  echo -e "${MENU}**${NUMBER} 5)${MENUITEM} Optimization & Virus Removal${NORMAL}"
  echo -e "${MENU}**${NUMBER} 6)${MENUITEM} Hardware Installation${NORMAL}"
  echo -e "${MENU}**${NUMBER} 7)${MENUITEM} Motherboard Installation${NORMAL}"
  echo -e "${MENU}**${NUMBER} 8)${MENUITEM} Software Installation${NORMAL}"
  echo -e "${MENU}**${NUMBER} 9)${MENUITEM} Printer Setup${NORMAL}"
  echo -e "${MENU}**${NUMBER} 10)${MENUITEM} Clone HDD/SSD${NORMAL}"
  echo -e "${MENU}**${NUMBER} 11)${MENUITEM} Laptop Screen Installation${NORMAL}"
  echo -e "${MENU}**${NUMBER} 99)${MENUITEM} Return to Estimator Main Menu ${NORMAL}"
  echo -e "${MENU}***********************************************************************${NORMAL}"
  echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
  read -p ': ' optMain

  while true; do
    case "${optMain}" in
      1) clear;
        echo "${OS_INSTALL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      2) clear;
        echo "${DATA_RECOVERY}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      3) clear;
        echo "${OPTIMIZATION}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      4) clear;
        echo "${VIRUS_REMOVAL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      5) clear;
        echo "${OPT_VIRUS_COMBO}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      6) clear;
        echo "${HARDWARE_INSTALL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      7) clear;
        echo "${MOTHERBOARD_INSTALL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      8) clear;
        echo "${SOFTWARE_INSTALL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      9) clear;
        echo "${PRINTER_SETUP}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      10) clear;
        echo "${CLONE_HDD}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      11) clear;
        echo "${SCREEN_INSTALL}" >> "${fileLocation}";
        retotal;
        services_labor_menu;
        ;;

      99) clear;
        main_menu;
        ;;

      *)clear;
        services_labor_menu;
        ;;
    esac
  done
}


###########################ADD DISCOUNT#####################################
function add_discount() {
  price=
  description=
  word='disount'

  while [ -z "${price}" ]; do
    echo
    read -ep "Enter customer price for ${word}: " price
    echo
    case "${price}" in
      ''|*[!0-9]*) echo "Incorrect response. Please check your input and try again";
        price=
        sleep 1;
        ;;
    esac
  done

  price=$(printf "%0.2f\n" $(echo $(python -c "import math;print(math.floor(${price} * 10 ** 2) / 10 ** 2)")))

  while [ -z "${description}" ]; do
    read -ep "Enter ${word} description: " description
    if [ -z "${description}" ]; then
      echo
      echo "You cannot leave this field blank. Please try again."
      echo
    fi
  done

  echo "\$-${price} ..... ${description}"  >> "${fileLocation}"
  echo

  retotal
  main_menu
}

############################DC JACK CHOICE####################################
function dc_jack_choice() {
  echo
  dcJackType=
  read -p 'Is DC Jack solder-on or plug-in (s/P): ' dcJackType
  if [ "${dcJackType,,}" != 's' -a "${dcJackType,,}" != 'p' -a -n "${dcJackType}" ]; then
    echo
    echo "You made an incorrect choice. Please try again."
    sleep 1
    clear
    dc_jack_choice
  fi
  if [ "${dcJackType,,}" == 's' ]; then
    dcJackPrice='145.00'
  else
    dcJackPrice='125.00'
  fi
  echo
  read -ep 'Enter DC Jack model number: ' dcJackModel
  echo
  read -ep 'Enter DC Jack Description: ' dcJackDescription
  echo
  shortLinkAnswer=
  read -p 'Add shortlink to part search ([e]bay|[a]mazon|[B]oth|[n]either): ' shortLinkAnswer

  keyword="$(echo ${dcJackModel} | sed 's/ /\%20/g')"
  ebayURL="https://www.ebay.com/sch/i.html?_nkw=${keyword}"
  ebayShortlink=$(curl -s "http://api.bit.ly/v3/shorten?login=computerresourceal&apiKey=R_c2c075a7331c48c1ab93ba6ed79cdc9b&longURL=${ebayURL}&format=txt")
  amazonURL="https://www.amazon.com/s/field-keywords=${keyword}"
  amazonShortlink=$(curl -s "http://api.bit.ly/v3/shorten?login=computerresourceal&apiKey=R_c2c075a7331c48c1ab93ba6ed79cdc9b&longURL=${amazonURL}&format=txt")

  if [ "${shortLinkAnswer,,}" == 'n' ]; then
    echo "\$${dcJackPrice} ..... ${dcJackDescription} | Model: ${dcJackModel}" >> "${fileLocation}"
  elif [ "${shortLinkAnswer,,}" == 'e' ]; then
    echo "\$${dcJackPrice} ..... ${dcJackDescription} | Model: ${dcJackModel} | ${ebayShortlink}" >> "${fileLocation}"
  elif [ "${shortLinkAnswer,,}" == 'a' ]; then
    echo "\$${dcJackPrice} ..... ${dcJackDescription} | Model: ${dcJackModel} | ${amazonShortlink}" >> "${fileLocation}"
  else
    echo "\$${dcJackPrice} ..... ${dcJackDescription} | Model: ${dcJackModel} | ${ebayShortlink} | ${amazonShortlink}" >> "${fileLocation}"
  fi

  retotal
  main_menu
}

#####################MISC PART & Motherboard#################################
function part_choice() {
  performLookup=
  model=
  price=
  description=
  shortLinkAnswer=

  isMobo="${1}"

  if [ "${isMobo,,}" == 'y' ]; then
    word='motherboard'
  else
    word='part'
  fi

  echo
  read -p 'Do you wish to perform part lookup first (y/N): ' performLookup

  while [ -z "${model}" ]; do
    echo
    read -ep "Enter ${word} model number: " model
    if [ -z "${model}" ]; then
      echo
      echo "You cannot leave this field blank. Try again."
    fi
  done

  if [ "${performLookup,,}" == 'y' ]; then
    part_price_lookup "${model}"
  fi

  while [ -z "${price}" ]; do
    echo
    read -ep "Enter customer price for ${word}: " price
    echo
    if [[ "${price}" != +([0-9])?(.)?([0-9])?([0-9]) ]]; then
      echo 'Incorrect response. Please check your input and try again.'
      price=
    fi
  done

  price=$(printf "%0.2f\n" $(echo $(python -c "import math;print(math.floor(${price} * 10 ** 2) / 10 ** 2)")))

  while [ -z "${description}" ]; do
    read -ep "Enter ${word} description: " description
    if [ -z "${description}" ]; then
      echo
      echo "You cannot leave this field blank. Please try again."
      echo
    fi
  done

  echo
  read -p 'Add shortlink to part results ([e]bay|[a]mazon|[B]oth|[n]either): ' shortLinkAnswer

  keyword="$(echo ${model} | sed 's/ /\%20/g')"
  ebayURL="https://www.ebay.com/sch/i.html?_nkw=${keyword}"
  ebayShortlink=$(curl -s "http://api.bit.ly/v3/shorten?login=computerresourceal&apiKey=R_c2c075a7331c48c1ab93ba6ed79cdc9b&longURL=${ebayURL}&format=txt")
  amazonURL="https://www.amazon.com/s/field-keywords=${keyword}"
  amazonShortlink=$(curl -s "http://api.bit.ly/v3/shorten?login=computerresourceal&apiKey=R_c2c075a7331c48c1ab93ba6ed79cdc9b&longURL=${amazonURL}&format=txt")

  if [ "${shortLinkAnswer,,}" == 'n' ]; then
    echo "\$${price} ..... ${description} | Model: ${model} @"  >> "${fileLocation}"
  elif [ "${shortLinkAnswer,,}" == 'e' ]; then
    echo "\$${price} ..... ${description} | Model: ${model} | ${ebayShortlink} @" >> "${fileLocation}"
  elif [ "${shortLinkAnswer,,}" == 'a' ]; then
    echo "\$${price} ..... ${description} | Model: ${model} | ${amazonShortlink} @" >> "${fileLocation}"
  else
    echo "\$${price} ..... ${description} | Model: ${model} | ${ebayShortlink} | ${amazonShortlink} @" >> "${fileLocation}"
  fi
  echo

  if [ "${isMobo,,}" == 'y' ]; then
    add_motherboard_service
  fi
  retotal
  main_menu
}

#####################MISC SERVICE############################
function misc_service_choice() {
  price=
  description=

  word='service'

  while [ -z "${price}" ]; do
    echo
    read -ep "Enter customer price for ${word}: " price
    echo
    case "${price}" in
      ''|*[!0-9]*) echo "Incorrect response. Please check your input and try again";
        price=
        sleep 1;
        ;;
    esac
  done

  price=$(printf "%0.2f\n" $(echo $(python -c "import math;print(math.floor(${price} * 10 ** 2) / 10 ** 2)")))

  while [ -z "${description}" ]; do
    read -ep "Enter ${word} description: " description
    if [ -z "${description}" ]; then
      echo
      echo "You cannot leave this field blank. Please try again."
      echo
    fi
  done

  echo "\$${price} ..... ${description}"  >> "${fileLocation}"
  echo

  retotal
  main_menu
}

###################DELETE CURRENT ESTIMATE######################
function erase_current_estimate() {
  if [ ! -s "${fileLocation}" ]; then
    echo "Estimate has not been started yet."
    echo "Please start the estimate first then try again."
    sleep 1.5
    return
  fi
  echo "You are about to erase the current estimate."
  read -p 'ARE YOU SURE YOU WANT TO CONTINUE (y/N): ' deleteAnswer
  echo

  if [ "${deleteAnswer,,}" == 'y' ]; then
    rm "${fileLocation}"
    echo "Estimate file erased."
    sleep 1
  else
    echo "Canceling estimate erase."
    sleep 1
  fi
}

######################PART PRICE LOOKUP##########################
function part_price_lookup() {

  searchKeyword="${1}"

  if [ -z "${searchKeyword}" ]; then
    read -ep 'Enter the model number to lookup: ' searchKeyword
  fi

  echo
  echo 'AMAZON PART CHECK'
  echo '------------------'
  amzsear -d "$searchKeyword" | head -7
  echo
  echo 'EBAY PART CHECK'
  echo '----------------'
  ebsear "$searchKeyword" -d | head -7
  echo

  if [ -z "${1}" ]; then
    read -p '---Press enter when finished---' nul
  fi
}

##########PRINT FUNCTION#################
function print_current_estimate() {
  if [ ! -s "${fileLocation}" ]; then
    echo "Estimate has not been started yet."
    echo "Please start the estimate first then try again."
    sleep 1.5
    return
  fi

  read -ep 'Enter description for title of estimate: ' estimateTitle
  printFile=$(mktemp)
  echo "${estimateTitle}" >> "${printFile}"
  echo "Estimate Created On $(today_date)" >> "${printFile}"
  echo >> "${printFile}"
  cat "${fileLocation}" >> "${printFile}"
  LPR "${printFile}"
  rm "${printFile}"
}

function LPR() {
  [ ! $(command -v enscript) ] && echo "Installing enscript. Please wait." && $(sudo apt install -qqy enscript)
  ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
  export ENSCRIPT
  /usr/bin/enscript -p - ${1} | /usr/bin/lpr
}

##############MAIN################
function main(){
  userChoice="$(get_user_id)"
  if [ "${userChoice:0:2}" == 'ID' ]; then
    folderLocation="$(set_file_location)"
    fileLocation="${folderLocation}/estimate"
  else
    fileLocation="$(set_file_location)"
  fi

  if [ "${userChoice:0:2}" == 'ID' ]; then
    id_exist_check
  fi

  main_menu
}

main
