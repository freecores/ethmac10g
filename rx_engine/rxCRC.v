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
module rxCRC(rxclk, reset, receiving_frame, rxd64, end_fcs, crc_code, crc_valid, crc_check_invalid, crc_check_valid, bits_more);
    input rxclk;
    input reset;
	 input end_fcs;
    input [31:0] crc_code;
    input [63:0] rxd64;
    input [7:0] crc_valid;
	 input receiving_frame;
	 input [2:0] bits_more;

	 output crc_check_invalid;
	 output crc_check_valid;

	 parameter TP = 1;

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // Input registers
	 /////////////////////////////////////////////////////////////////////////////////////////////
	
	 wire data_is_64;

	 assign data_is_64 = & crc_valid;

	 reg[31:0] crc_code_reg;
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   crc_code_reg <=#TP 0;
		   else if (end_fcs)
			   crc_code_reg <=#TP crc_code;
			else
			   crc_code_reg <=#TP crc_code_reg;
	 end

	 reg[63:0] data_less_64;
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
            data_less_64 <= #TP 0;
         else if (!data_is_64)
			   data_less_64 <= #TP rxd64;
         else 
			   data_less_64 <= #TP data_less_64;
	 end

	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 64bits CRC 
	 // start: crc_valid = 8'hff and receiving_frame = 1
	 // end  : crc_valid != 8'hff or receiving_frame = 0
	 // if bits_more is 0, then CRC check will happen when end happens.
    // else 8bits CRC should begin
	 /////////////////////////////////////////////////////////////////////////////////////////////
	 
	 wire do_64_crc;
	
	 assign do_64_crc = receiving_frame & data_is_64;

	 wire [31:0] crc_gen;

	 CRC32_D64 crc64(.DATA_IN(rxd64), .CLK(rxclk), .RESET(reset), .START(do_64_crc), .CRC_OUT(crc_gen));
	
	 /////////////////////////////////////////////////////////////////////////////////////////////
	 // 8bits CRC 
	 // start: crc_valid !=8'hff and receiving_frame = 1
	 // end  : cnt == bits_more
	 // CRC check will happen the next cycle when end happens 
	 /////////////////////////////////////////////////////////////////////////////////////////////
	 wire end_8_crc;
	 reg  do_8_crc;
    always@(data_is_64, end_8_crc)	begin
	     if (!data_is_64)
			  do_8_crc <=#TP 1'b1;	 
        else if (end_8_crc)
		     do_8_crc <=#TP 1'b0;
		  else
		     do_8_crc <=#TP do_8_crc;
	 end

	 wire [2:0] cnt;

	 counter crc_8_cnt(.clk(rxclk),.reset(reset), .load(end_8_crc), .en(do_8_crc), .value(cnt));
	 defparam crc_8_cnt.WIDTH = 3;

	 assign end_8_crc = (cnt == bits_more);	

	 wire [7:0]tmp_data[7:0];
	 wire [7:0]rxd8;

	 assign tmp_data[7] = {data_less_64[15],data_less_64[23],data_less_64[31],data_less_64[39],data_less_64[47],data_less_64[55],rxd64[63],1'b0};
	 assign tmp_data[6] = {data_less_64[14],data_less_64[22],data_less_64[30],data_less_64[38],data_less_64[46],data_less_64[54],rxd64[62],1'b0};
	 assign tmp_data[5] = {data_less_64[13],data_less_64[21],data_less_64[29],data_less_64[37],data_less_64[45],data_less_64[53],rxd64[61],1'b0};
	 assign tmp_data[4] = {data_less_64[12],data_less_64[20],data_less_64[28],data_less_64[36],data_less_64[44],data_less_64[52],rxd64[60],1'b0};
	 assign tmp_data[3] = {data_less_64[11],data_less_64[19],data_less_64[27],data_less_64[35],data_less_64[43],data_less_64[51],rxd64[59],1'b0};
	 assign tmp_data[2] = {data_less_64[10],data_less_64[18],data_less_64[26],data_less_64[34],data_less_64[42],data_less_64[50],rxd64[58],1'b0};
	 assign tmp_data[1] = {data_less_64[9],data_less_64[17],data_less_64[25],data_less_64[33],data_less_64[41],data_less_64[49],rxd64[57],1'b0};
	 assign tmp_data[0] = {data_less_64[8],data_less_64[16],data_less_64[24],data_less_64[32],data_less_64[40],data_less_64[48],rxd64[56],1'b0};

	 M8_1E data7(.E(1'b1), .S(cnt), .D(tmp_data[7]), .O(rxd8[7]));
	 M8_1E data6(.E(1'b1), .S(cnt), .D(tmp_data[6]), .O(rxd8[6]));
	 M8_1E data5(.E(1'b1), .S(cnt), .D(tmp_data[5]), .O(rxd8[5]));
	 M8_1E data4(.E(1'b1), .S(cnt), .D(tmp_data[4]), .O(rxd8[4]));
	 M8_1E data3(.E(1'b1), .S(cnt), .D(tmp_data[3]), .O(rxd8[3]));
	 M8_1E data2(.E(1'b1), .S(cnt), .D(tmp_data[2]), .O(rxd8[2]));
	 M8_1E data1(.E(1'b1), .S(cnt), .D(tmp_data[1]), .O(rxd8[1]));
	 M8_1E data0(.E(1'b1), .S(cnt), .D(tmp_data[0]), .O(rxd8[0]));

	 wire [31:0] crc_final;

    CRC32_D8 crc8(.DATA_IN(rxd8), .CLK(rxclk), .RESET(reset), .START(do_8_crc), .LOAD(~do_64_crc), .CRC_IN(crc_gen), .CRC_OUT(crc_final));
					 
    ////////////////////////////////////////////////////////////////////////////////////////////
    // CRC check
	 ////////////////////////////////////////////////////////////////////////////////////////////
	 wire crc_check_valid, crc_check_invalid;

    reg  end_8_crc_d1;
	 always@(posedge rxclk or posedge reset)begin
	       if (reset)
			    end_8_crc_d1<=#TP 0;
          else
			    end_8_crc_d1<=#TP end_8_crc;
	 end

	 assign crc_check_valid  = end_8_crc_d1 & (crc_final==crc_code_reg);
	 assign crc_check_invalid = end_8_crc_d1 & ~crc_check_valid;

endmodule
