#!/bin/bash
# Utility script to select the bootmode from command line
# Author: Nikhil Devshatwar

# No need to change anything below this line
UMS_part1=/dev/disk/by-id/usb-Linux_UMS_disk*part1
UMS_part2=/dev/disk/by-id/usb-Linux_UMS_disk*part2
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
user=`logname`

usage()
{
	echo
	echo "dfu-boot.sh => Utility script to select bootmode and mount MMC to PC"
	echo "Usage:"
	echo "  sudo ./dfu-boot.sh --PLATFORM [--mount DEV | --bootmode MODE | --tftp ADDRESS]"
	echo "    PLATFORM: j721e-evm, j7200-evm, am65xx-evm"
	echo "    DEV: specify the device to mount => 1 for MMC, 0 for eMMC"
	echo "    MODE: specify the bootmode to use"
	echo "    ADDRESS: specify the IP address for tftp/NFS boot"
}

read_config() {
configfile=$HOME/.config/k3bootswitch.conf
section=$1
param=$2

	python3 -c "
import configparser;
import sys;
config = configparser.ConfigParser();
config.read('$configfile');
print (config['$section'].get('$param',''));
"
}

init() {
board=$1

	prebuilt=$SCRIPTPATH/bin/$board
	boot_select=$SCRIPTPATH/boot_select/$board

	uart_dev=`read_config $board uart_dev`
	nfspath=`read_config $board nfspath`
	switch=`read_config $board switch`

	ipaddr=`read_config core ipaddr`
	switch_type=`read_config core switch_type`

	# Select toggle utility (phidget or rps)
	case $switch_type in
		rps)
			rps_dev=`read_config core rps_dev`
			if [ -z "$rps_dev" ]; then
				>&2 echo "    >>>> ERROR: RPS uart device is missing in the config"
				>&2 echo "    >>>>        Refer to the readme and set rps_dev = /dev/ttyUSB*"
				exit 1
			fi
			toggle_util="$SCRIPTPATH/rps/rps.sh $rps_dev"
			;;
		phidget | *)
			toggle_util=phidget-switch
			;;
	esac
}

toggle_power()
{
switch=$1
	echo "    >>>> Toggling power..."
	($toggle_util $switch 0 && sleep 1 && $toggle_util $switch 1 && sleep 0.1) >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo -n "ERROR: toggle utility '$toggle_util' not found, Reboot manually and press enter.. "
		read DUMMY
	fi
}

# Bootloader takes time to initialize
# wait till PC detects a dfu device
wait_till_ready() {
msg=$1
	for i in `seq 30`; do
		dfu-util -l | grep "Found DFU" >/dev/null 2>&1
		if [ $? -eq "0" ]; then
			>&2 echo "    >>>> dfu ready $msg after $i tries"
			return
		fi
		sleep 0.2
	done
	>&2 echo "    >>>> ERROR: Timeout waiting for dfu"
	>&2 echo "    >>>>        Make sure to connect USB cable from EVM to host machine"
	>&2 echo "    >>>>        Refer to readme for correct switch settings for DFU bootmode:"
	exit 1
}

# Use dfu to send prebuilt binaries till you get to the
# Cortex-A u-boot prompt
boot_till_uboot() {
	wait_till_ready "for tiboot3.bin"
	2>&1 dfu-util -R -a bootloader -D $prebuilt/tiboot3.bin
	# Skip the sysfe.itb where combined boot flow is used
	if [ $board != "am64xx-evm" ]; then
		wait_till_ready "for sysfw.itb"
		2>&1 dfu-util -R -a sysfw.itb -D $prebuilt/sysfw.itb
	fi
	wait_till_ready "for tispl.bin"
	2>&1 dfu-util -R -a tispl.bin -D $prebuilt/tispl.bin
	wait_till_ready "for u-boot.img"
	2>&1 dfu-util -R -a u-boot.img -D $prebuilt/u-boot.img
}

