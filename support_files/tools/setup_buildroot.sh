#!/bin/sh

#
# Copyright 2017, NovTech Inc
#


PROJECT_NAME=$1
SVN_USER=$2
SVN_PATH=$3

echo "Retrieving buildroot 2015.08.01 - this will take a couple minutes, please wait.."
git clone https://git.busybox.net/buildroot/ buildroot-2015.08.01
cd buildroot-2015.08.01
git checkout 2015.08.1
cd ..
echo "Setting up project"
mkdir -p meerkat96

#Copy support files to proper locations
cp support_files/Readme.txt $PROJECT_NAME
cp support_files/buildroot.config $PROJECT_NAME/.config
cp support_files/mk_meerkat_sd $PROJECT_NAME
cp support_files/svn_script $PROJECT_NAME
cp -ar support_files/overlay $PROJECT_NAME

cd $PROJECT_NAME
mkdir build
cd build

echo "Retrieving Kernel and Bootloader"
# get the current bootloader/kernel
svn checkout $SVN_PATH/linux-custom --username $SVN_USER
svn checkout $SVN_PATH/uboot-custom --username $SVN_USER

#make sure buildroot doesn't try to wipe out our source
touch linux-custom/.stamp_downloaded
touch linux-custom/.stamp_extracted
touch uboot-custom/.stamp_downloaded
touch uboot-custom/.stamp_extracted
cd ..

# set up buildroot
echo "configuration complete"
echo "change to the meerkat96 directory and configure buildroot"
echo "then run \"make\" to compile"
echo " "
echo "cd meerkat96"
echo "make -C \"../buildroot-2015.08.01/\" O=\"\$(pwd)\" menuconfig"
echo "make"



