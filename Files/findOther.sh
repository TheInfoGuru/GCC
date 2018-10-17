#!/bin/bash

OTHERFOLDER='./Files/CustomerLogs/Other'
PS3=$'\nPlease choose log to view: '
echo
select opt in $(find "${OTHERFOLDER}" -maxdepth 1 -type f | sed 's/^.*\///g'); do
  cat "${OTHERFOLDER}/${opt}" | less
  break
done
