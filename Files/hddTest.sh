#!/bin/bash

SMARTCTL=$(command -v smartctl)

RED_TEXT=`echo "\033[1;31m"`
BLUE_TEXT=`echo "\033[1;36m"`
GREEN_TEXT=`echo "\033[1;32m"`
YELLOW_TEXT=`echo "\033[33m"`
CYAN_TEXT=`echo "\033[1;34m"`
NORMAL=`echo "\033[m"`

if [ ! $SMARTCTL ]; then
	echo "Downloading smartctl. Please wait."
	sudo apt install smartmontools -qq > /dev/null 2>/dev/null
fi

echo -e "${YELLOW_TEXT}*****************************************************${NORMAL}${BLUE_TEXT}"
lsblk
echo -e "${NORMAL}${YELLOW_TEXT}*****************************************************${NORMAL}"
echo -e "Enter only the BLK name, i.e. sda sdb sdc etc!!!"
printf "Please enter the BLK device you would like to test: ${GREEN_TEXT}"
read hddID
echo -e "${NORMAL}"
lsblk | grep -i "$hddID" > /dev/null
if [ $? -ne 0 ]; then
	echo -e "${RED_TEXT}You have selected a nonexistent BLK device. Exiting in 10 seconds.${NORMAL}"
	sleep 10
	exit
fi
printf "Would you like to run a ${BLUE_TEXT}(s)${NORMAL}hort test, a ${BLUE_TEXT}(l)${NORMAL}ong test, or ${BLUE_TEXT}(n)${NORMAL}o test: ${GREEN_TEXT}"
read ANSWER1
echo -e "${NORMAL}"

if [ "$ANSWER1" == "s" ] || [ "$ANSWER1" == "S" ]; then
	sudo smartctl -t short /dev/$hddID | grep -i 'device lacks smart capability'> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${RED_TEXT}This device does not support SMART. Exiting in 10 seconds.${NORMAL}"
		sleep 10
		exit
	fi
	clear
	echo -e "${GREEN_TEXT}Running short test on ${RED_TEXT}$hddID${GREEN_TEXT}. Please wait ~2 minutes."
	echo -e "Log will pull up automatically after finished running.${NORMAL}"
	while (sleep 5;sudo smartctl -a /dev/$hddID | grep -i 'of test remaining.' >/dev/null); do
		if [ $? -ne 0 ]; then
			break
		fi
		clear
		echo -e "${GREEN_TEXT}Running short test on ${RED_TEXT}$hddID${GREEN_TEXT}. Please wait ~2 minutes."
		echo -e "Log will pull up automatically after finished running.${NORMAL}"
		echo
		testRemaining=$(sudo smartctl -a /dev/$hddID | grep -i 'test remaining' | awk '{print $1,$2,$3,$4}')
		echo -e "${CYAN_TEXT}There is approximately $testRemaining ${NORMAL}"
	done
	sudo smartctl -a /dev/$hddID | less
elif [ "$ANSWER1" == "l" ] || [ "$ANSWER1" == "L" ]; then
	sudo smartctl -t long /dev/$hddID | grep -i 'device lacks smart capability'> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${RED_TEXT}This device does not support SMART. Exiting in 10 seconds.${NORMAL}"
		sleep 10
		exit
	fi
	clear
	echo -e "${GREEN_TEXT}Running long test on ${RED_TEXT}$hddID${GREEN_TEXT}. This test may take multiple hours."
	echo -e "Log will pull up automatically after finished running.${NORMAL}"
	while (sleep 5;sudo smartctl -a /dev/$hddID | grep -i 'of test remaining.' >/dev/null); do
		if [ $? -ne 0 ]; then
			break
		fi
		clear
		echo -e "${GREEN_TEXT}Running long test on ${RED_TEXT}$hddID${GREEN_TEXT}. This test may take multiple hours."
		echo -e "Log will pull up automatically after finished running.${NORMAL}"
		echo
		testRemaining=$(sudo smartctl -a /dev/$hddID | grep -i 'test remaining' | awk '{print $1,$2,$3,$4}')
		echo -e "${CYAN_TEXT}There is approximately $testRemaining ${NORMAL}"
	done
	sudo smartctl -a /dev/$hddID | less
else 
	sudo smartctl -a /dev/$hddID | grep -i 'device lacks smart capability'> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "${RED_TEXT}This device does not support SMART. Exiting in 10 seconds.${NORMAL}"
		sleep 10
		exit
	fi
	sudo smartctl -a /dev/$hddID | less
fi
