`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    10:54:17 11/21/05
// Design Name:    
// Module Name:    rxDAchecker
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




module rxDAchecker(rxclk,reset,local_invalid, broad_valid, multi_valid, MAC_Addr, da_addr);
	 input  rxclk;
	 input  reset;

    output local_invalid;
	 output broad_valid;
	 output multi_valid;

    input [47:0] MAC_Addr;
	 input [47:0] da_addr;

	 parameter Multicast = 48'h0180C2000001;
	 parameter Broadcast = 48'hffffffffffff; 
	 parameter TP = 1;
    
	 reg multi_valid;
	 reg broad_valid;
	 reg local_valid;
    always @(posedge rxclk or posedge reset) begin
	       if (reset) begin
			    multi_valid <=#TP 0;
				 broad_valid <=#TP 0;
				 local_valid <=#TP 0;
			 end
			 else begin
			    multi_valid <=#TP (da_addr==Multicast);
				 broad_valid <=#TP (da_addr==Broadcast);
				 local_valid <=#TP (da_addr==MAC_Addr);
			 end
	 end

	 assign local_invalid = ~local_valid & ~multi_valid & ~broad_valid;

endmodule
