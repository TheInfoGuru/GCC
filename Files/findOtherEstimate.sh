#!/bin/bash

OTHERESTIMATEFOLDER='./Files/CustomerLogs/Other/ESTIMATES'
PS3=$'\nPlease choose log to view: '

echo
select opt in $(find "${OTHERESTIMATEFOLDER}" -maxdepth 1 -type f | sed 's/^.*\///g'); do
  cat "${OTHERESTIMATEFOLDER}/${opt}" | less
  exit 0
done
echo "No estimates currently in other folder."
sleep 1.5
