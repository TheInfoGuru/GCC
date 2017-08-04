#!/bin/bash
winver() {
for i in win7 vista win8 winblue rs1 th2 Win8.1
	do
		if [ -f "$winDir/Windows/System32/ntoskrnl.exe" ]; then
			strings $winDir/Windows/System32/ntoskrnl.exe | grep $i > /dev/null && 2>/dev/null
			if [ $? -eq 0 ]; then
				local winVar=$i
				if [ $winVar == "win7" ]; then
					local winVer="Windows 7"
				elif [ $winVar == "vista" ]; then
					local winVer="Windows Vista"
				elif [ $winVar == "win8" ]; then
					local winVer="Windows 8"
				elif [ $winVar == "winblue" ]; then
					local winVer="Windows 8.1"
				elif [ $winVar == "rs1" ] || [ $winVar == "th2" ] || [ $winVar == "Win8.1" ]; then
					local winVer="Windows 10"
				else local winVer="Windows version unknown"
				fi
			fi
		else winVer="Probably not Windows"
		fi
	done
eval "$1='$winVer'"
}

function c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

choose_HDD() {
	winDir="NA"
	printf 'Would you like to enter the HDD BLKID for testing? [y/n]'
	read -p ': ' ans2
	if [ $ans2 == y ]; then
		lsblk
		echo
		printf 'Please enter BLKID of HDD: '
		read hddID
	elif [ $ans2 == n ]; then
		echo 'Skipping all HDD tests ...'
		hddID=
	fi
}

choose_partition() {
	winDir='NA'
	echo '********************************************************************'
	printf 'Could not automount Windows Partition. Would you like to type in the BLKID of the partition (/dev/sdX1) now? [y/n]'
	read -p ': ' ans1
	if [ $ans1 == y ]; then
		lsblk
		echo
		printf 'Please enter partition BLKID: '
		read  winMount
		echo "Making a mount directory ..."
		mkdir ~/winMount 2>/dev/null
		printf "Attempting to mount partition read-only ... "
		sudo mount -r $winMount ~/winMount 2>/dev/null
		winDir=$(mount | grep "$winMount" | awk '{print $3}')
		hddID=${winMount%?}
		if [ -d "$winDir/Users" ]; then
			echo "SUCCESS"
		else 
			echo "FAIL"
			echo "COULD NOT MOUNT WINDOWS PARTION!"
			sleep 1
			sudo umount $winMount
			choose_HDD
		fi
	elif [ $ans1 == n ]; then
		echo 'Skipping mounting of Windows partition ...'
		choose_HDD
	else
		echo "Invalid Choice. Choose Again."
		sleep 2
		choose_partition
	fi
	echo '********************************************************************'

}

#check for root priveledges
if [ "$EUID" -ne 0 ]
	then echo "This script must be ran as root."
	exit
fi

#Quick internet check
ping -c 1 google.com > /dev/null
NETUP=$(echo $?)

#Random variable set
SMARTCTL=$(command -v smartctl) #Checks if smartctl is an installed command
ACPI=$(command -v acpi) #Checks if acpi is an installed command
TIMESTAMP=$(date "+%m/%d/%y")
ADAPTER=$(ifconfig -a | grep -B 1 -i "inet addr" | grep -i 'enp' | awk {'print $1'})

#clear the screen
clear

#Get PC ID
printf "Enter or scan in the PC ID, or type (o) for noncustomer PC: "
read PCID

if [ "${PCID:0:2}" != "ID" ]; then
	PCIDLoc=$(mktemp)
	echo $PCID > $PCIDLoc
	PCID=$(sed -e 's/^/ID/' $PCIDLoc)
	rm $PCIDLoc
fi

if [ "$PCID" == "o" ]; then
	printf "Enter a name for this file (will be located under Other in Customer Logs): "
	read fileName
fi

echo
read -p 'Do you wish to run a HDD test (Y/n): ' hddTest
echo
read -p 'Do you want to get user data size (Y/n): ' getData

clear

echo

echo Gathering info about this computer. This may take a few moments.

#things from /sys/devices/virtual/dmi/id
echo Getting current computer model ...
computerModel=$(cat /sys/devices/virtual/dmi/id/product_name) #computer model
echo Getting serial number ...
serialNumber=$(cat /sys/devices/virtual/dmi/id/product_serial) #computer serial number
echo Getting system manufacturer ...
systemMaker=$(cat /sys/devices/virtual/dmi/id/sys_vendor) #computer manufacturer

#getting CPU info
echo "Getting CPU info ..."
cpuCores=$(lscpu -p | tail -n 1 | sed 's/,.*//')
cpuCores=$(expr $cpuCores + 1)
cpuInfo=$(cat /proc/cpuinfo | head -n 6 | grep -i 'model name' | cut -c 14-)
cpuInfo+=" - "
cpuInfo+="$cpuCores Cores"

