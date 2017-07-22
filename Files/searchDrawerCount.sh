#!/bin/bash

echo "Enter the date you wish to search for."
echo "Format it exactly as first 3 letters of the month then day and year."
echo "Example: Sep 10 2018"
read -p ': ' cdate

cat $PWD/DrawerCounts | awk /"$cdate"/,/"###########################################################"/ | less

if [ $? -ne 0 ]; then
	echo "No entry found."
	echo "Either date was typed in the wrong format, or there isn't an entry on that day."
	echo "Press enter to exit."
	read nul
	exit 1
fi

exit 0
