`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    19:22:25 12/14/05
// Design Name:    
// Module Name:    rxStatModule
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
module rxStatModule(rxclk, reset, good_frame_get,crc_check_invalid, large_error, small_error,
                    receiving, padded_frame, pause_frame, broad_valid, multi_valid,
						  length_65_127, length_128_255, length_256_511, length_512_1023, length_1024_max,
						  jumbo_frame,	get_error_code, rxStatRegPlus);

	 input rxclk;
	 input reset;
	 input good_frame_get; 
	 input large_error;
	 input small_error;
	 input crc_check_invalid;
	 input receiving;
	 input padded_frame;
	 input pause_frame;
	 input broad_valid;
	 input multi_valid;
	 input length_65_127;
	 input length_128_255;
	 input length_256_511;
	 input length_512_1023;
	 input length_1024_max;
	 input jumbo_frame;
	 input get_error_code;
	 output [17:0] rxStatRegPlus;

	 parameter TP =1;

	 wire[17:0] rxStatRegPlus_tmp;

	 ////////////////////////////////////////////
	 // Count for Frames Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[0] = good_frame_get;

    ////////////////////////////////////////////
	 // Count for FCS check error
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[1] = crc_check_invalid;

	 ////////////////////////////////////////////
	 // Count for BroadCast Frame Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[2] = broad_valid & good_frame_get;

	 /////////////////////////////////////////////
	 // Count for Multicast Frame Received OK
	 /////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[3] = multi_valid & good_frame_get;

	 ////////////////////////////////////////////
	 // Count for 64 byte Frame Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[4] = padded_frame & good_frame_get;

	 ////////////////////////////////////////////
	 // Count for 65-127 byte Frames Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[5] = length_65_127 & good_frame_get;

	 ////////////////////////////////////////////
	 // Count for 128-255 byte Frames Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[6] = length_128_255 & good_frame_get;

	 ////////////////////////////////////////////
	 // Count for 256-511 byte Frames Received OK
	 ////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[7] = length_256_511 & good_frame_get;

	 //////////////////////////////////////////////
	 // Count for 512-1023 byte Frames Received OK
	 //////////////////////////////////////////////
    assign rxStatRegPlus_tmp[8] = length_512_1023 & good_frame_get;

	 //////////////////////////////////////////////
	 // Count for 1024-1518 byte Frames Received OK
	 //////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[9] = length_1024_max & good_frame_get;

    //////////////////////////////////////////////
	 // Count for Control Frames Received OK
	 //////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[10] = pause_frame & good_frame_get;

	 //////////////////////////////////////////////
	 // Count for Length/Type Out of Range
	 //////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[11] = large_error;

	 //////////////////////////////////////////////
	 // Count for Pause Frames Received OK
	 //////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[12] = pause_frame & good_frame_get;

	 /////////////////////////////////////////////////////////////
	 // Count for Control Frames Received with Unsupported Opcode.
	 /////////////////////////////////////////////////////////////
   // assign rxStatRegPlus_tmp[13] = pause_frame & good_frame_get;

	 ///////////////////////////////////////////////
	 // Count for Oversize Frames Received OK
	 ///////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[14] = jumbo_frame & good_frame_get;

	 ///////////////////////////////////////////////
	 // Count for Undersized Frames Received
	 ///////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[15] = small_error;

	 ///////////////////////////////////////////////
	 // Count for Fragment Frames Received
	 ///////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[16] = receiving & get_error_code;

	 ///////////////////////////////////////////////
	 // Count for Number of Bytes Received
	 ///////////////////////////////////////////////
	 assign rxStatRegPlus_tmp[17] = receiving;

	 reg[17:0] rxStatRegPlus;
	 always@(posedge rxclk or posedge reset) begin
	       if(reset)
			   rxStatRegPlus <=#TP 0;
			 else
			   rxStatRegPlus <=#TP rxStatRegPlus_tmp;
	 end

endmodule
