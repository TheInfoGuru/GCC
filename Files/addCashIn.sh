#!/bin/bash
CASHINLOCATION="$HOME/.currentCashIn"

#get input from the user
get_input() {
  #initialize answer variable with 'y'
  answer='y'

  read -p 'Please enter amount of cash in: $' cashIn
  echo
  printf "You have entered \$${cashIn}. Is this correct? (y/n): "
  read answer

  if [ "${answer}" == 'n' ] 2> /dev/null ; then
    get_input
  fi
}

main() {
  get_input
  echo ${cashIn} >> "$CASHINLOCATION"
}

main
