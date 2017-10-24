#!/bin/bash

# Copyright (c) 2016 NOVTECH Inc.
# All rights reserved.
# 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This script prepares a SD card with a boot image for the Altera Cyclone V based Boards
# Requires the root file system with a valid bootloader
#
###############################################################################################

# V0.1 9/21/2016 - Created from mk_mx7_sd.sh
# V0.2 9/21/2016 - updated for altera file names
# V0.3 9/21/2016 - Updated for 1M SPL, 50M FAT, rest RFS
# V0.5 11/17/2016 - Updated for new project structure, file names
# V0.6 11/20/2016 - Updated to account for proper naming of .dtb and .rbf 
# V0.7 11/20/2016 - Updated to resolve issue programming RFS
# V0.8 1/3/2017 - Updated to reference netleap_hdl_embedded_images 

opt=''

#get the project name from the top level directory
#PROJNAME=${PWD##*/} 
#LC_PROJNAME=${PROJNAME,,}

#set up paths to binaries

#paths to recompiled altera images
RBF_PATH="hdl_embedded_images"
SPL_PATH="hdl_embedded_images"
#UBOOT_PATH="hdl_embedded_images"
UBOOT_PATH="images"
LINUX_PATH="images"

# names of files/paths we will use later
TMP_MOUNTPOINT="./tmp_mnt"
ZIMAGE_NAME="zImage"
#DTB_NAME="socfpga_cyclone5_cv96.dtb"
DTB_NAME="socfpga.dtb"
UBOOT_SCR_NAME="u-boot.scr"
#FPGA_BIN_NAME="chameleon96.rbf"
FPGA_BIN_NAME="cv96.rbf"
ROOTFS_NAME="rootfs.ext2"
PRELOADER_NAME="preloader-mkpimage.bin"
UBOOT_NAME="u-boot.img"

function print_usage() {
    echo -e "\nUsage: $0 [-hukdfFrspa] /dev/sd# \nwhere /dev/sd# is a valid devnode for the SD card."
    echo "         -h        Help.  (This information.)"
    echo "         -u        Place U-boot on the SD card."
    echo "         -k        Place Kernel on the SD card."
    echo "         -d        Place Device Tree on the SD card."
    echo "         -f        Place root Filesystem on the SD card."
    echo "         -F        Place FULL root Filesystem on the SD card."
    echo "         -r        Place RBF on the SD card."
    echo "         -s        Place preloader on the SD card."
    echo "         -p        Partition the SD card."
    echo "         -a        copy all binaries to card"
    echo "                   (Also partitions if needed + full RFS)"
    echo -e ""
    echo -e "Run this script in the Project directory."
    echo -e "The ./rootfs/boot directory contains the kernel and boot stream files to be installed."
    echo -e ""
    echo -e "This utility uses sudo to: "
    echo -e "  1. erase the MBR on the given /dev/sd#" 
    echo -e "  2. repartitions the device as required to boot the Altera from sd media"
    echo -e "  3. installs the boot stream, kernel, and root filesystem to the sd card"
    echo -e ""
    echo -e "Notes:"
    echo -e "This script will refuse to work on /dev/sda, which is usually a hard disk."
    echo -e "This script will refuse to work on any medium which is ALREADY MOUNTED"
    echo -e "when the script starts.  Therefore, start the script, then insert the card"
    echo -e "when asked if you want to continue."
    echo -e ""
    exit 1
}

################################################
# constants
#
CONST_1K=1024
CONST_1M=$((${CONST_1K} * ${CONST_1K}))
CONST_1G=$((${CONST_1M} * ${CONST_1K}))
CONST_RFS_TYPE=ext4

# partition table settings
# unit = bytes. adjustments to satisfy the partitioner tool done below
CONST_PT_BOOT_SIZE=${CONST_1M}
CONST_PT_BOOT_OFFSET=${CONST_1M}
CONST_PT_BOOT_TYPE=a2
CONST_PT_BOOT_NUM=3

# 1/ Root file System partition, Type 83 = Linux EXT
CONST_PT_RFS_TYPE=83
CONST_PT_RFS_NUM=2

# 2/ Parition for the kernel, Device tree, etc. 
CONST_PT_LX_TYPE=b
CONST_PT_LX_NUM=1

#Size of the card, in GB
CARD_SIZE=4

#size of the card in KB
IMAGE_SIZE=$((${CARD_SIZE} * ${CONST_1G})) 

