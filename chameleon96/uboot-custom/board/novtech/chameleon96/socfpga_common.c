/*
 *  Copyright Altera Corporation (C) 2013. All rights reserved
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

#include <common.h>
#include <asm/io.h>
#include <asm/arch/system_manager.h>
#include <asm/arch/reset_manager.h>
#include <i2c.h>

DECLARE_GLOBAL_DATA_PTR;

/*
 * Initialization function which happen at early stage of c code
 */
int board_early_init_f(void)
{
#ifdef CONFIG_HW_WATCHDOG
	/* disable the watchdog when entering U-Boot */
	watchdog_disable();
#endif
	/* calculate the clock frequencies required for drivers */
	cm_derive_clocks_for_drivers();
	
	// YHN, turn USER LED 2
	int reg;
	reg = readl(0xFF708000); /* Get the current stae of GPIO0 */
    reg &= 0xFFBFFFFF;       /* Set GPIO 22 (USER 2) Low (on) */
    writel(reg, 0xFF708000);

	return 0;
}

/*
 * Miscellaneous platform dependent initialisations
 */
int board_init(void)
{
	/* adress of boot parameters for ATAG (if ATAG is used) */
	gd->bd->bi_boot_params = 0x00000100;

	/*
	 * reinitialize the global variable for clock value as after
	 * relocation, the global variable are cleared to zeroes
	 */
	cm_derive_clocks_for_drivers();
	return 0;
}

int hdmi_test(void)
{
	unsigned int value;
	puts("Initializing HDMI Transmitter for colorbar test\n");

	//i2c dev 2                                          
	i2c_set_bus_num(2);

	//i2c mw 37 FF.1 87 1    
	value = 0x87;
	i2c_write(0x37, 0xFF, 1, &value, 1);

	// i2c mw 73 FF.1 00 1                                         
	value = 0x00;
	i2c_write(0x73, 0xFF, 1, &value, 1);

	//i2c mw 73 A0.1 06 1                                        
	value = 0x02;
	i2c_write(0x73, 0xA0, 1, &value, 1);

	//i2c mw 73 E4.1 C0 1                                         
	value = 0xC0;
	i2c_write(0x73, 0xE4, 1, &value, 1);

	//i2c mw 73 F0.1 00 1                                         
	value = 0x00;
	i2c_write(0x73, 0xF0, 1, &value, 1);

	//i2c dev 0                                          
	i2c_set_bus_num(0);
}


int hdmi_init(void)
{
	unsigned int value;
	puts("Initializing HDMI Transmitter for 720p\n");

	//i2c dev 2                                          
	i2c_set_bus_num(2);

	//i2c mw 37 FF.1 02 1    
	value = 0x02;
	i2c_write(0x37, 0xFF, 1, &value, 1);

	// i2c mw 73 FF.1 00 1                                         
	value = 0x00;
	i2c_write(0x73, 0xFF, 1, &value, 1);

	//i2c mw 73 A0.1 06 1                                        
	value = 0x02; // 720p 
//	value = 0x06; // 1080p 
	i2c_write(0x73, 0xA0, 1, &value, 1);

	// TBG_CTRL_1 resync method
	//i2c mw 73 CB.1 00 1                                         
	value = 0x00;
	i2c_write(0x73, 0xCB, 1, &value, 1);

	//i2c mw 73 F0.1 00 1                                         
	value = 0x00;
	i2c_write(0x73, 0xF0, 1, &value, 1);

	//i2c mw 73 18.1 FF 1                                         
	value = 0xFF;
	i2c_write(0x73, 0x18, 1, &value, 1);

	//i2c mw 73 19.1 FF 1                                         
	value = 0xFF;
	i2c_write(0x73, 0x19, 1, &value, 1);

	//i2c mw 73 1A.1 FF 1                                         
	value = 0xFF;
	i2c_write(0x73, 0x1A, 1, &value, 1);

	//i2c mw 73 20.1 45 1                                         
	value = 0x45;
	i2c_write(0x73, 0x20, 1, &value, 1);

	//i2c mw 73 21.1 23 1                                         
	value = 0x23;
	i2c_write(0x73, 0x21, 1, &value, 1);

	//i2c mw 73 22.1 01 1                                         
	value = 0x01;
	i2c_write(0x73, 0x22, 1, &value, 1);

        //i2c mw 73 23.1 14 1
        value = 0x14; // turn off horizontal invert
        i2c_write(0x73, 0x23, 1, &value, 1);

	//i2c mw 73 23.1 20 1                                        
	value = 0x20;
	i2c_write(0x37, 0x23, 1, &value, 1);

	//i2c dev 0                                          
	i2c_set_bus_num(0);
}

