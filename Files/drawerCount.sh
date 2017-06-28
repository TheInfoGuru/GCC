#!/bin/bash
clear

STORELOCATION="/home/emanruoy/.current_drawer"

start_count() {
echo '*******************************************************'
read -p 'Please enter number of 20s in drawer: ' BEGTWENTY
read -p 'Please enter number of 10s in drawer: ' BEGTEN
read -p 'Please enter number of 5s in drawer: ' BEGFIVE
read -p 'Please enter number of 1s in drawer: ' BEGONE
echo
TWENTYTOTAL=$(expr $BEGTWENTY \* 20)
TENTOTAL=$(expr $BEGTEN \* 10)
FIVETOTAL=$(expr $BEGFIVE \* 5)
ONETOTAL=$(expr $BEGONE \* 1)
BEGBAL=$(expr $TWENTYTOTAL + $TENTOTAL + $FIVETOTAL + $ONETOTAL)
echo "Your beginning drawer balance is: $BEGBAL"
echo '*******************************************************'

DATE=$(date | awk '{print $2, $3, $6}')

echo "****************$DATE****************" >> $STORELOCATION
echo '======= BEGINNING DRAWER =======' >> $STORELOCATION
echo "Number of Twenties . . . . $BEGTWENTY" >> $STORELOCATION
echo "Number of Tens . . . . . . $BEGTEN" >> $STORELOCATION
echo "Number of Fives . . . . . .$BEGFIVE" >> $STORELOCATION
echo "Number of Ones . . . . . . $BEGONE" >> $STORELOCATION
echo >> $STORELOCATION
echo "Beginning Drawer Balance" >> $STORELOCATION
echo "$BEGBAL" >> $STORELOCATION
echo '---    ---    ---    ---    ---    ---' >> $STORELOCATION
}

#end_count() {
#}



if [ -f "$STORELOCATION" ]; then
	end_count
else
	start_count
fi

