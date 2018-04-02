#!/bin/bash

LPR() {
#[ ! command -v enscript ] && echo "Installing enscript. Please wait." && sudo apt install -qqy enscript
ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
export ENSCRIPT
/usr/bin/enscript -p - $1 | /usr/bin/lpr
}


clean_up() {
	rm $TRACKERFILEFILTER 2> /dev/null
	rm $TRACKERFILE 2> /dev/null
	rm $PRINTFILE 2> /dev/null

}
PRINTFILE=$(mktemp)
TRACKERFILE=$(mktemp)
GREP="(A[1-7]|B[1-3]|C[1-7]|D1|E[1-2]|Front Counter|[1-3] Bench)"
for i in $(find ./* -maxdepth 6 -type f -name 'log'); do
	PCFOLDER=$(echo "${i%/*}")
	CUSFOLDER=$(echo "${PCFOLDER%/*}")
	CUSNAME=$(cat "$CUSFOLDER/info.cus" | head -n 1)
	PCID=$(echo "$PCFOLDER" | grep -Eo "ID[0-9]?[0-9]?[0-9]?[0-9]")
	LOCATION=$(cat "$PCFOLDER/location")
	PCSTATUS=$(cat "$PCFOLDER/status")
	CHKINDATE=$(cat "$PCFOLDER/check_in")
	CONTACTSTATUS=$(cat "$PCFOLDER/contactStatus")
	echo "$CUSNAME*$PCID*$LOCATION*$PCSTATUS*$CHKINDATE*$CONTACTSTATUS" >> "$TRACKERFILE"
done

echo >> "$PRINTFILE"
echo "  Customer Name*PC ID*Location*Status*Check-In Date*Contact Status" >> "$PRINTFILE"
echo "--------------------------*    ----------*  ----------------*---------------------*    -----------------*   ---------------------" >> "$PRINTFILE"

declare -i j=1
declare -i k=1
declare -i l=1
declare -i m=1
declare -i n=1

#For A Shelf
while [ $j -lt '8' ]; do
	grep "A$j" "$TRACKERFILE" >> "$PRINTFILE"
	j+=1
done

#For B Shelf
while [ $k -lt '4' ]; do
	grep "B$k" "$TRACKERFILE" >> "$PRINTFILE"
	k+=1
done

#For C Shelf
while [ $l -lt '8' ]; do
	grep "C$l" "$TRACKERFILE" >> "$PRINTFILE"
	l+=1
done

#For D Shelf
grep "D1" "$TRACKERFILE" >> "$PRINTFILE"

#For E Shelf
while [ $m -lt '3' ]; do
	grep "E$m" "$TRACKERFILE" >> "$PRINTFILE"
	m+=1
done

#For Front Counter Shelf
grep "Front Counter" "$TRACKERFILE" >> "$PRINTFILE"

#For Work Benches
while [ $n -lt '4' ]; do
	grep "$n Bench" "$TRACKERFILE" >> "$PRINTFILE"
	n+=1
done

#For Any Other Location
grep -vE "$GREP" "$TRACKERFILE" >> "$PRINTFILE"


column -s '*' -t "$PRINTFILE" | LPR
clean_up
