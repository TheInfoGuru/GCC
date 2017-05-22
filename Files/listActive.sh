#!/bin/bash
clear
echo "These are the computers currently checked in: "
echo
find ./* -type f -name 'log'
echo
read -p 'Press ENTER to continue.'
