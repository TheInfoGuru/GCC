#!/bin/bash

#Source sourcefile
source ./Files/commonFunctions.source

#clear the screen
clear

#Set location variables
TEMPLOCATIONBEG="${HOME}/.current_drawer"
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
  echo "****************$(today_date)****************" >> ${TEMPLOCATIONBEG}
  echo '======= BEGINNING DRAWER =======' >> ${TEMPLOCATIONBEG}
  echo "Number of Twenties . . . . ${beginningTwenties}" >> ${TEMPLOCATIONBEG}
  echo "Number of Tens . . . . . . ${beginningTens}" >> ${TEMPLOCATIONBEG}
  echo "Number of Fives . . . . . .${beginningFives}" >> ${TEMPLOCATIONBEG}
  echo "Number of Ones . . . . . . ${beginningOnes}" >> ${TEMPLOCATIONBEG}
  echo >> ${TEMPLOCATIONBEG}
  echo "Beginning Drawer Balance: \$$beginningBalance" >> ${TEMPLOCATIONBEG}

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
  beginningBalance=$(grep 'Beginning Drawer' ${TEMPLOCATIONBEG} | awk '{print $4}' | tr -d '$')
  twentyAmount=$(bc < <(echo "${endTwenties} * 20"))
  tenAmount=$(bc< <(echo "${endTens} * 10"))
  fiveAmount=$(bc < <(echo "${endFives} * 5"))
  oneAmount="${endOnes}"
  endingBalance=$(bc < <(echo "${twentyAmount} + ${tenAmount} + ${fiveAmount} + ${oneAmount}"))
  cashDeposit=$(bc < <(echo "${qbTotal} + ${beginningBalance} - ${endingBalance} - ${cashOut} + ${cashIn}"))

  display_user_summary
  end_drawer_file
  print_file
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
  TEMPLOCATIONEND="$(mktemp)"
  #print daily summary to storage file
  echo >> ${TEMPLOCATIONEND}
  echo '======== ENDING DRAWER ========' >> ${TEMPLOCATIONEND}
  echo "Number of Twenties . . . . ${endTwenties}" >> ${TEMPLOCATIONEND}
  echo "Number of Tens . . . . . . ${endTens}" >> ${TEMPLOCATIONEND}
  echo "Number of Fives . . . . . .${endFives}" >> ${TEMPLOCATIONEND}
  echo "Number of Ones . . . . . . ${endOnes}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Ending Drawer Balance" >> ${TEMPLOCATIONEND}
  echo "\$${endingBalance}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Ending QB Cash Total" >> ${TEMPLOCATIONEND}
  echo "\$${qbTotal}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Ending CC Batch Total" >> ${TEMPLOCATIONEND}
  echo "\$${ccTotal}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Cash Out For the Day" >> ${TEMPLOCATIONEND}
  echo "\$${cashOut}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Cash In For the Day" >> ${TEMPLOCATIONEND}
  echo "\$${cashIn}" >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  echo "Actual Cash Deposit" >> ${TEMPLOCATIONEND}
  echo "\$${cashDeposit}" >> ${TEMPLOCATIONEND}
  echo '###########################################################' >> ${TEMPLOCATIONEND}
  echo >> ${TEMPLOCATIONEND}
  cat ${TEMPLOCATIONBEG} >> ${STORELOCATION}
  cat ${TEMPLOCATIONEND} >> ${STORELOCATION}
}

LPRBACK() {
  [ ! $(command -v enscript) ] && echo "Installing enscript. Please wait." && $(sudo apt install -qqy enscript)
  ENSCRIPT="--no-header --margins=36:36:36:36 --font=Times-Roman12 --word-wrap --media=Letter"
  export ENSCRIPT
  /usr/bin/enscript -p - ${1} | /usr/bin/lpr -P "HPBACK"
}

print_file() {
  PRINTFILE=$(mktemp)
  cat "${TEMPLOCATIONBEG}" >> "${PRINTFILE}"
  cat "${TEMPLOCATIONEND}" >> "${PRINTFILE}"
  LPRBACK "${PRINTFILE}" > /dev/null 2>&1
}

cleanup_files() {
  [ -f "${TEMPLOCATIONBEG}" ] && rm ${TEMPLOCATIONBEG}
  [ -f "${TEMPLOCATIONEND}" ] && rm ${TEMPLOCATIONEND}
  [ -f "${PRINTFILE}" ] && rm ${PRINTFILE}
  [ -f "${CASHINFILE}" ] && rm ${CASHINFILE}
  [ -f "${CASHOUTFILE}" ] && rm ${CASHOUTFILE}
}

main() {
  if [ -f "${TEMPLOCATIONBEG}" ]; then
    end_count
  else
    start_count
  fi
}

main