# Calculate EXT and FAT partition size based on image size. Preloader partition size is fixed (1MB).
# Root file System partition, Type 83 = Linux EXT, 80% of image size
CONST_PT_RFS_SIZE=$((${IMAGE_SIZE} * 85 / 100))
#CONST_PT_RFS_SIZE=$((${IMAGE_SIZE} - (${CONST_1M}*100)))

CONST_PT_RFS_OFFSET=$((${CONST_PT_BOOT_OFFSET} + ${CONST_PT_BOOT_SIZE} + 5*${CONST_1M}))

# FAT file system, 10% size
#CONST_PT_LX_SIZE=(${CONST_1M}*50)
CONST_PT_LX_SIZE=$((${IMAGE_SIZE} * 5 / 100))
CONST_PT_LX_OFFSET=$((${CONST_PT_RFS_OFFSET} + ${CONST_PT_RFS_SIZE} + 5 * ${CONST_1M}))

DEBUG=
put_uboot=0
put_kernel=0
put_uboot_padding=0
put_root=0
put_full_root=0
put_rbf=0
put_device_tree=0
put_partition=0
put_preloader=0
put_all=0
is_1partitioned=0
is_2partitioned=0;
require_unmounted=1
dont_ask=1
bMounted=0

# if number of arguments is less than 2, no hope of 
# doing useful things 
if [ $# -lt 2 ]
  then
	print_usage
	exit 1
fi

while getopts "hukdfFrspa" Option
do
  case $Option in
    h ) print_usage
        exit 0
        ;;
    u ) put_uboot=1
    ;;
    k ) put_kernel=1
    ;;
	d ) put_device_tree=1
	;;
    f ) put_root=1
    ;;
    F ) put_full_root=1
    ;;
	r ) put_rbf=1
	;;
	s ) put_preloader=1
	;;
    p ) put_partition=1
    ;;
	a ) put_all=1
	;;
	* )	print_usage
		exit 0
	;;
  esac
done

# This function tests to see if the given device $1 is
# mounted, as shown in /etc/mtab.
# Return value $bMounted==1 if mounted, zero otherwise.
function is_mounted() {
#	if mount | grep "$1 on" > /dev/null
	if  grep -q -e "^$1.*" /etc/mtab;  
	then
		bMounted=1   
	else
		bMounted=0
	fi

#   echo -e "$1 mounted: $bMounted"
}

function validate_device()
{
    # The disk-name is in $1.
	if [[ ! $1 ]]; then

		print_usage
		exit 1
	fi

	# Disallow the use of sda
	if [[ $1 == *sda* ]]; then
		echo -e "This script will not work on /dev/sda, which is usually a hard disk.\nExitting."
		exit 1
	fi

	# Disallow the use of sdb
	if [[ $1 == *sdb* ]]; then
		echo -e "This script will not work on /dev/sdb, which is usually a hard disk.\nExitting."
		exit 1
	fi

   	if [[ "${#1}" != 3 ]]; then
	    echo "Invalid device name /dev/$1 - you need to specify something like sdb, sdc, etc."
		exit 1
	fi

	# check if we'll need a partition, but don't have one
	if [[ $put_all -eq 0 ]]; then
		if [[ $put_partition -eq 0 ]]; then

			#check partition 1
			validate_partition $1"1"
	
			if [ $is_partitioned -eq 0 ]; then
		    	echo "Missing partition $1 on device $1 - Please run this script with -p option first"
				exit 1
			fi
	
			#check partition 2
			validate_partition $1"2"

			if [ $is_partitioned -eq 0 ]; then
		    echo "Missing partition $1 on device $1 - Please run this script with -p option first"
				exit 1
			fi
		fi
	fi

    echo "Using device /dev/$1"

	# check for mount - set bMounted
	is_mounted $p1
	if [ $bMounted -eq 1 ]; then
		#unmount - unfortunately may take a second
		sudo umount /dev/$1*
	fi
}


function validate_partition()
{

	if ! grep "$1" /proc/partitions > /dev/null; then
		is_partitioned=0
	else
		is_partitioned=1
	fi

}

# Shift out the used-up command-line arguments.
shift $(($OPTIND - 1))

validate_device "$1"
# Remember the device name
p0=/dev/$1
# Construct names for the partitions
p1=/dev/$1"1"
p2=/dev/$1"2"
p3=/dev/$1"3"




# This function partitions uses "sudo fdisk" to partition device "/dev/sdX"
# named by parameter $1 as follows:
#        Device           Size          Id      System
#     /dev/sdX1           All remaining 83      Linux
#	  /dev/sdX2			  1M			a2		
#	  /dev/sdX3			  			a2		
#
# $1 contains the name of the device to partition.

