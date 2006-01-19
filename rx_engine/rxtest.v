`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:23:18 12/26/2005
// Design Name:   rxReceiveEngine
// Module Name:   rxtest.v
// Project Name:  ethmac10g
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rxReceiveEngine
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module rxtest_v;

	// Inputs
	reg rxclk_in;
	reg reset_in;
	reg [31:0] rxd_in;
	reg [3:0] rxc_in;
	reg [52:0] cfgRxRegData_in;

	wire rxclk_2x;

	// Outputs
	wire [17:0] rxStatRegPlus;
	wire [63:0] rx_data;
	wire [7:0] rx_data_valid;
	wire rx_good_frame;
	wire rx_bad_frame;
	wire [2:0] rxCfgofRS;
	wire [1:0] rxTxLinkFault;
	wire reset_out;

	// Instantiate the Unit Under Test (UUT)
	rxReceiveEngine uut (
		.rxclk_in(rxclk_in), 
		.reset_in(reset_in),
		.rxclk_2x(rxclk_2x),
		.reset_out(reset_out), 
		.rxd_in(rxd_in), 
		.rxc_in(rxc_in), 
		.rxStatRegPlus(rxStatRegPlus), 
		.cfgRxRegData_in(cfgRxRegData_in), 
		.rx_data(rx_data), 
		.rx_data_valid(rx_data_valid), 
		.rx_good_frame(rx_good_frame), 
		.rx_bad_frame(rx_bad_frame), 
		.rxCfgofRS(rxCfgofRS), 
		.rxTxLinkFault(rxTxLinkFault)
	);

	initial begin
		// Initialize Inputs
		rxclk_in = 0;
		rxd_in = 0;
		rxc_in = 0;
		cfgRxRegData_in = 0;
		cfgRxRegData_in[35] = 1'b1;//recv_enable
		cfgRxRegData_in[36] = 1'b1;//vlan enable
		cfgRxRegData_in[34] = 1'b0;//inband fcs
		cfgRxRegData_in[52:37] = 16'h4e94;
		cfgRxRegData_in[31:0]=32'h47f90300;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end

	wire [31:0] testvector[95:0];
	wire [3:0] testvector1[95:0];

	wire [31:0] trueframe1[21:0];
	wire [3:0] trueframe2[21:0];

assign testvector[0]=32'h555555df;
assign testvector[1]=32'hd5555555;	
assign testvector[2]=32'h47f90300;
assign testvector[3]=32'h0b004e94;
assign testvector[4]=32'hf7a0021f;
assign testvector[5]=32'h00a20010;
assign testvector[6]=32'h3d3c2680;
assign testvector[7]=32'h888c0000;
assign testvector[8]=32'ha1db65cc;
assign testvector[9]=32'h2850a414;
assign testvector[10]=32'h02f89650;
assign testvector[11]=32'h0a8005f0;
assign testvector[12]=32'h8040fe3f;
assign testvector[13]=32'h2ee40000;
assign testvector[14]=32'h6ceea484;
assign testvector[15]=32'h1c158c97;
assign testvector[16]=32'hb2caadb3;
assign testvector[17]=32'hc9498324;
assign testvector[18]=32'hafabaa1f;
assign testvector[19]=32'hd0b3567d;
assign testvector[20]=32'hc7ecf78f;
assign testvector[21]=32'hb84bde8b;
assign testvector[22]=32'h586af26c;
assign testvector[23]=32'haa3c3a94;
assign testvector[24]=32'hcc09ce77;
assign testvector[25]=32'ha5eed376;
assign testvector[26]=32'h03df2904;
assign testvector[27]=32'h265e28c9;
assign testvector[28]=32'h3770189f;
assign testvector[29]=32'h97eacc54;
assign testvector[30]=32'hc23fb610;
assign testvector[31]=32'hfe15e244;
assign testvector[32]=32'hc14de056;
assign testvector[33]=32'h02ee7034;
assign testvector[34]=32'h03659484;
assign testvector[35]=32'h4a9abae8;
assign testvector[36]=32'h918f6ed4;
assign testvector[37]=32'h3d34d604;
assign testvector[38]=32'h9a729914;
assign testvector[39]=32'haf0205c7;
assign testvector[40]=32'h4cc098d5;
assign testvector[41]=32'hc7e2acfc;
assign testvector[42]=32'h8a19bf8e;
assign testvector[43]=32'hd7639bda;
assign testvector[44]=32'hd1fb311e;
assign testvector[45]=32'ha238c4d9;
assign testvector[46]=32'hc9bdcd00;
assign testvector[47]=32'h21ada082;
assign testvector[48]=32'h3a66571f;
assign testvector[49]=32'h74ee977c;
assign testvector[50]=32'h7cb0e7f1;
assign testvector[51]=32'he63a2e50;
assign testvector[52]=32'hfb43b6ca;
assign testvector[53]=32'h0d63c968;
assign testvector[54]=32'h958185a0;
assign testvector[55]=32'hb7262b2a;
assign testvector[56]=32'ha0018bed;
assign testvector[57]=32'h91e62f95;
assign testvector[58]=32'h3ac7ac7e;
assign testvector[59]=32'hea2a392e;
assign testvector[60]=32'h4b6570d2;
assign testvector[61]=32'h2f8c5bdc;
assign testvector[62]=32'h24f3ea6c;
assign testvector[63]=32'h2f6555fb;
assign testvector[64]=32'hefdd06dd;
assign testvector[65]=32'haa043ab2;
assign testvector[66]=32'hede72cc6;
assign testvector[67]=32'h0515433a;
assign testvector[68]=32'h31a8eba8;
assign testvector[69]=32'h413537cb;
assign testvector[70]=32'h5fbe358c;
assign testvector[71]=32'hc3aab4e6;
assign testvector[72]=32'h4070e288;
assign testvector[73]=32'h87b6268a;
assign testvector[74]=32'h982b2629;
assign testvector[75]=32'h4b6296c9;
assign testvector[76]=32'h1986ac34;
assign testvector[77]=32'hb5a4b1ea;
assign testvector[78]=32'hfa3120b2;
assign testvector[79]=32'hd4487395;
assign testvector[80]=32'hfb9a1667;
assign testvector[81]=32'he4b132ec;
assign testvector[82]=32'hc46ea10d;
assign testvector[83]=32'hb70ea618;
assign testvector[84]=32'h79b254de;
assign testvector[85]=32'hfe9a53c0;
assign testvector[86]=32'hd9e83015;
assign testvector[87]=32'h0097f445;
assign testvector[88]=32'he209598f;
assign testvector[89]=32'h07aa176d;
assign testvector[90]=32'hafb00462;
assign testvector[91]=32'h2b2feabf;
assign testvector[92]=32'h9177bbd2;
assign testvector[93]=32'h949442cf;
assign testvector[94]=32'h9379c09a;
assign testvector[95]=32'h07bfe128;

assign testvector1[0]=4'h1;
assign testvector1[1]=4'h0;
assign testvector1[2]=4'h0;
assign testvector1[3]=4'h0;
assign testvector1[4]=4'h0;
assign testvector1[5]=4'h0;
assign testvector1[6]=4'h0;
assign testvector1[7]=4'h0;
assign testvector1[8]=4'h0;
assign testvector1[9]=4'h0;
assign testvector1[10]=4'h0;
assign testvector1[11]=4'h0;
assign testvector1[12]=4'h0;
assign testvector1[13]=4'h0;
assign testvector1[14]=4'h0;
assign testvector1[15]=4'h0;
assign testvector1[16]=4'h0;
assign testvector1[17]=4'h0;
assign testvector1[18]=4'h0;
assign testvector1[19]=4'h0;
assign testvector1[20]=4'h0;
assign testvector1[21]=4'h0;
assign testvector1[22]=4'h0;
assign testvector1[23]=4'h0;
assign testvector1[24]=4'h0;
assign testvector1[25]=4'h0;
assign testvector1[26]=4'h0;
assign testvector1[27]=4'h0;
assign testvector1[28]=4'h0;
assign testvector1[29]=4'h0;
assign testvector1[30]=4'h0;
assign testvector1[31]=4'h0;
assign testvector1[32]=4'h0;
assign testvector1[33]=4'h0;
assign testvector1[34]=4'h0;
assign testvector1[35]=4'h0;
assign testvector1[36]=4'h0;
assign testvector1[37]=4'h0;
assign testvector1[38]=4'h0;
assign testvector1[39]=4'h0;
assign testvector1[40]=4'h0;
assign testvector1[41]=4'h0;
assign testvector1[42]=4'h0;
assign testvector1[43]=4'h0;
assign testvector1[44]=4'h0;
assign testvector1[45]=4'h0;
assign testvector1[46]=4'h0;
assign testvector1[47]=4'h0;
assign testvector1[48]=4'h0;
assign testvector1[49]=4'h0;
assign testvector1[50]=4'h0;
assign testvector1[51]=4'h0;
assign testvector1[52]=4'h0;
assign testvector1[53]=4'h0;
assign testvector1[54]=4'h0;
assign testvector1[55]=4'h0;
assign testvector1[56]=4'h0;
assign testvector1[57]=4'h0;
assign testvector1[58]=4'h0;
assign testvector1[59]=4'h0;
assign testvector1[60]=4'h0;
assign testvector1[61]=4'h0;
assign testvector1[62]=4'h0;
assign testvector1[63]=4'h0;
assign testvector1[64]=4'h0;
assign testvector1[65]=4'h0;
assign testvector1[66]=4'h0;
assign testvector1[67]=4'h0;
assign testvector1[68]=4'h0;
assign testvector1[69]=4'h0;
assign testvector1[70]=4'h0;
assign testvector1[71]=4'h0;
assign testvector1[72]=4'h0;
assign testvector1[73]=4'h0;
assign testvector1[74]=4'h0;
assign testvector1[75]=4'h0;
assign testvector1[76]=4'h0;
assign testvector1[77]=4'h0;
assign testvector1[78]=4'h0;
assign testvector1[79]=4'h0;
assign testvector1[80]=4'h0;
assign testvector1[81]=4'h0;
assign testvector1[82]=4'h0;
assign testvector1[83]=4'h0;
assign testvector1[84]=4'h0;
assign testvector1[85]=4'h0;
assign testvector1[86]=4'h0;
assign testvector1[87]=4'h0;
assign testvector1[88]=4'h0;
assign testvector1[89]=4'h0;
assign testvector1[90]=4'h0;
assign testvector1[91]=4'h0;
assign testvector1[92]=4'h0;
assign testvector1[93]=4'h0;
assign testvector1[94]=4'h0;
assign testvector1[95]=4'hc;

	assign trueframe2[0] = 4'hf;
	assign trueframe2[1] = 4'hf;
	assign trueframe2[2] = 4'h1;
	assign trueframe2[3] = 4'h0;
	assign trueframe2[4] = 4'h0;
	assign trueframe2[5] = 4'h0;
	assign trueframe2[6] = 4'h0;
	assign trueframe2[7] = 4'h0;
	assign trueframe2[8] = 4'h0;
	assign trueframe2[9] = 4'h0;
	assign trueframe2[10] = 4'h0;
	assign trueframe2[11] = 4'h0;
	assign trueframe2[12] = 4'h0;
	assign trueframe2[13] = 4'h0;
	assign trueframe2[14] = 4'h0;
	assign trueframe2[15] = 4'h0;
	assign trueframe2[16] = 4'h0;
	assign trueframe2[17] = 4'h0;
	assign trueframe2[18] = 4'h0;
	assign trueframe2[19] = 4'h0;
	assign trueframe2[20] = 4'hf;
	assign trueframe2[21] = 4'hf;

	initial begin
	  reset_in = 1;
	  #100
	  reset_in = 0;
	end
	always rxclk_in =#10 ~rxclk_in;

	reg [7:0]i;
	always@(posedge rxclk_2x or posedge reset_out) begin
	      if (reset_out) begin
			   i <= 0;
				rxd_in <=0;
				rxc_in <=0;
   		end
			else begin
			   i <= i+1;
				if(i==97)
				  i<=0;
//				rxd64_in <=taggedvector1[i];
//	      	rxc8_in <=taggedvector2[i];
//				rxd64_in <=testvector1[i];
//	      	rxc8_in <=testvector2[i];
				rxd_in <=testvector[i];
	      	rxc_in <=testvector1[i];
//				rxd64_in <=smallvector1[i];
//	      	rxc8_in <=smallvector2[i];
			end
	end

      
endmodule

