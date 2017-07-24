#!/bin/bash

get_input() {
answer=y
read -p 'Please enter amount of cash in (Do NOT include change): $' cashIn
echo
printf "You have entered \$$cashIn. Is this correct? (y/n): "
read answer

if [ $answer == n ] 2> /dev/null ; then
	get_input
fi
}
get_input
echo $cashIn >> ~/currentCashIn
