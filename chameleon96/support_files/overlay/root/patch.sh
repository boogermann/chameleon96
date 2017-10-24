#!/bin/sh

#./brcm_patchram_plus -d --patchram bcm/BCM4343A1_001.002.009.0038.0000_Generic_UART_37_4MHz_wlbga_ref_OTP.hcd --enable_hci --no2bytes --tosleep 1000 /dev/ttymxc6
#echo "./brcm_patchram_plus -d --patchram bcm/BCM4343A1_001.002.009.0038.0000_Generic_UART_37_4MHz_wlbga_ref_OTP.hcd --enable_hci --no2bytes --tosleep 1000 /dev/ttymxc6"
echo "./brcm_patchram_plus -d --patchram /lib/firmware/brcm/4343w.hcd --baudrate 115200 --enable_hci --no2bytes --tosleep 1000 /dev/ttyS1"
./brcm_patchram_plus -d --patchram /lib/firmware/brcm/4343w.hcd --baudrate 115200 --enable_hci --no2bytes --tosleep 1000 /dev/ttyS1

