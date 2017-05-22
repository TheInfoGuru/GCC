#!/bin/bash

function c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

#Find out what is mounted
echo -e "[$(c_timestamp)] Finding current mount points."

netMount=$(mount | grep -i '10.1.10.13/net' | awk '{print $3}')
smbMount=$(mount | grep -i '10.1.10.12/smb' | awk '{print $3}')
dataMount=$(mount | grep -i '10.1.10.12/CustomerData' | awk '{print $3}')

if [ ! $netMount ]; then
	echo -e "[$(c_timestamp)] Making Net directory in home folder."
	mkdir ~/Net > /dev/null 2>/dev/null
	echo -e "[$(c_timestamp)] Mounting Net share to created folder."
	sudo mount -t cifs -o user=Guest,password=,rw //10.1.10.13/Net ~/Net > /dev/null
	echo -e "[$(c_timestamp)] Done."
	netMount="~/Net"
fi

if [ ! $smbMount ]; then
	echo -e "[$(c_timestamp)] Making SMB directory in home folder."
	mkdir ~/SMB > /dev/null 2>/dev/null
	echo -e "[$(c_timestamp)] Mounting SMB share to created folder."
	sudo mount -t cifs -o user=Guest,password=,rw //10.1.10.12/SMB ~/SMB > /dev/null
	echo -e "[$(c_timestamp)] Done."
	logsMount="~/SMB"
fi

#if [ ! $dataMount ]; then
#	echo -e "[$(c_timestamp)] Making Customer Data directory in home folder."
#	mkdir ~/CustomerData > /dev/null 2>/dev/null
#	echo -e "[$(c_timestamp)] Mounting Customer Data share to created folder."
#	sudo mount -t cifs -o user=Guest,password=,rw //10.1.10.12/CustomerData ~/CustomerData > /dev/null
#	echo -e "[$(c_timestamp)] Done."
#	dataMount="~/CustomerData"
#fi

echo "****************************************************"
echo "* Net Share mounted at $netMount"
echo "* SMB Share mounted at $smbMount"
echo "* Customer Data mounted at $dataMount"
echo "****************************************************"
sleep 3
