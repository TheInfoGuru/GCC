#!/bin/bash

OTHERESTIMATEFOLDER='./Files/CustomerLogs/Other/ESTIMATES'

echo 'You are about to delete all estimates in the other folder.'
echo 'This is the list that is about to be deleted.'
echo
find "${OTHERESTIMATEFOLDER}" -maxdepth 1 -type f | sed 's/^.*\///g' | column
echo
read -p 'ARE YOU SURE YOU WANT TO DELETE ALL THESE ESTIMATES (y/N): ' choice

if [ "${choice,,}" == 'y' ]; then
  find "${OTHERESTIMATEFOLDER}" -maxdepth 1 -type f -exec rm {} \;
  echo "Estimates deleted."
  sleep 1.5
else
  echo "Canceling deletion."
  sleep 1.5
fi
