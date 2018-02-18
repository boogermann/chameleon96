/*
 *  Copyright Altera Corporation (C) 2012-2013. All rights reserved
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms and conditions of the GNU General Public License,
 *  version 2, as published by the Free Software Foundation.
 *
 *  This program is distributed in the hope it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define CONFIG_SOCFPGA_CHAMELEON96 

#ifndef __CONFIG_H
#define __CONFIG_H

#include "../../board/novtech/chameleon96/build.h"
#include "../../board/novtech/chameleon96/pinmux_config.h"
#include "../../board/novtech/chameleon96/pll_config.h"
#include "../../board/novtech/chameleon96/sdram/sdram_config.h"
#include "../../board/novtech/chameleon96/reset_config.h"
#include "chameleon96_common.h"
#ifdef CONFIG_SPL_BUILD
#include "../../board/novtech/chameleon96/iocsr_config_chameleon96.h"
#endif

/*
 * Console setup
 */
/* Monitor Command Prompt */
#define CONFIG_SYS_PROMPT		"SOCFPGA_CHAMELEON96 # "

/* EMAC controller and PHY used */
#define CONFIG_EMAC_BASE		CONFIG_EMAC1_BASE
#define CONFIG_EPHY_PHY_ADDR		CONFIG_EPHY1_PHY_ADDR
#define CONFIG_PHY_INTERFACE_MODE	SOCFPGA_PHYSEL_ENUM_RGMII

#define CONFIG_I2C_MULTI_BUS    1
#define CONFIG_SYS_I2C_BUS_MAX 4

#define CONFIG_SYS_I2C_BASE1        SOCFPGA_I2C1_ADDRESS
#define CONFIG_SYS_I2C_BASE2        SOCFPGA_I2C2_ADDRESS
#define CONFIG_SYS_I2C_BASE3        SOCFPGA_I2C3_ADDRESS

#define CONFIG_SYS_I2C_SPEED1       100000
#define CONFIG_SYS_I2C_SPEED2       100000
#define CONFIG_SYS_I2C_SPEED3       100000

#define CONFIG_SYS_I2C_SLAVE1       0x02
#define CONFIG_SYS_I2C_SLAVE2       0x02
#define CONFIG_SYS_I2C_SLAVE3       0x02

#define CONFIG_SYS_I2C_NOPROBES     { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127 }

/* Define machine type for Cyclone 5 */
#define CONFIG_MACH_TYPE 4251


#endif	/* __CONFIG_H */
