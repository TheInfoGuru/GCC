#!/bin/bash

#Source sourcefile
source ./Files/commonFunctions.source

#clear the screen
clear

#Set location variables
CURRENTLOCATION="${HOME}/.current_drawer"
STORELOCATION="${PWD}/DrawerCounts"
CASHINFILE="${HOME}/.currentCashIn"
CASHOUTFILE="${HOME}/.currentCashOut"

#Beginning of the day count
start_count() {
  #Get amounts from user
  echo '***************START OF DAY**************************'
  read -p 'Please enter number of 20s in drawer: ' beginningTwenties
  read -p 'Please enter number of 10s in drawer: ' beginningTens
  read -p 'Please enter number of 5s in drawer: ' beginningFives
  read -p 'Please enter number of 1s in drawer: ' beginningOnes
  echo

  #Amount calculations
  twentyAmount=$(bc < <(echo "${beginningTwenties} * 20"))
  tenAmount=$(bc < <(echo "${beginningTens} * 10"))
  fiveAmount=$(bc < <(echo "${beginningFives} * 5"))
  oneAmount="${beginningOnes}"
  beginningBalance=$(bc < <(echo "${twentyAmount} + ${tenAmount} + ${fiveAmount} + ${oneAmount}"))

  #Output to user total amount of beginning drawer
  echo "Your beginning drawer balance is: ${beginningBalance}"
  break_line
  echo 'Please press enter to exit when you are done.'
  read waitForUserInput

  start_drawer_file

  return 0
}

#Print to current drawer count file
start_drawer_file() {
  echo "****************$(today_date)****************" >> ${CURRENTLOCATION}
  echo '======= BEGINNING DRAWER =======' >> ${CURRENTLOCATION}
  echo "Number of Twenties . . . . ${beginningTwenties}" >> ${CURRENTLOCATION}
  echo "Number of Tens . . . . . . ${beginningTens}" >> ${CURRENTLOCATION}
  echo "Number of Fives . . . . . .${beginningFives}" >> ${CURRENTLOCATION}
  echo "Number of Ones . . . . . . ${beginningOnes}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Beginning Drawer Balance: \$$beginningBalance" >> ${CURRENTLOCATION}
  echo '---    ---    ---    ---    ---    ---' >> ${CURRENTLOCATION}

  return 0
}

end_count() {
  #get ending drawer amounts from user
  echo '***************END OF DAY*******************'
  read -p 'Please enter number of 20s in drawer: ' endTwenties
  read -p 'Please enter number of 10s in drawer: ' endTens
  read -p 'Please enter number of 5s in drawer: ' endFives
  read -p 'Please enter number of 1s in drawer: ' endOnes
  read -p 'Enter CASH QuickBooks total: $' qbTotal
  read -p 'Enter CC BATCH total: $' ccTotal

  #Initialize Values
  cashIn=0
  cashOut=0
  cashInAmounts=$(cat ${CASHINFILE} 2> /dev/null)
  cashOutAmounts=$(cat ${CASHOUTFILE} 2> /dev/null)

  #Add up cash in and out amounts
  for i in ${cashInAmounts}; do
    cashIn=$(bc < <(echo "${cashIn} + ${i}"))
  done

  for j in ${cashOutAmounts}; do
    cashOut=$(bc < <(echo "${cashOut} + ${j}"))
  done

  #Get and calculate ending drawer amounts
  beginningBalance=$(grep 'Beginning Drawer' ${CURRENTLOCATION} | awk '{print $4}' | tr -d '$')
  twentyAmount=$(bc < <(echo "${endTwenties} * 20"))
  tenAmount=$(bc< <(echo "${endTens} * 10"))
  fiveAmount=$(bc < <(echo "${endFives} * 5"))
  oneAmount="${endOnes}"
  endingBalance=$(bc < <(echo "${twentyAmount} + ${tenAmount} + ${fiveAmount} + ${oneAmount}"))
  cashDeposit=$(bc < <(echo "${qbTotal} + ${beginningBalance} - ${endingBalance} - ${cashOut} + ${cashIn}"))

  display_user_summary
  end_drawer_file
  cleanup_files
}

display_user_summary() {
  #Display to user daily summary
  break_line
  tput setaf 3
  echo
  echo "Your beginning drawer balance was: \$${beginningBalance}"
  echo "Your ending drawer balance is: \$${endingBalance}"
  echo "Your total cash in today was: \$${cashIn}"
  echo "Your total cash out today was: \$${cashOut}"
  echo
  echo "Your Cash Deposit should be \$${cashDeposit}."
  echo
  echo "Your totals for the day are as follows:"
  echo
  echo "CASH ................... \$${qbTotal}"
  echo "CC ..................... \$${ccTotal}"
  echo
  tput sgr0
  break_line
  echo "Please press enter to exit when you are done."
  read nul
}

end_drawer_file() {
  #print daily summary to storage file
  echo >> ${CURRENTLOCATION}
  echo '======== ENDING DRAWER ========' >> ${CURRENTLOCATION}
  echo "Number of Twenties . . . . ${endTwenties}" >> ${CURRENTLOCATION}
  echo "Number of Tens . . . . . . ${endTens}" >> ${CURRENTLOCATION}
  echo "Number of Fives . . . . . .${endFives}" >> ${CURRENTLOCATION}
  echo "Number of Ones . . . . . . ${endOnes}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Ending Drawer Balance" >> ${CURRENTLOCATION}
  echo "\$${endingBalance}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Ending QB Cash Total" >> ${CURRENTLOCATION}
  echo "\$${qbTotal}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Ending CC Batch Total" >> ${CURRENTLOCATION}
  echo "\$${ccTotal}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Cash Out For the Day" >> ${CURRENTLOCATION}
  echo "\$${cashOut}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Cash In For the Day" >> ${CURRENTLOCATION}
  echo "\$${cashIn}" >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  echo "Actual Cash Deposit" >> ${CURRENTLOCATION}
  echo "\$${cashDeposit}" >> ${CURRENTLOCATION}
  echo '###########################################################' >> ${CURRENTLOCATION}
  echo >> ${CURRENTLOCATION}
  cat ${CURRENTLOCATION} >> ${STORELOCATION}
}

cleanup_files() {
  [ -f "${CURRENTLOCATION}" ] && rm ${CURRENTLOCATION}
  [ -f "${CASHINFILE}" ] && rm ${CASHINFILE}
  [ -f "${CASHOUTFILE}" ] && rm ${CASHOUTFILE}

}
if [ -f "${CURRENTLOCATION}" ]; then
	end_count
else
	start_count
fi

