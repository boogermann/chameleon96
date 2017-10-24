Buildroot Example instructions

cd ~/Projects/<project name>

copy the appropriate <boardname>.config to .config

make -C "../buildroot-2015.08.01/" O="$(pwd)" menuconfig

make updates to selected packages, if desired

make

Linux
make linux-rebuild - rebuild linux kernel
make linux-menuconfig - configure linux kernel

UBoot
make uboot-rebuild - rebuild u-boot

Filesystem & associated packages
make 

All output files are located in:
~Projects/<projectname>/images/ folder