# Detect and mount the partitions
try_mount() {
uart_dev=$1
mdev=$2
	for i in `seq 1 100`; do
		echo "ums 0 mmc $mdev" > $uart_dev
		sleep 0.1
		if [ -b $UMS_part1 ] && [ -b $UMS_part2 ]; then
			mkdir -p /media/$user/UMS-boot
			mkdir -p /media/$user/UMS-rootfs
			mount $UMS_part1 /media/$user/UMS-boot -o uid=`id | cut -d'(' -f1  | cut -d'=' -f2`,gid=`id | cut -d'(' -f2  | cut -d'=' -f2`
			mount $UMS_part2 /media/$user/UMS-rootfs
			echo "    >>>> Mounted partions at /media/$user/UMS-boot and /media/$user/UMS-rootfs"
			return
		fi
	done
	>&2 echo "    >>>> ERROR: Could not find partitions $UMS_part1"
	exit 1
}

change_bootmode_slow() {
uart_dev=$1
        sleep 5
        for i in `seq 1 100`; do
                echo "mw.w 0x43000030 0x0d3b" > $uart_dev
                sleep 0.1
                echo "reset" > $uart_dev
                sleep 0.1
        done
}


# Send a boot_select binary
change_bootmode() {
bootmode=$1
	if [ ! -f $boot_select/spl.$bootmode ]; then
		echo "Invalid bootmode $bootmode"
		options=`ls $boot_select/spl* | awk -F"." 'BEGIN{ORS=" "} { print $2 }'`
		echo "Supported bootmodes for $board are: $options"
		exit 1
	fi

	wait_till_ready
	echo "    >>>> Selecting bootmode: $bootmode"
	dfu-util -R -a bootloader -D $boot_select/spl.$bootmode >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "    >>>> SUCCESS"
	else
		echo "    >>>> FAILED"
	fi
}

# Send commands to do a tftp boot
tftp_boot() {
ipaddr=$1
nfspath=$2

	for i in `seq 1 30`; do
		echo "" > $uart_dev
		sleep 0.3
	done

	cat >>$uart_dev << EOF
run findfdt
setenv bootargs console=\$console \$optargs root=/dev/nfs rw  nfsroot=$ipaddr:$nfspath,nolock,v3,tcp,rsize=4096,wsize=4096 ip=dhcp sysrq_always_enabled loglevel=8 earlycon=ns16550a,mmio32,0x02800000
setenv bootcmd 'run args_all; setenv autoload no; dhcp; setenv serverip $ipaddr; run findfdt; tftp \${loadaddr} Image; tftp \${fdtaddr} \${name_fdt}; fdt address \${fdtaddr}; fdt resize 0x100000; booti \${loadaddr} - \${fdtaddr}'
boot
EOF
}

# Main script starts from here
if [ `whoami` != "root" ]; then
	echo "This script should be called with sudo!!"
	usage
	exit 1
fi

while [[ $# -gt 0 ]]
do
case $1 in
	--j7|--j7es|--j721e|--j721e-evm)
		init "j721e-evm"
		shift
		;;
	--vcl|--j7vcl|--j7200|--j7200-evm)
		init "j7200-evm"
		shift
		;;
	--am65|--am65x-evm|--am654-idk|--am65xx-evm)
		init "am65xx-evm"
		shift
		;;
	--am64|--am64xx-evm)
		init "am64xx-evm"
		shift
		;;
	-t|--tftp)
		ipaddr=$2
		shift
		shift
		;;
	-m|--mount)
		mdev=$2
		shift
		shift
		;;
	-b|--bootmode)
		bootmode=$2
		shift
		shift
		;;
	-h|--help)
		usage
		exit 0
		;;
	*)
		echo "Invalid argument $1"
		usage
		exit 1
		;;
esac
done

init $board

if [ ! -z $bootmode ]; then
	# Reboot the board in specified bootmode
	toggle_power $switch
	if [ $board == "am64x-evm" ] && [ $bootmode == "uart" ]; then
		boot_till_uboot >/dev/null
		change_bootmode_slow $uart_dev
	else
		change_bootmode $bootmode
	fi
elif [ ! -z $mdev ]; then
	# Reboot the board and mount the specified device
	toggle_power $switch
	boot_till_uboot >/dev/null
	try_mount $uart_dev $mdev
elif [ ! -z $ipaddr ]; then
	# Reboot the board and mount the specified device
	toggle_power $switch
	boot_till_uboot >/dev/null
	tftp_boot $ipaddr $nfspath
else
	echo "Invalid usage!!"
	usage
fi
