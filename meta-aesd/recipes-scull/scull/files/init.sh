#!/bin/sh

usage() {
	echo "Command: $0 <start/stop>"
	echo "Functionality: installs/removes the LDD."
}

#Check that one arguments has been provided
if [ ! $# -eq 1 ]
then
	usage
	exit 1
fi

if [ $1 = "start" ]
then
    echo "Installing Scull modules"

	mode="644"
	# Look for wheel or use staff
	if grep -q '^staff:' /etc/group; then
		group="staff"
	else
		group="wheel"
	fi

	#
	# SCULL
	#

	device_scull="scull"
	module_scull="scull"
	
	# Install module
	insmod /lib/modules/5.15.68-yocto-standard/$module_scull.ko || exit 1

	# Retrieve major number
	major=$(awk "\$2==\"$module_scull\" {print \$1}" /proc/devices)

	# Remove nodes and place them again with ownership and access privileges
	rm -f /dev/${device_scull}[0-3]
	mknod /dev/${device_scull}0 c $major 0
	mknod /dev/${device_scull}1 c $major 1
	mknod /dev/${device_scull}2 c $major 2
	mknod /dev/${device_scull}3 c $major 3
	ln -sf ${device_scull}0 /dev/${device_scull}
	chgrp $group /dev/${device_scull}[0-3] 
	chmod $mode  /dev/${device_scull}[0-3]

	rm -f /dev/${device_scull}pipe[0-3]
	mknod /dev/${device_scull}pipe0 c $major 4
	mknod /dev/${device_scull}pipe1 c $major 5
	mknod /dev/${device_scull}pipe2 c $major 6
	mknod /dev/${device_scull}pipe3 c $major 7
	ln -sf ${device_scull}pipe0 /dev/${device_scull}pipe
	chgrp $group /dev/${device_scull}pipe[0-3] 
	chmod $mode  /dev/${device_scull}pipe[0-3]

	rm -f /dev/${device_scull}single
	mknod /dev/${device_scull}single  c $major 8
	chgrp $group /dev/${device_scull}single
	chmod $mode  /dev/${device_scull}single

	rm -f /dev/${device_scull}uid
	mknod /dev/${device_scull}uid   c $major 9
	chgrp $group /dev/${device_scull}uid
	chmod $mode  /dev/${device_scull}uid

	rm -f /dev/${device_scull}wuid
	mknod /dev/${device_scull}wuid  c $major 10
	chgrp $group /dev/${device_scull}wuid
	chmod $mode  /dev/${device_scull}wuid

	rm -f /dev/${device_scull}priv
	mknod /dev/${device_scull}priv  c $major 11
	chgrp $group /dev/${device_scull}priv
	chmod $mode  /dev/${device_scull}priv
    
elif [ $1 = "stop" ]
then
    echo "Removing Scull modules"

	# Invoke rmmod with all arguments we got
	module_scull="scull"
	device_scull="scull"
	rmmod $module_scull || exit 1
	# Remove stale nodes
	rm -f /dev/${device_scull}[0-3]
	rm -f /dev/${device_scull}pipe[0-3]
	rm -f /dev/${device_scull}single
	rm -f /dev/${device_scull}uid
	rm -f /dev/${device_scull}wuid
	rm -f /dev/${device_scull}priv
	
fi