function make_nominal_partition() 
{
    if [[ $DEBUG ]] ;
    then
        WRITE=q
    else
        WRITE=w
    fi

if ! grep "$1"1 /proc/partitions > /dev/null; then
echo "Deleting SDB1"
echo "p
d
1
$WRITE" | sudo fdisk $1
sleep 1
echo "Delete SDB1"
fi

if ! grep "$1"2 /proc/partitions > /dev/null; then
echo "Deleting SDB2"
echo "p
d
2
$WRITE" | sudo fdisk $1
sleep 1
echo "Delete SDB2"
fi

if ! grep "$1"3 /proc/partitions > /dev/null; then
echo "Deleting SDB3"
echo "p
d
3
$WRITE" | sudo fdisk $1
sleep 1
echo "Deleted SDB3"
fi

echo "Partition ${CONST_PT_RFS_NUM} starts at $((${CONST_PT_RFS_OFFSET}/512)) and is +$((${CONST_PT_RFS_SIZE}/1024))K"

echo "Partition ${CONST_PT_LX_NUM} starts at $((${CONST_PT_LX_OFFSET}/512)) and is +$((${CONST_PT_LX_SIZE}/1024))K"

echo "Partition ${CONST_PT_BOOT_NUM} starts at $((${CONST_PT_BOOT_OFFSET}/512)) and is +$((${CONST_PT_BOOT_SIZE}/1024))K"


echo "p
n
p
${CONST_PT_RFS_NUM}
$((${CONST_PT_RFS_OFFSET}/512))
+$((${CONST_PT_RFS_SIZE}/1024))K
t
${CONST_PT_RFS_TYPE}
n
p
${CONST_PT_LX_NUM}
$((${CONST_PT_LX_OFFSET}/512))
+$((${CONST_PT_LX_SIZE}/1024))K
t
${CONST_PT_LX_NUM}
${CONST_PT_LX_TYPE}
n
p
${CONST_PT_BOOT_NUM}
$((${CONST_PT_BOOT_OFFSET}/512))
+$((${CONST_PT_BOOT_SIZE}/1024))K
t
${CONST_PT_BOOT_NUM}
${CONST_PT_BOOT_TYPE}

p
w" 

echo "p
n
p
${CONST_PT_RFS_NUM}
$((${CONST_PT_RFS_OFFSET}/512))
+$((${CONST_PT_RFS_SIZE}/1024))K
t
${CONST_PT_RFS_TYPE}
n
p
${CONST_PT_LX_NUM}
$((${CONST_PT_LX_OFFSET}/512))
+$((${CONST_PT_LX_SIZE}/1024))K
t
${CONST_PT_LX_NUM}
${CONST_PT_LX_TYPE}
n
p
${CONST_PT_BOOT_NUM}
$((${CONST_PT_BOOT_OFFSET}/512))
+$((${CONST_PT_BOOT_SIZE}/1024))K
t
${CONST_PT_BOOT_NUM}
${CONST_PT_BOOT_TYPE}

p
$WRITE" | sudo fdisk $1

sleep 1
sudo partprobe $1
sleep 1
$DEBUG sudo mkfs.vfat $2
}

# This function installs the preloader (spl) named in $1 to $3 
function install_preloader() {
    echo -e "\nInstalling $1 on $2 "
       echo sudo dd if=$1 of=$2 bs=64k seek=0 
       $DEBUG sudo dd if=$1 of=$2 bs=64k seek=0 
       $DEBUG sync

    echo -e "...finished installing $1 on $2.\n"
}

# This function installs the boot stream named in $1
function install_uboot() {
    echo -e "\nInstalling $1 on $2 "
    echo sudo dd if=$1 of=$2 bs=64k seek=4 
    $DEBUG sudo dd if=$1 of=$2 bs=64k seek=4 
    $DEBUG sync

    echo -e "...finished installing $1 on $2.\n"
}

# Destination is the first parameter, after that is a list of files
function install_files_to_fat_partition() 
{
	DESTINATION="$1"
	shift
   
    $DEBUG sudo mkdir -p $TMP_MOUNTPOINT 
    echo sudo mount -t vfat $DESTINATION $TMP_MOUNTPOINT 
    $DEBUG sudo mount -t vfat $DESTINATION $TMP_MOUNTPOINT 

	# copy as many files as were specified
	while [ $1 ]; do
        	$DEBUG sudo cp $1 $TMP_MOUNTPOINT 
		echo "Installed $1 to FAT Partition $DESTINATION"
		shift
	done

    sync; sync
	sleep 1
    $DEBUG sudo umount $TMP_MOUNTPOINT 
    sync; sync
	sleep 1
    $DEBUG sudo rmdir $TMP_MOUNTPOINT 
}