#Getting CPU Temp snapshot
echo "Getting snapshot of CPU temp ..."
cpuTemp=$(sensors | grep -m 1 -i 'Core 0:' | sed 's/.*://' | awk '{print $1}')

#for getting ip address
echo Getting IP address ...
ipAddress=$(ip addr | grep -v "127.0.0.1" | grep "inet " | awk '{print $2}' | tr "\n" " ")

#for getting mac address
echo Getting MAC address ...
macAddress=$(ip addr | grep link/ether | awk '{print $2}' | tr "\n" " ")

#make sure smartmontools is installed
printf "Is smartmontools is installed ... "
if [ ! $SMARTCTL ]; then #Check to see if smartctl is installed
	echo no
	if [ "$NETUP" -eq 0 ]; then
		echo 'Installing smartmontools. Please wait a moment ...'
		sudo apt install -qq smartmontools > /dev/null 2>/dev/null #if not install it
	else 
		echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 10 SECONDS$(tput sgr0)"
		sleep 10
		exit
	fi
else echo yes
fi

#Try to auto mount Windows Partition
  #declare HDD specific variables
winMount=$(sudo fdisk -l | grep -v '*' | grep -iE '(HPFS/NTFS/exFAT|Microsoft basic data)' | awk {'print $1'})
if [ -d $HOME/winMount/Users ]; then
	winDir=$HOME/winMount
else
	winDir=$(mount | grep "$winMount" | awk '{print $3}')
fi

