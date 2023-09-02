#! /bin/bash

ETHCOUNT=0

FILE=/etc/udev/rules.d/70-persistent-net.rules

if test -f "$FILE"; then
	
	echo "Network cards already configured"	

else	
	touch /etc/udev/rules.d/70-persistent-net.rules

	while [ $ETHCOUNT -le 1 ]; 

	do
		for i in `ifconfig | grep "ether" | cut -d " " -f 10`
		do
			echo "SUBSYSTEM==\"net\",ACTION==\"add\",DRIVERS==\"?*\",ATTR{address}==\"$i\",ATTR{dev_id}==\"0x0\",ATTR{type}==\"1\",NAME=\"eth$ETHCOUNT\"" >> /etc/udev/rules.d/70-persistent-net.rules
			((ETHCOUNT++))
		done
	done
	CRONFILE="var/spool/cron/root"
	rm $CRONFILE
	systemctl stop NetworkManager
	systemctl disable NetworkManager
	
	echo "ifconfig eth0 up" > /root/startNetwork.sh
	echo "ifconfig eth1 up" >> /root/startNetwork.sh
	echo "systemctl start NetworkManager" >> /root/startNetwork.sh
	echo "systemctl enable NetworkManager" >> /root/startNetwork.sh
	echo "echo \" \" > /var/spool/cron/root" >> /root/startNetwork.sh
	echo "/usr/bin/crontab /var/spool/cron/root" >> /root/startNetwork.sh
	echo "reboot" >> /root/startNetwork.sh
	
	chmod +x /root/startNetwork.sh

	CRONFILE="/var/spool/cron/root"
	touch $CRONFILE
	/usr/bin/crontab $CRONFILE

	echo "@reboot /root/startNetwork.sh" >> $CRONFILE
	
	reboot
fi