#ifdef CONFIG_BOARD_LATE_INIT
int board_late_init(void)
{
	int rc = 0;
	int flag1 = 0;
	
	int reg;
	
	int tries = 0;
	int i;
	int error = 0;
	
	/* YHN, add code for:
	1. Put USB PHY in reset
	2. Put USB HUB in reset
	3. Load FPGA       
	4. Release USB PHY/HUB from reset*/	
			
	// Step 1
    printf("Place USBOTG PHY in reset\n");  // Reset on RGMII0_TX_CTL => GPIO09 => bit 9 of GPIO0
	reg = readl(0xFF708000);
	reg |= 0x00000200;              // Set Bit 9 to high, USB PHY is a reset lhigh
	writel(reg, 0xFF708000);
	reg = readl(0xFF708004);
	reg |= 0x00000200;              // Set Bit 9 to high, make it an output
	writel(reg, 0xFF708004);
	
    // Step 2
    printf("Place USB HUB in reset\n");  // nReset on RGMII0_TX_CLK => GPIO00 => bit 0 of GPIO0
	reg = readl(0xFF708000);
	reg &= 0xFFFFFFFE;                   // Set Bit 0 to low, USB HUB is reset low
	writel(reg, 0xFF708000);
	reg = readl(0xFF708004);
	reg |= 0x00000001;                   // Set Bit 0 to high, make it an output
	writel(reg, 0xFF708004);
	
	
    // Step 3
	printf("\n");
	printf("======================\n");
	printf("Loading FPGA .rbf FILE\n");
	printf("======================\n");

	rc = run_command ("fatload mmc 0:1 $fpgadata cv96.rbf ", flag1);

	printf("Read FPGA File Status = 0x%x.\n", rc);

	tries = 1;
	
	while (tries <= 5)
	   {
	   	   rc = run_command ("fpga load 0 $fpgadata $filesize ", flag1);
		   //rc = run_command ("fpga load 0 0x2000000 $filesize ", flag1);
	       if (rc == 0)
		      break;
	        else
		       tries++;
		       
       } 
    printf("Try # = 0x%x.\n", tries);	   
	printf("Programming FPGA Status = 0x%x.\n", rc);
	rc = run_command ("run bridge_enable_handoff ", flag1);			
	printf("HPS2FPGA Bridge Status = 0x%x.\n", rc);
	reg = readl(0xFF200000);
	printf("FPGA HDL ID = 0x%x.\n", reg);	
	
	
	// Step 4
    printf("USBOTG PHY is out of reset\n");  // Reset on RMGII0_TX_CTL => GPIO09 => bit 9 of GPIO0
	reg = readl(0xFF708000);
	reg &= 0xFFFFFDFF;              // Set Bit 1 to low
	writel(reg, 0xFF708000);

    printf("USB HUB is out of reset\n");  // nReset on RGMII0_TX_CLK => GPIO00 => bit 0 of GPIO0
	reg = readl(0xFF708000);
	reg |= 0x00000001;                   // Set Bit 0 to high, USB HUB is reset low
	writel(reg, 0xFF708000);
	
	// YHN, turn USER LED 3
	reg = readl(0xFF708000); /* Get the current stae of GPIO0 */
    	reg &= 0xFDFFFFFF;       /* Set GPIO 25 (USER 3) Low (on) */
    	writel(reg, 0xFF708000);

	hdmi_init();

	return 0;
}
#endif


