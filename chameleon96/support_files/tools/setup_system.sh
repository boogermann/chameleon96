#!/bin/sh

#
# Copyright 2017, NovTech, Inc.
#

PROJECT_NAME="meerkat96"
SVN_USER="meerkat96"
SVN_PATH="http://novtech.ddns.net/svn/Customer/meerkat96"

if [ -d support_files ]; then
	echo "support_files directory exists, skipping initial setup"
else
	echo "Verifying/Installing dependencies"	
	sudo apt-get install -y ncurses-dev
	sudo apt-get install -y g++
	sudo apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1
	sudo apt-get install -y linux-libc-dev-armhf-cross
	sudo apt-get install -y gcc-multilib
	sudo apt-get install -y build-essential

	echo "Retrieving meerkat96"
	svn checkout $SVN_PATH/support_files --username $SVN_USER 
fi

while true
do
  # (1) prompt user, and read command line argument
	read -p "Configure for buildroot or yocto? (B/Y)?: " answer

  # (2) handle the input we were given
  case $answer in
   [yY]* ) ./support_files/setup_yocto.sh $PROJECT_NAME $SVN_USER $SVN_PATH
           echo "Yocto configuration complete."
           break;;

   [bB]* )  ./support_files/setup_buildroot.sh $PROJECT_NAME $SVN_USER $SVN_PATH
           	echo "Buildroot configuration complete."
			exit;;

   * )     echo "Please enter B or Y";;
  esac
done



