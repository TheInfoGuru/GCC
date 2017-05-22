#!/bin/bash

##get current serial, if log found with serial, ask user if they want to see it. if so , display it. if not, ask for serial or customer name and display options or auto bring up only one

find_term() {
        echo
        old_IFS=$IFS
        for i in $(find . -maxdepth 4 -type f 2>/dev/null) 
                do
                        IFS=
                        foundArray+=($(grep -il "$nameSerial" "$i")) 2>/dev/null
                done
        IFS=${old_IFS}

	if [ ! "$foundArray" ]; then
		echo -e "Log not found for $nameSerial."
		echo
		return
	fi

        if [ "${foundArray[1]}" ]; then

                PS3="Please choose an item from the matched search: "

                select pcOpt in "${foundArray[@]}"; do
                        case $pcOpt in
				"${foundArray[0]}")
					cat "${foundArray[0]}" | less
					break;
					;;
				"${foundArray[1]}")
					cat "${foundArray[1]}" | less
					break;
					;;
				"${foundArray[2]}")
					cat "${foundArray[2]}" | less
					break;
					;;
				"${foundArray[3]}")
					cat "${foundArray[3]}" | less
					break;
					;;
				"${foundArray[4]}")
					cat "${foundArray[4]}" | less
					break;
					;;
				"${foundArray[5]}")
					cat "${foundArray[5]}" | less
					break;
					;;
				"${foundArray[6]}")
					cat "${foundArray[6]}" | less
					break;
					;;
				"${foundArray[7]}")
					cat "${foundArray[7]}" | less
					break;
					;;
				"${foundArray[8]}")
					cat "${foundArray[8]}" | less
					break;
					;;
				"${foundArray[9]}")
					cat "${foundArray[9]}" | less
					break;
					;;
				"${foundArray[10]}")
					cat "${foundArray[10]}" | less
					break;
					;;
				"${foundArray[11]}")
					cat "${foundArray[11]}" | less
					break;
					;;
				"${foundArray[12]}")
					cat "${foundArray[12]}" | less
					break;
					;;
				"${foundArray[13]}")
					cat "${foundArray[13]}" | less
					break;
					;;
				"${foundArray[14]}")
					cat "${foundArray[14]}" | less
					break;
					;;
				"${foundArray[15]}")
					cat "${foundArray[15]}" | less
					break;
					;;
				"${foundArray[16]}")
					cat "${foundArray[16]}" | less
					break;
					;;
				"${foundArray[17]}")
					cat "${foundArray[17]}" | less
					break;
					;;
				"${foundArray[18]}")
					cat "${foundArray[18]}" | less
					break;
					;;
				"${foundArray[19]}")
					cat "${foundArray[19]}" | less
					break;
					;;
                                *)
                                        echo "ERROR: YOU HAVE MADE AN INCORRECT CHOICE.";
                                        echo "PLEASE CHOOSE ONE OF THE OPTIONS LISTED.";
                                        sleep 3;
                                        ;;
                        esac
                done
        else
		cat "${foundArray[0]}"
        fi
}

main() {
	clear
	printf "Please enter what to look for in the logs: "
	read nameSerial
	echo
	find_term
}

main

while (true); do
	printf "Would you like to run another query (y/n): "
	read runAgain
	if [ "$runAgain" == 'n' ]; then
		exit
	else main
	fi
done

