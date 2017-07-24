#!/bin/bash

get_input() {
answer=y
read -p 'Please enter amount of cash out (Do NOT include change): $' cashOut
echo
printf "You have entered \$$cashOut. Is this correct? (y/n): "
read answer

if [ $answer == n ] 2> /dev/null ; then
	get_input
fi
}
get_input
echo $cashOut >> ~/currentCashOut
