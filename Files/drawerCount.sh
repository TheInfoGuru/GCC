#!/bin/bash
clear

CURRENTLOCATION="$HOME/.current_drawer"
STORELOCATION="$PWD/DrawerCounts"

start_count() {
echo '***************START OF DAY**************************'
read -p 'Please enter number of 20s in drawer: ' BEGTWENTY
read -p 'Please enter number of 10s in drawer: ' BEGTEN
read -p 'Please enter number of 5s in drawer: ' BEGFIVE
read -p 'Please enter number of 1s in drawer: ' BEGONE
echo

TWENTYTOTAL=$(python -c "print($BEGTWENTY*20)")
TENTOTAL=$(python -c "print($BEGTEN*10)")
FIVETOTAL=$(python -c "print($BEGFIVE*5)")
ONETOTAL=$(python -c "print($BEGONE*1)")
BEGBAL=$(python -c "print($TWENTYTOTAL+$TENTOTAL+$FIVETOTAL+$ONETOTAL)")

echo "Your beginning drawer balance is: $BEGBAL"
echo '*******************************************************'
echo 'Please press enter to exit when you are done.'
read nul

DATE=$(date | awk '{print $2, $3, $6}')

echo "****************$DATE****************" >> $CURRENTLOCATION
echo '======= BEGINNING DRAWER =======' >> $CURRENTLOCATION
echo "Number of Twenties . . . . $BEGTWENTY" >> $CURRENTLOCATION
echo "Number of Tens . . . . . . $BEGTEN" >> $CURRENTLOCATION
echo "Number of Fives . . . . . .$BEGFIVE" >> $CURRENTLOCATION
echo "Number of Ones . . . . . . $BEGONE" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Beginning Drawer Balance" >> $CURRENTLOCATION
echo "$BEGBAL" >> $CURRENTLOCATION
echo '---    ---    ---    ---    ---    ---' >> $CURRENTLOCATION
}

end_count() {
echo '***************END OF DAY*******************'
read -p 'Please enter number of 20s in drawer: ' ENDTWENTY
read -p 'Please enter number of 10s in drawer: ' ENDTEN
read -p 'Please enter number of 5s in drawer: ' ENDFIVE
read -p 'Please enter number of 1s in drawer: ' ENDONE
read -p 'Enter CASH QuickBooks total: $' QBTOTAL
read -p 'Enter CC BATCH total: $' CCTOTAL

CASHIN=0
CASHOUT=0
CASHINFILE="$HOME/.currentCashIn"
CASHOUTFILE="$HOME/.currentCashOut"
CASHINAMOUNTS=$(cat $CASHINFILE 2> /dev/null)
CASHOUTAMOUNTS=$(cat $CASHOUTFILE 2> /dev/null)

for i in $CASHINAMOUNTS; do
	CASHIN=$(expr $CASHIN + $i) 2> /dev/null
done

for j in $CASHOUTAMOUNTS; do
	CASHOUT=$(expr $CASHOUT + $j) 2> /dev/null
done

BEGBAL=$(grep -A 1 'Beginning Drawer Balance' $CURRENTLOCATION | grep -v 'Beginning Drawer Balance')

TWENTYTOTAL=$(python -c "print($ENDTWENTY*20)")
TENTOTAL=$(python -c "print($ENDTEN*10)")
FIVETOTAL=$(python -c "print($ENDFIVE*5)")
ONETOTAL=$(python -c "print($ENDONE*1)")
ENDBAL=$(python -c "print($TWENTYTOTAL+$TENTOTAL+$FIVETOTAL+$ONETOTAL)")
CASHDEPOSIT=$(python -c "print($QBTOTAL+$BEGBAL-$ENDBAL-$CASHOUT+$CASHIN)")

echo '*******************************************************'
tput setaf 3
echo
echo "Your beginning drawer balance was: \$$BEGBAL"
echo "Your ending drawer balance is: \$$ENDBAL"
echo "Your total cash in today was: \$$CASHIN"
echo "Your total cash out today was: \$$CASHOUT"
echo
echo "Your Cash Deposit should be \$$CASHDEPOSIT."
echo
echo "Your totals for the day are as follows:"
echo
echo "CASH ................... \$$QBTOTAL"
echo "CC ..................... \$$CCTOTAL"
echo
tput sgr0
echo '*******************************************************'
echo "Please press enter to exit when you are done."
read nul

echo >> $CURRENTLOCATION
echo '======== ENDING DRAWER ========' >> $CURRENTLOCATION
echo "Number of Twenties . . . . $ENDTWENTY" >> $CURRENTLOCATION
echo "Number of Tens . . . . . . $ENDTEN" >> $CURRENTLOCATION
echo "Number of Fives . . . . . .$ENDFIVE" >> $CURRENTLOCATION
echo "Number of Ones . . . . . . $ENDONE" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Ending Drawer Balance" >> $CURRENTLOCATION
echo "\$$ENDBAL" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Ending QB Cash Total" >> $CURRENTLOCATION
echo "\$$QBTOTAL" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Ending CC Batch Total" >> $CURRENTLOCATION
echo "\$$CCTOTAL" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Cash Out For the Day" >> $CURRENTLOCATION
echo "\$$CASHOUT" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Cash In For the Day" >> $CURRENTLOCATION
echo "\$$CASHIN" >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
echo "Actual Cash Deposit" >> $CURRENTLOCATION
echo "\$$CASHDEPOSIT" >> $CURRENTLOCATION
echo '###########################################################' >> $CURRENTLOCATION
echo >> $CURRENTLOCATION
cat $CURRENTLOCATION >> $STORELOCATION
if [ $? -ne 0 ]; then
	echo "there was an error cating current to store location"
	read nul
	exit 1
fi
rm $CURRENTLOCATION
rm $CASHINFILE 2> /dev/null
rm $CASHOUTFILE 2> /dev/null
}



if [ -f "$CURRENTLOCATION" ]; then
	end_count
else
	start_count
fi

