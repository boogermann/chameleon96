#!/bin/bash

LINUX_PATH='../../chameleon96/build/linux-custom'

mkdir -p ${LINUX_PATH}/include/config/mmc/sdhci/of/sls
cp sdhc.h ${LINUX_PATH}/include/config/mmc/sdhci/of/sls/sdhc.h

mkdir -p ${LINUX_PATH}/drivers/mmc/host/

cp sdhci-of-slssdhc.o ${LINUX_PATH}/drivers/mmc/host/sdhci-of-slssdhc.o
cp Makefile	${LINUX_PATH}/drivers/mmc/host/Makefile
cp Kconfig ${LINUX_PATH}/drivers/mmc/host/Kconfig


