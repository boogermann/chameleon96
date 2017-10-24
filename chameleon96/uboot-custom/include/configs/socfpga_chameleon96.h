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


/* Define machine type for Cyclone 5 */
#define CONFIG_MACH_TYPE 4251


#endif	/* __CONFIG_H */