# This function installs copies filenamed in $1
function copy_file_to_fat() {
    echo -e "\nInstalling $1 on $2 "
   
    $DEBUG sudo mkdir $TMP_MOUNTPOINT
    $DEBUG sudo mount -t vfat $2 $TMP_MOUNTPOINT
    $DEBUG sudo cp $1 $TMP_MOUNTPOINT
	sync; sync;
	sleep 1
    $DEBUG sudo umount $TMP_MOUNTPOINT
	sync; sync;
	sleep 1
    $DEBUG sudo rmdir $TMP_MOUNTPOINT
    echo -e "...finished installing $1 on $2.\n"
	sync; sync
}

# into the device named in partition number.
function install_ext4_rootfs() {
    echo -e "\nFormatting rootfs partition...\n"
    $DEBUG sudo mkfs.ext4 $1
    echo -e "...finished formatting rootfs partition on $2.\n"
	sync; sync
}


# This function installs the rootfs directory named in $1
# into the device named in $2 in partition number $3.
function install_rootfs() {
    echo -e "\nInstalling $1 on $2 "
    echo sudo dd if=$1 of=$2  
    $DEBUG sudo dd if=$1 of=$2 
    $DEBUG sync
    echo -e "...finished installing rootfs on $2.\n"
}

# This function installs the rootfs directory named in $1
# into the device named in $2 in partition number $3.
function install_full_rootfs() {
    $DEBUG sudo mkdir -p zzzsdcard rootfs

    echo -e "\nFormatting rootfs partition $2 as ext4...\n"
    $DEBUG sudo mkfs.ext4 $2
    $DEBUG sudo mount $2 zzzsdcard/
    echo -e "\nInstalling $1 on $2..."
    $DEBUG sudo mount -o loop -t ext4 $1 rootfs
    #$DEBUG sudo tar --numeric-owner -xzvf $1
    echo -e "\nCD to images/rootfs/"
    (   
        cd ./rootfs
        $DEBUG sudo cp -rv * ../zzzsdcard/.
        echo "Copying Files to  sd"
    )   

    if [ -f tools/memtool ] ; then
        $DEBUG sudo cp tools/memtool zzzsdcard/usr/bin/
        echo "Copying memtool file to  sd"
    fi
    # really unmount the partitions
    echo -e "\nUnmount zzzsdcard and rootfs"
    $DEBUG sudo umount -l rootfs zzzsdcard
    while [ true ]; do
        sudo sync
        if grep /dev/loop /proc/mounts; then
                    $DEBUG sudo umount rootfs
            continue # still mounted
        fi
        if grep $2 /proc/mounts; then
                    $DEBUG sudo umount zzzsdcard
            continue # still mounted
        fi
        break
    done
    echo -e "\nCleaning up...\nDelete zzzsdcard and rootfs"
    $DEBUG sudo rm -rf zzzsdcard rootfs
    echo -e "...finished installing rootfs on $2.\n"
}

#############################################
# OK, here it goes.
#############################################
is_mounted $p0

if [[ $require_unmounted -eq 1 ]]; then
    # This script is not running in "expert" mode.
    # We care if the target volume is already mounted.  We don't
    # want to clobber the contents accidentally.
    if [[ $bMounted -eq 1 ]]; then
        # The target volume is indeed already mounted.
        echo
        echo "The requested volume $p0 is already mounted."
        echo "Possibly this volume is a hard disk or some other important medium."
        echo "Therefore, this script will exit and not touch it."
        echo "Please make sure your sd card is unmounted before running this script."
        #exit 1
	echo -e "Are you sure you want to continue? (yes/no): "
    	read op
	if [ ! "$opt" = "yes" ]; then
       	   echo -e "\nAborting..., nothing was altered!"
           exit 1
	else
	   echo "Unmounting $p0 from system"
	   sudo umount $p1 $p2
    	fi

    fi
else
    # This script is running in "expert" mode.
    # We will clobber any contents of the target volume.
    echo "This script is running in expert mode."
fi

# If we got to here, then we are ready to process the target volume.
#echo -e "\nInsert the specified device ($p0) now, if you have not already done so.\n"

# Ask the user if they want to make changes unless they said to skip this.
if [[ $dont_ask -eq 0 ]]; then
    echo -e "\nThis script requires the use of 'sudo' and erases the content of the specified device ($p0)"
    echo -e "Are you sure you want to continue? (yes/no): "
    read opt

    if [ ! "$opt" = "yes" ]; then
        echo -e "\nAborting..., nothing was altered!"
        exit 1
    fi
fi

