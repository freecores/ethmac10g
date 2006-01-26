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
module rxCRC(rxclk, reset, receiving, receiving_d1, receiving_d2, CRC_DATA, get_terminator, crc_check_invalid, crc_check_valid, terminator_location);
    input rxclk;
    input reset;
	 input get_terminator;
    input [63:0] CRC_DATA;
	 input receiving;
	 input receiving_d1,receiving_d2;
	 input [2:0] terminator_location;

	 output crc_check_invalid;
	 output crc_check_valid;

	 parameter TP = 1;

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // Input registers
	 /////////////////////////////////////////////////////////////////////////////////////////////

	 reg get_terminator_d1, get_terminator_d2,get_terminator_d3;
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)begin
			  get_terminator_d1 <=#TP 0;
			  get_terminator_d2 <=#TP 0;
			  get_terminator_d3 <=#TP 0;
			end   
			else begin
			  get_terminator_d1 <=#TP get_terminator;
			  get_terminator_d2 <=#TP get_terminator_d1;
			  get_terminator_d3 <=#TP get_terminator_d2;
			end   
	 end

	 reg[2:0] bytes_cnt;
	 reg start_tmp;
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   bytes_cnt <=#TP 0;
			else if (get_terminator)
			   bytes_cnt <=#TP terminator_location;
			else if (start_tmp)
			   bytes_cnt <=#TP bytes_cnt-1;
	 end

	 reg[63:0] terminator_data;
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)
			   terminator_data <=#TP 0;
			else if (get_terminator_d2)
			  	terminator_data <=#TP CRC_DATA;
			else
			   terminator_data <=#TP terminator_data<<8;
	 end
	 
	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 64bits CRC 
	 // start: crc_valid = 8'hff and receiving_frame = 1
	 // end  : crc_valid != 8'hff or receiving_frame = 0
	 // if bits_more is 0, then CRC check will happen when end happens.
    // else 8bits CRC should begin
	 /////////////////////////////////////////////////////////////////////////////////////////////

    wire [31:0] crc_gen;

	 CRC32_D64 crc64(.DATA_IN(CRC_DATA), .CLK(rxclk), .RESET(reset), .START(receiving_d2&receiving_d1), .CRC_OUT(crc_gen), .init(get_terminator_d3));
     
	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 8bits CRC
	 /////////////////////////////////////////////////////////////////////////////////////////////
   
  	 reg[7:0] CRC_DATA_TMP;
    always@(posedge rxclk or posedge reset) begin
	      if(reset)
			  CRC_DATA_TMP <=#TP 0;
			else 
           CRC_DATA_TMP <=#TP terminator_data[63:56];			
    end
    
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)
			  start_tmp <=#TP 0;
			else if (get_terminator_d3)
           start_tmp <=#TP 1'b1;
         else if(bytes_cnt==1)
           start_tmp <=#TP 1'b0;
	 end		  
	 
	 wire[31:0] crc_tmp;
	 CRC32_D8  crc8(.DATA_IN(CRC_DATA_TMP), .CLK(rxclk), .RESET(reset), .START(start_tmp), .LOAD(~start_tmp), .CRC_IN(crc_gen), .CRC_OUT(crc_tmp));		 
	
    ////////////////////////////////////////////////////////////////////////////////////////////
    // CRC check
	 ////////////////////////////////////////////////////////////////////////////////////////////
	 wire crc_check_valid, crc_check_invalid;

	 assign crc_check_valid  = (~bytes_cnt) & (crc_tmp==32'hc704dd7b);
	 assign crc_check_invalid =(~bytes_cnt) & (crc_tmp!=32'hc704dd7b);

endmodule
