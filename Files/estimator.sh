#!/bin/bash

#source commonFunctions
source "./Files/commonFunctions.source"

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

function display_banner() {
echo -e "${BANNER} __                   __                  "
echo "/__ |  _ |_  _  |    /   _ __ __  _ __  _|"
echo "\_| | (_)|_)(_| |    \__(_)||||||(_|| |(_|"
echo -e "${NORMAL}"
}

function get_user_id() {
#get id or option
get_pcid ", enter 'o' for other, or leave blank to not save"
}

#Display root menu
main_menu(){
        clear
        display_banner
        echo -e "${MENU}************************************************************************${NORMAL}"
        echo -e "${ENTER_LINE}  ************************* ESTIMATOR TOOL **************************${NORMAL}"
        echo -e "${MENU}************************************************************************${NORMAL}"
        echo -e "${MENU}**${NUMBER} 1)${MENUITEM} HDDs/SSDs ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 2)${MENUITEM} Laptop Screens ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 3)${MENUITEM} Services ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 4)${MENUITEM} Labor ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 5)${MENUITEM} Misc Item ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 6)${MENUITEM} Misc Service ${NORMAL}"
        echo -e "${MENU}**${NUMBER} 10)${MENUITEM} Exit Estimator Tool ${NORMAL}"
        echo -e "${MENU}***********************************************************************${NORMAL}"
        echo -e "${ENTER_LINE}Please enter a menu option. ${NORMAL}"
        read -p ': ' optMain

while true; do
  case "${optMain}" in
    1) clear;
      main_menu;
      ;;

    2) clear;
      main_menu;
      ;;

    3) clear;
      main_menu;
      ;;

    4) clear;
      main_menu;
      ;;

    5) clear;
      main_menu;
      ;;

    10) clear;
      break;
      ;;

    *)clear;
      main_menu;
      ;;
  esac
done
}

#Different SubMenus Seperate here

#add values together

#option to print

#maybe add to user info


function main(){
#  userChoice="$(get_user_id)"

  main_menu

echo after main menu
}

main
