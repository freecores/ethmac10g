`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    21:23:10 11/21/05
// Design Name:    
// Module Name:    rxLenTypChecker
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:	Length/Type:
// 1. <64:  Length, we should remove PAD
// 2. >=64, <= 1518:	Length, valid frame, we don't need remove PAD(0x2E, 0x5DC)
// 3. >=1518: <9k+18: Length, jumbo frame, if supported (0x5DC, 0x2400)
//	4. >9k+18, = 0x8100: Type, Tagged frame
// 5. >9k+18, = 0x8808: Type, pause frame


////////////////////////////////////////////////////////////////////////////////


`define MAX_VALID_LENGTH 12'h0be
`define MAX_VALID_BITS_MORE 3'h6
`define MAX_TAG_LENGTH 12'h0bf
`define MAX_TAG_BITS_MORE 3'h2
`define MAX_JUMBO_LENGTH 12'h466

`define MIN_VALID_LENGTH 8'h08;


module rxLenTypChecker(rxclk, reset, get_terminator, terminator_location, jumbo_enable, tagged_frame, 
       frame_cnt, vlan_enable,length_error);
    	 
	 input  rxclk;
	 input  reset;
    input  jumbo_enable; //Enable jumbo frame recieving
	 input  vlan_enable;  //VLAN mode enable bit
    input  tagged_frame;	 //number of 64bits DATA field of tagged frame contains
	 input  get_terminator;
	 input[11:0] frame_cnt; 
	 input[2:0] terminator_location;

	 output length_error;

	 parameter TP =1 ;

	 reg [2:0]location_reg;
	 always@(posedge rxclk or posedge reset)begin
	       if (reset) 
			    location_reg <=#TP 0;
			 else if(get_terminator)
			    location_reg <=#TP terminator_location;
			 else 
			    location_reg <=#TP location_reg;
	 end

	 reg length_error;
	 always@(posedge rxclk or posedge reset)begin
	       if(reset) 
			    length_error <=#TP 1'b0;
			 else if(tagged_frame & vlan_enable) begin
			     if ((frame_cnt == `MAX_TAG_LENGTH) & (location_reg > `MAX_TAG_BITS_MORE))
				     length_error <=#TP 1'b1;
				  else if ((frame_cnt > `MAX_TAG_LENGTH) & ~jumbo_enable)
				     length_error <=#TP 1'b1;
              else if(frame_cnt > `MAX_JUMBO_LENGTH)
				     length_error <=#TP 1'b1;
				  else
				     length_error <=#TP 1'b0;
			 end
			 else begin
				  if ((frame_cnt == `MAX_VALID_LENGTH) & (location_reg > `MAX_VALID_BITS_MORE))
			        length_error <=#TP 1'b1;
			     else if((frame_cnt > `MAX_VALID_LENGTH) & ~jumbo_enable) 
			        length_error <=#TP 1'b1;
              else if(frame_cnt > `MAX_JUMBO_LENGTH)
				     length_error <=#TP 1'b1;
              else
			        length_error <=#TP 1'b0;
			 end
	 end
			    
	 
endmodule
