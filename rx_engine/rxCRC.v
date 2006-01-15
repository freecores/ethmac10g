`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    19:23:40 12/14/05
// Design Name:    
// Module Name:    rxCRC
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
`define ALLONES 64'hffffffffffffffff
module rxCRC(rxclk, reset, receiving_d2, rxd64_d2, get_terminator, crc_check_invalid, crc_check_valid, wait_crc_check, terminator_location);
    input rxclk;
    input reset;
	 input get_terminator;
    input [63:0] rxd64_d2;
	 input receiving_d2;
	 input wait_crc_check;
	 input [2:0] terminator_location;

	 output crc_check_invalid;
	 output crc_check_valid;

	 parameter TP = 1;

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // Input registers
	 /////////////////////////////////////////////////////////////////////////////////////////////

	 reg[63:0] rxd64_d3;
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)
			   rxd64_d3<=0;
         else
			   rxd64_d3 <=rxd64_d2;
	 end

	 reg get_terminator_d1, get_terminator_d2;
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)begin
			  get_terminator_d1 <=#TP 0;
			  get_terminator_d2 <=#TP 0;
			end   
			else begin
			  get_terminator_d1 <=#TP get_terminator;
			  get_terminator_d2 <=#TP get_terminator_d1;
			end   
	 end

	 reg[5:0] bits_more_reg;
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   bits_more_reg <=#TP 0;
			else if (get_terminator)
			   bits_more_reg <=#TP terminator_location;
			else
			   bits_more_reg <=#TP bits_more_reg;
	 end

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 64bits CRC 
	 // start: crc_valid = 8'hff and receiving_frame = 1
	 // end  : crc_valid != 8'hff or receiving_frame = 0
	 // if bits_more is 0, then CRC check will happen when end happens.
    // else 8bits CRC should begin
	 /////////////////////////////////////////////////////////////////////////////////////////////

    wire [31:0] crc_gen, part_crc;
	
	 crc_fast crc64(.clk(rxclk), .reset(reset), .init(~receiving_d2), .calc(receiving_d2), .d_valid(receiving_d2),
	                .data(rxd64_d3), .crc_reg(crc_gen), .bits_more_reg(bits_more_reg),.part_crc(part_crc));
				 
	 wire[31:0] crc_code;
	 assign crc_code = get_terminator_d2? part_crc: crc_gen;
    ////////////////////////////////////////////////////////////////////////////////////////////
    // CRC check
	 ////////////////////////////////////////////////////////////////////////////////////////////
	 wire crc_check_valid, crc_check_invalid;

	 assign crc_check_valid  = get_terminator_d2 & (crc_code==32'hc704dd7b);
	 assign crc_check_invalid = get_terminator_d2 & (crc_code!=32'hc704dd7b);

endmodule
