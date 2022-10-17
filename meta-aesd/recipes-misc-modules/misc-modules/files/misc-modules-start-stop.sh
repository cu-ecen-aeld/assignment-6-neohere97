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
    echo "Installing Misc modules"

	mode="644"
	# Look for wheel or use staff
	if grep -q '^staff:' /etc/group; then
		group="staff"
	else
		group="wheel"
	fi

	#
	# FAULTY
	#

	module_faulty="faulty"
	device_faulty="faulty"

	# Install module
	insmod /lib/modules/5.15.68-yocto-standard/$module_faulty.ko || exit 1

	# Retrieve major number
	major=$(awk "\$2==\"$module_faulty\" {print \$1}" /proc/devices)
	if [ ! -z ${major} ]; then
		# Remove nodes and place them again with ownership and access privileges
		rm -f /dev/${device_faulty}
		mknod /dev/${device_faulty} c $major 0
		chgrp $group /dev/${device_faulty}
		chmod $mode  /dev/${device_faulty}
	else
		echo "No device found in /proc/devices for driver ${module_faulty} (this driver may not allocate a device)"
	fi
	
	#
	# HELLO
	#

	module_hello="hello"
	device_hello="hello"

	# Install module
	modprobe $module_hello || exit 1

	# Retrieve major number
	major=$(awk "\$2==\"$module_hello\" {print \$1}" /proc/devices)
	if [ ! -z ${major} ]; then
		# Remove nodes and place them again with ownership and access privileges
		rm -f /dev/${device_hello}
		mknod /dev/${device_hello} c $major 0
		chgrp $group /dev/${device_hello}
		chmod $mode  /dev/${device_hello}
	else
		echo "No device found in /proc/devices for driver ${module_hello} (this driver may not allocate a device)"
	fi
    
elif [ $1 = "stop" ]
then
    echo "Removing Misc modules"

	# Invoke rmmod with all arguments we got
	module_faulty="faulty"
	device_faulty="faulty"
	rmmod $module_faulty || exit 1
	# Remove stale nodes
	rm -f /dev/${device_faulty}

	# Invoke rmmod with all arguments we got
	module_hello="hello"
	device_hello="hello"
	rmmod $module_hello || exit 1
	# Remove stale nodes
	rm -f /dev/${device_hello}
	
fi