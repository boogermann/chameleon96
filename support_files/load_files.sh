#!/bin/bash

# 
# Run this script from support_files 
# to copy updated .config files and 
# populate files into the overlay
#
#

echo "This script will replace files in your project area."
echo "Please back up any changes you may have made to prevent loss of data"
echo "Press Y-enter to continue, or ctrl-c to stop."

read response

if [ $response == "Y" ] 
then
echo "Copying svn_update"
cp svn_script ../chameleon96
echo "Removing overlay directory"
rm -rf ../chameleon96/overlay
echo "Populating overlay directory"
cp -ar overlay ../chameleon96
echo "Populating buildroot config"
cp buildroot.config ../chameleon96/.config
else
echo "User aborted action"
fi
