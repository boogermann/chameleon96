#!/bin/sh

#
# Copyright 2017, NovTech Inc.
#


PROJECT_NAME=$1
SVN_USER=$2
SVN_PATH=$3

echo "setting up project"
mkdir -p $PROJECT_NAME/images
#copy support files to proper locations

#make sure yocto pre-requisites are there
sudo ./support_files/yocto/yocto-packages.sh -d Ubuntu
sudo mkdir /opt/angstrom-v2016.12-yocto2.2
sudo chown -R novtech:novtech /opt/angstrom-v2016.12-yocto2.2
ln -s /opt/angstrom-v2016.12-yocto2.2 $PROJECT_NAME/yocto
mkdir -p $PROJECT_NAME/yocto/layers/manifests/conf
ln -s ~/Projects/support_files/yocto/meta-$PROJECT_NAME $PROJECT_NAME/yocto/layers/meta-$PROJECT_NAME
git config --global user.email "novtech@novtech.com"
git config --global user.name "novtech"
./support_files/yocto/yocto2.2-build  -b $PROJECT_NAME -d $PROJECT_NAME/yocto




