`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    17:21:58 11/24/05
// Design Name:    
// Module Name:    rxNumCounter
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:   This module only deals with cycles with 64bits
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module rxNumCounter(rxclk, reset, receiving, frame_cnt);
    
	 input rxclk;            //receive clk	 
    input reset;				 //globe reset

    input receiving;	 //start to count	data field

	 output[11:0] frame_cnt;

	 parameter TP =1;

	 // Data counter
    // used in rxReceiveData field, 
    // this counter is used for frames whose length is larger than 64
    // Of course it also count actual bytes of frames whose length is shorter than 64.
    counter data_counter(.clk(rxclk), .reset(reset), .load(~receiving), .en(receiving), .value(frame_cnt));
	 defparam data_counter.WIDTH = 12;

endmodule
