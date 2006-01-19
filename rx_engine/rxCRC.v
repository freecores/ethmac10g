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
module rxCRC(rxclk, reset, receiving_d1, receiving_d2, rxd64_d2, get_terminator, crc_check_invalid, crc_check_valid, wait_crc_check, terminator_location);
    input rxclk;
    input reset;
	 input get_terminator;
    input [63:0] rxd64_d2;
	 input receiving_d2;
	 input receiving_d1;
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
			   rxd64_d3 <={rxd64_d2[7:0],rxd64_d2[15:8],rxd64_d2[23:16],rxd64_d2[31:24],
				            rxd64_d2[39:32],rxd64_d2[47:40],rxd64_d2[55:48],rxd64_d2[63:56]};
	 end

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
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   bytes_cnt <=#TP 0;
			else if (get_terminator)
			   bytes_cnt <=#TP {rxd64_d2[7:0],rxd64_d2[15:8],rxd64_d2[23:16],rxd64_d2[31:24],
				                 rxd64_d2[39:32],rxd64_d2[47:40],rxd64_d2[55:48],rxd64_d2[63:56]};
			else
			   bytes_cnt <=#TP bytes_cnt;
	 end

	 reg[63:0] terminator_data;
	 always@(posedge rxclk or posedge reset) begin
	      if(reset)
			   terminator_data <=#TP 0;
			else if (get_terminator_d1)
			  	terminator_data <=#TP rxd64_d2;
			else
			   terminator_data <=#TP terminator_data;
	 end

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 64bits CRC 
	 // start: crc_valid = 8'hff and receiving_frame = 1
	 // end  : crc_valid != 8'hff or receiving_frame = 0
	 // if bits_more is 0, then CRC check will happen when end happens.
    // else 8bits CRC should begin
	 /////////////////////////////////////////////////////////////////////////////////////////////

    wire [31:0] crc_gen;
	 
	 wire [31:0] crc_byte[6:0];

	 CRC32_D64 crc64(.DATA_IN(rxd64_d3), .CLK(rxclk), .RESET(reset), .START(receiving_d2&receiving_d1), .CRC_OUT(crc_gen), .init(~receiving_d2));

	 crc_bytes crcbytes(.d(terminator_data), .crc_in(crc_gen), .crc_byte1(crc_byte[0]),.crc_byte2(crc_byte[1]),.crc_byte3(crc_byte[2]),
	                    .crc_byte4(crc_byte[3]),.crc_byte5(crc_byte[4]),.crc_byte6(crc_byte[5]),.crc_byte7(crc_byte[6]));			 

	 wire[31:0] crc_code;
	 reg[31:0] crc_part;
	 always@(posedge rxclk or posedge reset) begin
	        if(reset)
			    crc_part <=#TP 0;
			  else
			    case (bytes_cnt) 
					     3'b001: crc_part <=#TP crc_byte[0];
					     3'b010: crc_part <=#TP crc_byte[1];
					     3'b011: crc_part <=#TP crc_byte[2];
					     3'b100: crc_part <=#TP crc_byte[3];
					     3'b101: crc_part <=#TP crc_byte[4];
					     3'b110: crc_part <=#TP crc_byte[5];
					     3'b111: crc_part <=#TP crc_byte[6];
					     3'b000: crc_part <=#TP crc_gen;
				 endcase
	 end

//	 assign crc_code = get_terminator_d2?crc_part:crc_gen;
//	 always @(posedge rxclk or posedge reset) begin
//	        if(reset) 
//			    crc_code <=#TP 0;
//			  else if (get_terminator_d2) 
//			       case (bytes_cnt) 
//					     3'b001: crc_code <=#TP crc_byte[0];
//					     3'b010: crc_code <=#TP crc_byte[1];
//					     3'b011: crc_code <=#TP crc_byte[2];
//					     3'b100: crc_code <=#TP crc_byte[3];
//					     3'b101: crc_code <=#TP crc_byte[4];
//					     3'b110: crc_code <=#TP crc_byte[5];
//					     3'b111: crc_code <=#TP crc_byte[6];
//					     3'b000: crc_code <=#TP crc_gen;
//					 endcase
//			  else 
//			       crc_code <=#TP crc_gen;
//	 end
    ////////////////////////////////////////////////////////////////////////////////////////////
    // CRC check
	 ////////////////////////////////////////////////////////////////////////////////////////////
	 wire crc_check_valid, crc_check_invalid;

	 assign crc_check_valid  = get_terminator_d3 & (crc_part==32'hc704dd7b);
	 assign crc_check_invalid = get_terminator_d3 & (crc_part!=32'hc704dd7b);

endmodule
