#!/bin/bash

OTHERFOLDER='./Files/CustomerLogs/Other'

echo 'You are about to delete all logs in the other folder.'
echo 'This is the list that is about to be deleted.'
echo
find "${OTHERFOLDER}" -maxdepth 1 -type f | sed 's/^.*\///g' | column
echo
read -p 'ARE YOU SURE YOU WANT TO DELETE ALL THESE LOGS (y/N): ' choice

if [ "${choice,,}" == 'y' ]; then
  find "${OTHERFOLDER}" -maxdepth 1 -type f -exec rm {} \;
  echo "Logs deleted."
  sleep 1.5
else
  echo "Canceling deletion."
  sleep 1.5
fi
