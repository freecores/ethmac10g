`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    09:50:39 12/13/05
// Design Name:    
// Module Name:    rxClkgen
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module rxClkgen(rxclk_in, reset, rxclk, rxclk_2x, locked);
    input rxclk_in;
    input reset;
	 output rxclk;
	 output rxclk_2x;
	 output locked;

	 dcm0 rx_dcm(.CLKIN_IN(rxclk_in), 
                .RST_IN(reset), 
                .CLKIN_IBUFG_OUT(), 
                .CLK0_OUT(rxclk), 	
					 .CLK2X_OUT(rxclk_2x), 
                .CLK180_OUT(), 
                .LOCKED_OUT(locked)
					 );

endmodule