strCheck=${#winMount}

if [ $strCheck -eq 9 ]; then
        hddID=${winMount%?}
elif [ $strCheck -eq 14 ]; then
        hddID=${winMount%??}
fi

printf "Is there a possible windows drive ... "
if [ $strCheck -eq 9 ] || [ $strCheck -eq 14 ]; then
	if [ "$winMount" ]; then
		echo "yes"
		printf "Is a windows partition mounted ... "
		if [ ! "$winDir" ]; then
			echo "no"
			echo "Making a mount directory ..."
			mkdir ~/winMount 2>/dev/null
			printf "Attempting to automount Windows partition read-only ... "
			sudo mount -r $winMount ~/winMount 2>/dev/null
			winDir=$(mount | grep "$winMount" | awk '{print $3}')
			if [ -d "$winDir/Users" ]; then
				echo "successful"
			else 
				echo "failed"
				sudo umount -l $winMount
				choose_partition
			fi
		else echo "yes"
		fi
	else 
		echo "no"
		choose_partition
	fi
else
	echo yes
	choose_partition

fi
###HDD/WINDOWS STUFF###

if [ $hddID ]; then
	#for getting HDD size
	echo Getting HDD size ...
	hddSize=$(smartctl -a $hddID | grep -i "User Capacity:" | awk '{print $5, $6}')
fi

#Try to get User Data size if hdd is mounted
if [ ! "$getData" == "n" ]; then
	echo Trying to calculate approximate user data size ...
	if [ "$winDir" != "NA" ]; then
		userData=$(du -sh $winDir/Users/ 2> /dev/null | awk '{print $1}')
	else userData=NA
	fi
fi

#Maybe get windows version
echo Trying to get Windows Version ...
winVersion=''
if [ "$winDir" != "NA" ]; then
	winver winVersion
else winVersion="Windows Partition not mounted"
fi

###END HDD/WINDOWS STUFF###

#for getting RAM amount
echo Calculating approximate RAM amount ...
memTotal=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')
memTotal=$(expr $memTotal / 1048576)
memTotal=$(expr $memTotal + 1)

#Check if computer is a laptop
printf "Is this a laptop... "
if [ "$(ls -A /sys/class/power_supply)" ]; then
	echo yes
	laptopCheck="y"
else 
	echo no
	laptopCheck="n"
fi

#If computer is a laptop, run battery check
if [ $laptopCheck == y ]; then
	printf "Is ACPI installed ..."
	if [ ! $ACPI ]; then
		echo no
		if [ "$NETUP" -eq 0 ]; then
			echo 'Installing ACPI. Please wait a moment ...'
			sudo apt install -qq acpi > /dev/null 2>/dev/null #if not install it
		else 
			echo -e "$(tput setaf 1)NO INTERNET DETECTED. YOU MUST HAVE INTERNET TO INSTALL PACKAGES. EXITING IN 10 SECONDS$(tput sgr0)"
			sleep 10
			exit
		fi
	else
		echo yes
	fi
	echo "Getting battery health ..."
	batHealth=$(acpi -i | grep -v 'charg' | awk '{print $13}')
	
else batHealth=': NA'
fi

#Get link speed if on ethernet
echo Checking ethernet link speed ...
if [ $ADAPTER ]; then
linkSpeed=$(ethtool $ADAPTER | grep -i speed | awk {'print $2'})
else
linkSpeed="NA"
fi

# Get Bios windows key if it exists
echo Trying to get BIOS WinKey ...
biosKey="NA"

if [ -f /sys/firmware/acpi/tables/MSDM ]; then
	biosKey=$(strings /sys/firmware/acpi/tables/MSDM | tail -n 1)
fi

#Make sure Customer Logs share is mounted
if [ "$PCID" == "o" ]; then
	PCFOLDER="$PWD/Files/CustomerLogs/Other"
	if [ ! -d "$PCFOLDER" ]; then
		mkdir "$PCFOLDER"
		chmod -R 777 "$PCFOLDER"
	fi
	fileName=$(echo "$fileName" | tr -d ' ')
	saveLocation="$PWD/Files/CustomerLogs/Other/$fileName"
else
	PCFOLDER=$(find . -maxdepth 6 -type d -name $PCID)
	saveLocation="$PCFOLDER/info"
fi

#PRINT TO FILE
echo Creating log file ...
echo '///////////////////////////////////////////////////////////START OF INFO\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\' >> "$saveLocation"
echo >> "$saveLocation"
echo "Info was grabbed on $TIMESTAMP" >> "$saveLocation"
echo >> "$saveLocation"
echo "----------------PC Info----------------" >> "$saveLocation"
echo "Computer Manufacturer .  .  .  . . $systemMaker" >> "$saveLocation"
echo "Computer Model . . . . . . . . . . $computerModel" >> "$saveLocation"
echo "Computer Serial Number . . . . . . $serialNumber" >> "$saveLocation"
echo "Computer CPU . . . . . . . . . . . $cpuInfo" >> "$saveLocation"
echo "CPU temp is  . . . . . . . . . . . $cpuTemp" >> "$saveLocation"
echo "Windows Bios Key . . . . . . . . . $biosKey" >> "$saveLocation"
echo "Windows Version  .  .  .  .  .  .  $winVersion" >> "$saveLocation"
echo >> "$saveLocation"
echo "IP Address is $ipAddress" >> "$saveLocation"
echo "MAC Address is $macAddress" >> "$saveLocation"
echo "Ethernet link speed is $linkSpeed." >> "$saveLocation"
echo >> "$saveLocation"
echo "Estimate Battery health is $batHealth" >> "$saveLocation"
echo >> "$saveLocation"
echo "Approximate amount of system memory is $memTotal GB." >> "$saveLocation"
echo >> "$saveLocation"
echo "Approximate size of user data is $userData." >> "$saveLocation"
echo >> "$saveLocation"
echo "--------------HDD section--------------" >> "$saveLocation"
echo "HDD size:        $hddSize" | tr "[]" " " >> "$saveLocation"

#Make Variables
if [ "$hddID" ]; then
ARGV0=$(basename $0) #sets ARGV0 to script name
STDERR=/dev/stderr #sets standard error location
BLKADDRESS=$hddID #Set variable to passed argument (BLK)

# get hdd model
echo Getting HDD model ...
smartctl -a $BLKADDRESS | grep "Device Model" >> "$saveLocation"
echo >> "$saveLocation"

#get basic pass/fail
echo 'Getting SMART pass/fail ...'
smartctl -a $BLKADDRESS | grep "test result" >> "$saveLocation"
echo >> "$saveLocation"

#Checking to see if there are errors in the log
errorsCheck=$(smartctl -a $BLKADDRESS | grep -i 'no errors logged')
if [ ! "$errorsCheck" ]; then
	echo "THERE ARE ERRORS FOUND IN THE LOG!" >> "$saveLocation" 
	echo >> "$saveLocation"
fi


#Get smart attributes
echo Getting SMART attributes ...
smartctl -A $BLKADDRESS | grep -i -E '(Raw_Read_Error_Rate|Reallocated_sector|Reported_Uncorrec|spin_retry|power_on|power_cycle|Current_Pending_Sector|Uncorrectable_Error_Cnt|Offline_Uncorrectable)' | awk '{ print $10, "\t", $2 }' >> "$saveLocation"

echo

# actual scan part
if [ ! "$hddTest" == 'n' ]; then
	smartctl -t short $BLKADDRESS >> /dev/null		# start the test in the background
	echo "Waiting for short HDD smart test to run. Average is 2 minutes."
	echo "Log will be pulled up after running."
	while (sleep 5;sudo smartctl -a $BLKADDRESS | grep -i 'of test remaining.' >/dev/null); do
                if [ $? -ne 0 ]; then
                        break
                fi
        done
fi
echo >> "$saveLocation"	# We need a blank line for pretty printing
echo "Here are the last five SMART test results:" >> "$saveLocation"
echo >> "$saveLocation"
smartctl -l selftest $BLKADDRESS | grep -E '(Test_Description|# 1|# 2|# 3|# 4|# 5)' >> "$saveLocation"	# show results
echo >> "$saveLocation"
fi

chmod 777 "$saveLocation"

if [ ! "$PCID" == "o" ]; then
	sudo echo "Y" > "$PCFOLDER/ranLogs"
fi

#Show log
cat "$saveLocation" | less
