#!/bin/bash

#check for root priveledges
if [ "$EUID" -ne 0 ];
	then echo "This script must be ran as root."
	exit
fi

#set Variables
echo "Setting up variables for checking commands ..."
STRESS=$(command -v stress)
TMUX=$(command -v tmux)
HTOP=$(command -v htop)
LSCPU=$(command -v lscpu)
SENSORS=$(command -v sensors)

echo "Downloading and setting stuff up. This may take a few minutes ..."
echo "The TMUX session containing the stress test will pull up when it is ready."

printf "Is sensors installed ..."
if [ ! $SENSORS ]; then
	echo " no"
	echo "Installing sensors now ..."
	sudo apt install sensors -yqq > /dev/null 2>/dev/null #if not installed
else echo " yes"
fi

printf "Is stress installed ..."
if [ ! $STRESS ]; then
	echo " no"
	echo "Installing stress now ..."
	sudo apt install stress -yqq > /dev/null 2>/dev/null #if not installed
else echo " yes"
fi

printf "Is TMUX installed ..."
if [ ! $TMUX ]; then
	echo " no"
	echo "Installing TMUX now ..."
	sudo apt install tmux -yqq  > /dev/null 2>/dev/null #if not installed
else echo " yes"
fi

printf "Is htop installed ..."
if [ ! $HTOP ]; then
	echo " no"
	echo "Installing htop now ..."
	sudo apt install htop -yqq > /dev/null 2>/dev/null #if not installed
else echo " yes"
fi

printf "Is lscpu installed ..."
if [ ! $LSCPU ]; then
	echo " no"
	sudo apt install lscpu -yqq > /dev/null 2>/dev/null #if not installed
else echo " yes"
fi

echo "Calculating number of cores ..."
cpuCores=$(lscpu -p | tail -n 1 | sed 's/,.*//')
cpuCores=$(expr $cpuCores + 1)

echo "Killing any existing cpu stress tmux sessions"
tmux kill-window -t cpuStress 2>/dev/null
##CHANGE TO DETECT IF WINDOW OPEN. IF SO LET KNOW AND EXIT
echo "Creating TMUX session and starting processes ..."
WATCH="watch 'sensors | awk /Core/'"
sudo -u $SUDO_USER tmux \
	new-window -d -n cpuStress \; \
	send-keys -t "GCC:cpuStress" "htop" ENTER \; \
	split-window -d -t "GCC:cpuStress" -h \; \
	send-keys -t "GCC:cpuStress.1" "stress -c $cpuCores" ENTER \; \
	split-window -d -t "GCC:cpuStress.1" -v \; \
	send-keys -t "GCC:cpuStress.1" "$WATCH" ENTER
exit
