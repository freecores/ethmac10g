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

`define MIN_VALID_LENGTH 8'h08


module rxLenTypChecker(rxclk, reset, get_terminator, terminator_location, jumbo_enable, tagged_frame, 
       frame_cnt, vlan_enable,length_error,large_error, small_error, padded_frame, length_65_127, 
		 length_128_255, length_256_511, length_512_1023, length_1024_max,jumbo_frame);
    	 
	 input  rxclk;
	 input  reset;
    input  jumbo_enable; //Enable jumbo frame recieving
	 input  vlan_enable;  //VLAN mode enable bit
    input  tagged_frame;	 //number of 64bits DATA field of tagged frame contains
	 input  get_terminator;
	 input[11:0] frame_cnt; 
	 input[2:0] terminator_location;

	 output length_error;
	 output large_error;
	 output small_error;
	 output padded_frame;
	 output length_65_127;
	 output length_128_255;
	 output length_256_511;
	 output length_512_1023;
	 output length_1024_max;
	 output jumbo_frame;
	 
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

	 reg large_error;
	 always@(posedge rxclk or posedge reset)begin
	       if(reset) 
			    large_error <=#TP 1'b0;
			 else if(tagged_frame & vlan_enable) begin
			     if ((frame_cnt == `MAX_TAG_LENGTH) & (location_reg > `MAX_TAG_BITS_MORE))
				     large_error <=#TP 1'b1;
				  else if ((frame_cnt > `MAX_TAG_LENGTH) & ~jumbo_enable)
				     large_error <=#TP 1'b1;
              else if(frame_cnt > `MAX_JUMBO_LENGTH)
				     large_error <=#TP 1'b1;
				  else
				     large_error <=#TP 1'b0;
			 end
			 else begin
				  if ((frame_cnt == `MAX_VALID_LENGTH) & (location_reg > `MAX_VALID_BITS_MORE))
			        large_error <=#TP 1'b1;
			     else if((frame_cnt > `MAX_VALID_LENGTH) & ~jumbo_enable) 
			        large_error <=#TP 1'b1;
              else if(frame_cnt > `MAX_JUMBO_LENGTH)
				     large_error <=#TP 1'b1;
              else
			        large_error <=#TP 1'b0;
			 end
	 end

	 reg small_error;
	 always@(posedge rxclk or posedge reset) begin
	       if(reset)
			   small_error <=#TP 0;
			 else 
			   small_error <=#TP get_terminator & (frame_cnt< `MIN_VALID_LENGTH);
	 end

 	 wire length_error;
	 assign length_error = small_error | large_error;
			     
	 /////////////////////////////////////////////////
	 // Statistic signals
	 /////////////////////////////////////////////////		    
	 									  
	 ///////////////////////////////////
	 // 64byte frame received OK
	 ///////////////////////////////////

	 reg padded_frame;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    padded_frame <=#TP 0;
			  else
			    padded_frame <=#TP get_terminator & (frame_cnt==`MIN_VALID_LENGTH);
	 end

	 ///////////////////////////////////
	 // 65-127 byte Frame Received OK
	 ///////////////////////////////////

	 reg length_65_127;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    length_65_127 <=#TP 0;
			  else
			    length_65_127 <=#TP get_terminator & (frame_cnt>`MIN_VALID_LENGTH) & (frame_cnt <=127);
	 end

	 ///////////////////////////////////
	 // 128-255 byte Frame Received OK
	 ///////////////////////////////////

	 reg length_128_255;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    length_128_255 <=#TP 0;
			  else
			    length_128_255 <=#TP get_terminator & (frame_cnt>128) & (frame_cnt <=255);
	 end

	 ///////////////////////////////////
	 // 256-511 byte Frame Received OK
	 ///////////////////////////////////

	 reg length_256_511;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    length_256_511 <=#TP 0;
			  else
			    length_256_511 <=#TP get_terminator & (frame_cnt>256) & (frame_cnt <=511);
	 end

	 ///////////////////////////////////
	 // 512-1023 byte Frame Received OK
	 ///////////////////////////////////

	 reg length_512_1023;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    length_512_1023 <=#TP 0;
			  else
			    length_512_1023 <=#TP get_terminator & (frame_cnt>512) & (frame_cnt <=1023);
	 end

	 ///////////////////////////////////
	 // 1024-max byte Frame Received OK
	 ///////////////////////////////////

	 reg length_1024_max;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    length_1024_max <=#TP 0;
			  else
			    length_1024_max <=#TP get_terminator & (frame_cnt>1024) & (frame_cnt <=`MAX_VALID_LENGTH);
	 end

	 //////////////////////////////////////////////
	 // Count for Control Frames Received OK
	 //////////////////////////////////////////////
	 //how to indicate a control frame(not clearly specificated in 802.3

	 ///////////////////////////////////////////////
	 // Count for Oversize Frames Received OK
	 ///////////////////////////////////////////////
	 
	 reg jumbo_frame;
	 always@(posedge rxclk or posedge reset) begin
	       if(reset)
				jumbo_frame <=#TP 0;
			 else
			   jumbo_frame <=#TP get_terminator & jumbo_enable & (frame_cnt > `MAX_VALID_LENGTH) & (frame_cnt < `MAX_JUMBO_LENGTH);
	 end

endmodule
