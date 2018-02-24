#!/bin/bash
#
ALTERA_HANDOFF=hps_isw_handoff 
result=${PWD##*/} 

if [[ -z "${SOCEDS_DEST_ROOT}" ]]; then
    echo " You must execute this script from within the Intel/Altera "
    echo " Embedded Command Shell environment "
    echo " Look for intelFPGA/17.1/embedded/embedded_command_shell.sh "
    exit
fi

if [ -d "$ALTERA_HANDOFF" ]; then
    echo "Found handoff directory called $ALTERA_HANDOFF"
else
    echo " You must execute this script from the target board support_files"
    echo "directory which contains a 'hps_isw_handoff' directory."
    exit
fi

# work around unqiue project name..
cd ../*/build/uboot-custom
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "change directory failed for '../*/build/uboot-custom' Exiting...."
    exit 254
fi

cd ..
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "change directory failed for 'cd ..' Exiting...."
    exit 254
fi

make CROSS_COMPILE=arm-altera-eabi- -C uboot-custom distclean
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "Make for uboot distclean failed. Exiting...."
    exit 252
fi

cd ..
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "change directory failed for 'cd ..' Exiting...."
    exit 252
fi

if [ -d build ]; then
    echo "Changed directory to correct position."
else
    echo " You must execute this script from the target support_files"
    echo "directory which contains a 'hps_isw_handoff' directory."
    echo "...or possibly some other directory structure issue has occured."
    exit
fi

make -C "../buildroot-2015.08.1/" O="$(pwd)" uboot-reconfigure

cp build/uboot-custom/spl/u-boot-spl.bin ./images/.
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "Copying u-boot-spl.bin to images directory failed. Exiting...."
    exit 254
else
    echo "Copying Buildroot variant u-boot-spl.bin to images directory. ---> OK."
fi

cp build/uboot-custom/u-boot.bin ./images/.
status_flag=$?
if [ $status_flag -ne  0 ]; then
    echo "Copying u-boot.bin to images directory failed. Exiting...."
    exit 253
else
    echo "Copying Buildroot variant u-boot.bin to images directory. ---> OK."
fi

