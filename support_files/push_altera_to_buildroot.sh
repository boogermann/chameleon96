#!/bin/bash
#
# This is the first attempt at Altera Embedded Design Suite integration
#
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

echo "Select which sub-directory to push over to buildroot..."

select DIRNAME in hps_isw_handoff/*/ ;
do
    echo "You selected $DIRNAME ($REPLY) "
    break
done

echo "Executing: bsp-create-settings --type spl --bsp-dir tmp_EDS --settings tmp_EDS/settings.bsp --preloader-settings-dir $DIRNAME "

#
bsp-create-settings --type spl --bsp-dir tmp_EDS --settings tmp_EDS/settings.bsp --preloader-settings-dir $DIRNAME

cp tmp_EDS/generated/build.h ../chameleon96/build/uboot-custom/board/altera/socfpga/build.h
cp tmp_EDS/generated/iocsr_config_cyclone5.c ../chameleon96/build/uboot-custom/board/altera/socfpga/iocsr_config_cyclone5.c
cp tmp_EDS/generated/iocsr_config_cyclone5.h ../chameleon96/build/uboot-custom/board/altera/socfpga/iocsr_config_cyclone5.h
cp tmp_EDS/generated/reset_config.h ../chameleon96/build/uboot-custom/board/altera/socfpga/reset_config.h
cp tmp_EDS/generated/pll_config.h ../chameleon96/build/uboot-custom/board/altera/socfpga/pll_config.h
cp tmp_EDS/generated/pinmux_config_cyclone5.c ../chameleon96/build/uboot-custom/board/altera/socfpga/pinmux_config_cyclone5.c
cp tmp_EDS/generated/pinmux_config.h ../chameleon96/build/uboot-custom/board/altera/socfpga/pinmux_config.h
cp tmp_EDS/generated/sdram/sdram_config.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sdram_config.h
cp $DIRNAME/alt_types.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/alt_types.h
cp $DIRNAME/sdram_io.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sdram_io.h
cp $DIRNAME/sequencer_auto_ac_init.c ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer_auto_ac_init.c
cp $DIRNAME/sequencer_auto.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer_auto.h
cp $DIRNAME/sequencer_auto_inst_init.c ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer_auto_inst_init.c
cp $DIRNAME/sequencer.c ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer.c
cp $DIRNAME/sequencer_defines.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer_defines.h
cp $DIRNAME/sequencer.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/sequencer.h
cp $DIRNAME/system.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/system.h
cp $DIRNAME/tclrpt.c ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/tclrpt.c
cp $DIRNAME/tclrpt.h ../chameleon96/build/uboot-custom/board/altera/socfpga/sdram/tclrpt.h

echo "Altera customizations pushed to NovTech Buildroot Uboot"