if [[ $put_all -eq 1 ]]; then
	#if partition doesn't exist, make it

	#check partition 1
	validate_partition $1"1"
	if [ $is_partitioned -eq 0 ]; then
		put_partition=1
	fi

	#check partition 2
	validate_partition $1"2"
	if [ $is_partitioned -eq 0 ]; then
		put_partition=1
	fi

	put_uboot=1
	put_preloader=1
	put_rbf=1
	put_device_tree=1
	put_kernel=1
	put_full_root=1
fi

# make sure the important parts of the build are complete
# this is measured by files present
if [ $put_uboot -eq 1 ]; then
	if [ ! -f "$UBOOT_PATH/$UBOOT_NAME" ]; then
		echo "$UBOOT_PATH/$UBOOT_NAME not built, failing"
		exit 1
	fi
fi

if [ $put_preloader -eq 1 ]; then
	if [ ! -f "$SPL_PATH/$PRELOADER_NAME" ]; then

		echo "$SPL_PATH/$PRELOADER_NAME not built, failing"
		exit 1
	fi
fi

if [ $put_rbf -eq 1 ]; then
	if [ ! -f "$RBF_PATH/$FPGA_BIN_NAME" ]; then
		echo "$RBF_PATH/$FPGA_BIN_NAME not built, failing"
		exit 1
	fi
fi

if [ $put_device_tree -eq 1 ]; then
	if [ ! -f "$LINUX_PATH/$DTB_NAME" ]; then
		echo "$LINUX_PATH/$DTB_NAME not built, failing"
		exit 1
	fi
fi

if [ $put_kernel -eq 1 ]; then
	if [ ! -f "$LINUX_PATH/$ZIMAGE_NAME" ]; then
		echo "$LINUX_PATH/$ZIMAGE_NAME not built, failing"
		exit 1
	fi
fi

if [ $put_root -eq 1 ]; then
	if [ ! -f "$LINUX_PATH/$ROOTFS_NAME" ]; then
		echo "$LINUX_PATH/$ROOTFS_NAME not built, failing"
		exit 1
	fi
fi

# partition the card if requested
if [[ $put_partition -eq 1 ]]; then
    echo -e "\nPartitioning & Burning File System to SD."

    echo "$p0 and $p1" 
    $DEBUG make_nominal_partition $p0 $p1
    $DEBUG install_ext4_rootfs $p2
fi

# put uboot on the card
if [[ $put_uboot -eq 1 ]]; then
	boot_name="$UBOOT_NAME" #"u-boot.imx" #"u-boot-spl.imx

	$DEBUG install_uboot $UBOOT_PATH/$boot_name $p3 
	
	# Linux may automount /dev/sdX3 at this point, check and unmount if so...
	is_mounted $p3
fi

# put the preloader on the card
if [[ $put_preloader -eq 1 ]]; then
	preloader_name=$PRELOADER_NAME

	$DEBUG install_preloader $SPL_PATH/$preloader_name $p3 
	
	# Linux may automount /dev/sdX3 at this point, check and unmount if so...
	is_mounted $p3
fi

# put RBF on the card
if [[ $put_rbf -eq 1 ]]; then
	rbf_name=$FPGA_BIN_NAME

	$DEBUG copy_file_to_fat $RBF_PATH/$rbf_name $p1
	
	# Linux may automount /dev/sdX3 at this point, check and unmount if so...
	is_mounted $p3
fi

# put the device tree on the card
if [[ $put_device_tree -eq 1 ]]; then
	dtb_name=$DTB_NAME

	$DEBUG copy_file_to_fat $LINUX_PATH/$dtb_name $p1
	
	# Linux may automount /dev/sdX3 at this point, check and unmount if so...
	is_mounted $p3
fi

# put the kernel on the card
if [[ $put_kernel -eq 1 ]]; then
	$DEBUG copy_file_to_fat $LINUX_PATH/$ZIMAGE_NAME $p1
	
	# Linux may automount /dev/sdX3 at this point, check and unmount if so...
	is_mounted $p3
fi

is_mounted $p1
if [[ $bMounted -eq 1 ]] ;
	echo "was mounted"
then
    echo
    echo "$p1 was automounted, unmounting..."
    sudo umount /dev/$1*
fi

if [[ $put_root -eq 1 ]]; then
    install_rootfs "$LINUX_PATH/$ROOTFS_NAME" $p2
fi

if [[ $put_full_root -eq 1 ]]; then
    install_full_rootfs "$LINUX_PATH/$ROOTFS_NAME" $p2
fi



echo -e "\nDone! Plug the SD/MMC card into the board and power-on."

#End

