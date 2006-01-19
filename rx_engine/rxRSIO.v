`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    09:22:59 12/22/05
// Design Name:    
// Module Name:    rxRSIO
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
`define SEQUENCE 8'h59
`define START  8'hdf
`define PREAMBLE 8'h55
module rxRSIO(rxclk, rxclk_2x, reset, rxd_in, rxc_in, rxd64, rxc8, local_fault, remote_fault);
    input rxclk;
	 input rxclk_2x;
	 input reset;
    input [31:0] rxd_in;
    input [3:0] rxc_in;			 
    output [63:0] rxd64;
    output [7:0] rxc8;
	 output local_fault;
	 output remote_fault;

	 parameter TP =1;

	 wire local_fault, remote_fault;
	 wire get_align, get_seq;

    assign get_align = ((rxd_in[7:0]==`START) & rxc_in[0]) & ((rxd_in[15:8]==`PREAMBLE) & ~rxc_in[1]);
	 assign get_seq = (rxd_in[7:0] == `SEQUENCE) & (rxd_in[29:8] == 0) & (rxc_in[3:0]== 4'h8) & rxd_in[31];
    assign local_fault = get_seq & ~rxd_in[30];
    assign remote_fault = get_seq & rxd_in[30];
	 
	 wire[7:0] rxc8_in_tmp;
	 wire[63:0]rxd64_in_tmp;
	 reg ddr_read_en;
	 always@(posedge rxclk_2x or posedge reset) begin
	       if (reset)
			    ddr_read_en<=#TP 1;
			 else if (get_align)
			    ddr_read_en <=#TP 1;
			 else
			    ddr_read_en<=#TP ~ddr_read_en;
	 end

//rxd ddr io registers
FDCE rxd64_in_0 (.Q(rxd64_in_tmp[0]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[0]));    defparam rxd64_in_0.INIT = 1'b0;
FDCE rxd64_in_1 (.Q(rxd64_in_tmp[1]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[1]));	   defparam rxd64_in_1.INIT = 1'b0;
FDCE rxd64_in_2 (.Q(rxd64_in_tmp[2]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[2]));		defparam rxd64_in_2.INIT = 1'b0;
FDCE rxd64_in_3 (.Q(rxd64_in_tmp[3]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[3]));		defparam rxd64_in_3.INIT = 1'b0;
FDCE rxd64_in_4 (.Q(rxd64_in_tmp[4]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[4]));		defparam rxd64_in_4.INIT = 1'b0;
FDCE rxd64_in_5 (.Q(rxd64_in_tmp[5]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[5]));		defparam rxd64_in_5.INIT = 1'b0;
FDCE rxd64_in_6 (.Q(rxd64_in_tmp[6]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[6]));		defparam rxd64_in_6.INIT = 1'b0;
FDCE rxd64_in_7 (.Q(rxd64_in_tmp[7]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[7]));		defparam rxd64_in_7.INIT = 1'b0;
FDCE rxd64_in_8 (.Q(rxd64_in_tmp[8]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[8]));	defparam rxd64_in_8.INIT = 1'b0;
FDCE rxd64_in_9 (.Q(rxd64_in_tmp[9]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[9]));	defparam rxd64_in_9.INIT = 1'b0;
FDCE rxd64_in_10 (.Q(rxd64_in_tmp[10]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[10]));	defparam rxd64_in_10.INIT = 1'b0;
FDCE rxd64_in_11 (.Q(rxd64_in_tmp[11]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[11]));	defparam rxd64_in_11.INIT = 1'b0;
FDCE rxd64_in_12 (.Q(rxd64_in_tmp[12]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[12]));	defparam rxd64_in_12.INIT = 1'b0;
FDCE rxd64_in_13 (.Q(rxd64_in_tmp[13]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[13]));	defparam rxd64_in_13.INIT = 1'b0;
FDCE rxd64_in_14 (.Q(rxd64_in_tmp[14]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[14]));	defparam rxd64_in_14.INIT = 1'b0;
FDCE rxd64_in_15 (.Q(rxd64_in_tmp[15]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[15]));	defparam rxd64_in_15.INIT = 1'b0;
FDCE rxd64_in_16 (.Q(rxd64_in_tmp[16]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[16]));	defparam rxd64_in_16.INIT = 1'b0;
FDCE rxd64_in_17 (.Q(rxd64_in_tmp[17]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[17]));	defparam rxd64_in_17.INIT = 1'b0;
FDCE rxd64_in_18 (.Q(rxd64_in_tmp[18]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[18]));	defparam rxd64_in_18.INIT = 1'b0;
FDCE rxd64_in_19 (.Q(rxd64_in_tmp[19]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[19]));	defparam rxd64_in_19.INIT = 1'b0;
FDCE rxd64_in_20 (.Q(rxd64_in_tmp[20]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[20]));	defparam rxd64_in_20.INIT = 1'b0;
FDCE rxd64_in_21 (.Q(rxd64_in_tmp[21]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[21]));	defparam rxd64_in_21.INIT = 1'b0;
FDCE rxd64_in_22 (.Q(rxd64_in_tmp[22]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[22]));	defparam rxd64_in_22.INIT = 1'b0;
FDCE rxd64_in_23 (.Q(rxd64_in_tmp[23]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[23]));	defparam rxd64_in_23.INIT = 1'b0;
FDCE rxd64_in_24 (.Q(rxd64_in_tmp[24]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[24]));	defparam rxd64_in_24.INIT = 1'b0;
FDCE rxd64_in_25 (.Q(rxd64_in_tmp[25]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[25]));	defparam rxd64_in_25.INIT = 1'b0;
FDCE rxd64_in_26 (.Q(rxd64_in_tmp[26]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[26]));	defparam rxd64_in_26.INIT = 1'b0;
FDCE rxd64_in_27 (.Q(rxd64_in_tmp[27]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[27]));	defparam rxd64_in_27.INIT = 1'b0;
FDCE rxd64_in_28 (.Q(rxd64_in_tmp[28]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[28]));	defparam rxd64_in_28.INIT = 1'b0;
FDCE rxd64_in_29 (.Q(rxd64_in_tmp[29]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[29]));	defparam rxd64_in_29.INIT = 1'b0;
FDCE rxd64_in_30 (.Q(rxd64_in_tmp[30]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[30]));	defparam rxd64_in_30.INIT = 1'b0;
FDCE rxd64_in_31 (.Q(rxd64_in_tmp[31]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxd_in[31]));	defparam rxd64_in_31.INIT = 1'b0;
FDCE rxd64_in_32 (.Q(rxd64_in_tmp[32]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[0]));	defparam rxd64_in_32.INIT = 1'b0;
FDCE rxd64_in_33 (.Q(rxd64_in_tmp[33]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[1]));	defparam rxd64_in_33.INIT = 1'b0;
FDCE rxd64_in_34 (.Q(rxd64_in_tmp[34]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[2]));	defparam rxd64_in_34.INIT = 1'b0;
FDCE rxd64_in_35 (.Q(rxd64_in_tmp[35]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[3]));	defparam rxd64_in_35.INIT = 1'b0;
FDCE rxd64_in_36 (.Q(rxd64_in_tmp[36]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[4]));	defparam rxd64_in_36.INIT = 1'b0;
FDCE rxd64_in_37 (.Q(rxd64_in_tmp[37]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[5]));	defparam rxd64_in_37.INIT = 1'b0;
FDCE rxd64_in_38 (.Q(rxd64_in_tmp[38]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[6]));	defparam rxd64_in_38.INIT = 1'b0;
FDCE rxd64_in_39 (.Q(rxd64_in_tmp[39]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[7]));	defparam rxd64_in_39.INIT = 1'b0;
FDCE rxd64_in_40 (.Q(rxd64_in_tmp[40]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[8]));	defparam rxd64_in_40.INIT = 1'b0;
FDCE rxd64_in_41 (.Q(rxd64_in_tmp[41]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[9]));	defparam rxd64_in_41.INIT = 1'b0;
FDCE rxd64_in_42 (.Q(rxd64_in_tmp[42]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[10]));	defparam rxd64_in_42.INIT = 1'b0;
FDCE rxd64_in_43 (.Q(rxd64_in_tmp[43]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[11]));	defparam rxd64_in_43.INIT = 1'b0;
FDCE rxd64_in_44 (.Q(rxd64_in_tmp[44]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[12]));	defparam rxd64_in_44.INIT = 1'b0;
FDCE rxd64_in_45 (.Q(rxd64_in_tmp[45]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[13]));	defparam rxd64_in_45.INIT = 1'b0;
FDCE rxd64_in_46 (.Q(rxd64_in_tmp[46]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[14]));	defparam rxd64_in_46.INIT = 1'b0;
FDCE rxd64_in_47 (.Q(rxd64_in_tmp[47]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[15]));	defparam rxd64_in_47.INIT = 1'b0;
FDCE rxd64_in_48 (.Q(rxd64_in_tmp[48]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[16]));	defparam rxd64_in_48.INIT = 1'b0;
FDCE rxd64_in_49 (.Q(rxd64_in_tmp[49]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[17]));	defparam rxd64_in_49.INIT = 1'b0;
FDCE rxd64_in_50 (.Q(rxd64_in_tmp[50]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[18]));	defparam rxd64_in_50.INIT = 1'b0;
FDCE rxd64_in_51 (.Q(rxd64_in_tmp[51]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[19]));	defparam rxd64_in_51.INIT = 1'b0;
FDCE rxd64_in_52 (.Q(rxd64_in_tmp[52]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[20]));	defparam rxd64_in_52.INIT = 1'b0;
FDCE rxd64_in_53 (.Q(rxd64_in_tmp[53]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[21]));	defparam rxd64_in_53.INIT = 1'b0;
FDCE rxd64_in_54 (.Q(rxd64_in_tmp[54]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[22]));	defparam rxd64_in_54.INIT = 1'b0;
FDCE rxd64_in_55 (.Q(rxd64_in_tmp[55]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[23]));	defparam rxd64_in_55.INIT = 1'b0;
FDCE rxd64_in_56 (.Q(rxd64_in_tmp[56]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[24]));	defparam rxd64_in_56.INIT = 1'b0;
FDCE rxd64_in_57 (.Q(rxd64_in_tmp[57]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[25]));	defparam rxd64_in_57.INIT = 1'b0;
FDCE rxd64_in_58 (.Q(rxd64_in_tmp[58]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[26]));	defparam rxd64_in_58.INIT = 1'b0;
FDCE rxd64_in_59 (.Q(rxd64_in_tmp[59]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[27]));	defparam rxd64_in_59.INIT = 1'b0;
FDCE rxd64_in_60 (.Q(rxd64_in_tmp[60]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[28]));	defparam rxd64_in_60.INIT = 1'b0;
FDCE rxd64_in_61 (.Q(rxd64_in_tmp[61]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[29]));	defparam rxd64_in_61.INIT = 1'b0;
FDCE rxd64_in_62 (.Q(rxd64_in_tmp[62]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[30]));	defparam rxd64_in_62.INIT = 1'b0;
FDCE rxd64_in_63 (.Q(rxd64_in_tmp[63]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxd_in[31]));	defparam rxd64_in_63.INIT = 1'b0;

//rxc ddr io registers
FDCE rxc8_in_0 (.Q(rxc8_in_tmp[0]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxc_in[0]));	 defparam rxc8_in_0.INIT = 1'b0;
FDCE rxc8_in_1 (.Q(rxc8_in_tmp[1]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxc_in[1]));	 defparam rxc8_in_1.INIT = 1'b0;
FDCE rxc8_in_2 (.Q(rxc8_in_tmp[2]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxc_in[2]));	 defparam rxc8_in_2.INIT = 1'b0;
FDCE rxc8_in_3 (.Q(rxc8_in_tmp[3]), .C(rxclk_2x), .CE(~ddr_read_en), .CLR(reset), .D(rxc_in[3]));	 defparam rxc8_in_3.INIT = 1'b0;
FDCE rxc8_in_4 (.Q(rxc8_in_tmp[4]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxc_in[0]));		 defparam rxc8_in_4.INIT = 1'b0;
FDCE rxc8_in_5 (.Q(rxc8_in_tmp[5]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxc_in[1]));		 defparam rxc8_in_5.INIT = 1'b0;
FDCE rxc8_in_6 (.Q(rxc8_in_tmp[6]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxc_in[2]));		 defparam rxc8_in_6.INIT = 1'b0;
FDCE rxc8_in_7 (.Q(rxc8_in_tmp[7]), .C(rxclk_2x), .CE(ddr_read_en), .CLR(reset), .D(rxc_in[3]));		 defparam rxc8_in_7.INIT = 1'b0;
    
	 reg[63:0] rxd64;
	 reg[7:0] rxc8;
	 always@(posedge rxclk or posedge reset) begin
	       if(reset) begin
			    rxc8<=#TP 0;
			    rxd64 <=#TP 0;
			 end
			 else	begin
			    rxc8<=#TP rxc8_in_tmp;
			    rxd64 <=#TP rxd64_in_tmp;
			 end
	 end


endmodule
