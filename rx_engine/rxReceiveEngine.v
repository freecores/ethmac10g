`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    16:35:47 11/21/05
// Design Name:    
// Module Name:    rxReceiveEngine
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
module rxReceiveEngine(rxclk_in, reset_in, rxd_in, rxc_in, rxStatRegPlus,reset_out,
                       cfgRxRegData_in, rx_data, rx_data_valid, rx_good_frame,
                       rx_bad_frame, rxCfgofRS, rxTxLinkFault);
    input rxclk_in;
    input reset_in;
    input [31:0] rxd_in;
    input [3:0] rxc_in;
	 output reset_out;
    output [17:0] rxStatRegPlus;	
    input [64:0] cfgRxRegData_in;
    output [63:0] rx_data;
    output [7:0] rx_data_valid;
    output rx_good_frame;
    output rx_bad_frame;
	 output[2:0] rxCfgofRS;
    output [1:0] rxTxLinkFault;

	 parameter TP =1;

    wire rxclk;
	 wire rxclk_180;
	 wire locked;
	 wire reset_dcm;
	 wire reset;

	 reg [47:0]MAC_Addr;	//MAC Address used in receiving control frame.
    reg      vlan_enable; //VLAN Enable
	 reg      recv_enable; //Receiver Enable
	 reg      inband_fcs;	//In-band FCS Enable, when this bit is '1', the MAC will pass FCS up to client
	 reg      jumbo_enable;//Jumbo Frame Enable
	 reg      recv_rst;		//Receiver reset

	 wire start_da, start_lt;
	 wire tagged_frame;
	 wire pause_frame;
	 wire [47:0] da_addr;
//	 wire [15:0] lt_data;
	 wire [11:0] frame_cnt;
	 wire [2:0]  terminator_location;
	 wire get_sfd,get_error_code,get_terminator, get_terminator_d1;
	 wire receiving;
	 wire receiving_d1,receiving_d2;

	 
	 wire length_error;
	 wire large_error;
	 wire small_error;
	 wire padded_frame;
	 wire length_65_127;
	 wire length_128_255;
	 wire length_256_511;
	 wire length_512_1023;
	 wire length_1024_max;
	 wire jumbo_frame;

	 wire local_invalid;
	 wire broad_valid;
	 wire multi_valid;

	 wire good_frame_get, bad_frame_get;
	 wire wait_crc_check;

	 wire crc_check_valid;
	 wire crc_check_invalid;
	 wire check_reset;

	 wire [1:0]link_fault;

	 //////////////////////////////////////////
	 // Input Registers
	 //////////////////////////////////////////
	 
	 wire [63:0] rxd64;
	 wire [63:0] CRC_DATA;
	 wire [7:0] rxc8;

	 assign rxTxLinkFault = link_fault;
	 //////////////////////////////////////////
	 // Read Receiver Configuration Word
	 //////////////////////////////////////////
	 
	 always@(posedge rxclk or posedge reset)begin
	        if(reset) begin
			     MAC_Addr <= 0;
	           vlan_enable <= 0;
	           recv_enable <= 0;
	           inband_fcs  <= 0;
	           jumbo_enable <= 0;
	           recv_rst <= 0;
			  end
			  else begin
			     MAC_Addr <= cfgRxRegData_in[47:0];
	           vlan_enable <= cfgRxRegData_in[48];
	           recv_enable <= cfgRxRegData_in[49];
	           inband_fcs  <= cfgRxRegData_in[50];
	           jumbo_enable <= cfgRxRegData_in[51];
	           recv_rst <= cfgRxRegData_in[52];
			  end
    end			  
    
	 assign  reset_dcm = reset_in | recv_rst;
	 assign  reset = ~locked;
	 assign  reset_out = reset;
	 
	 /////////////////////////////////////////
	 // Write Configuration Words	of RS 
	 /////////////////////////////////////////

	 assign rxCfgofRS[0] = ~link_fault[0] & link_fault[1]; //get local fault
	 assign rxCfgofRS[1] = link_fault[0] & link_fault[1];  //get remote fault
	 assign rxCfgofRS[2] = locked;  //Receive DCM locked
	 
	 ////////////////////////////////////////
	 // Receive Clock Generator
	 //////////////////////////////////////// 

	 rxClkgen rxclk_gen(.rxclk_in(rxclk_in),
	                    .reset(reset_dcm),
							  .rxclk(rxclk),
							  .rxclk_180(rxclk_180), 
							  .locked(locked)
							  );
	
	 //////////////////////////////////////
    // Rx Engine DataPath
	 //////////////////////////////////////
	 rxDataPath datapath_main(.rxclk(rxclk), .reset(reset), .rxd64(rxd64), .rxc8(rxc8), .inband_fcs(inband_fcs), .receiving(receiving), 
	                          .start_da(start_da), .start_lt(start_lt), .wait_crc_check(wait_crc_check), .get_sfd(get_sfd), 
                             .get_terminator(get_terminator), .get_error_code(get_error_code), .tagged_frame(tagged_frame), .pause_frame(pause_frame),
									  .da_addr(da_addr), .terminator_location(terminator_location), .CRC_DATA(CRC_DATA), .rx_data_valid(rx_data_valid), 
									  .rx_data(rx_data), .get_terminator_d1(get_terminator_d1),.bad_frame_get(bad_frame_get),.good_frame_get(good_frame_get),
									  .check_reset(check_reset),.rx_good_frame(rx_good_frame),.rx_bad_frame(rx_bad_frame));
	 
	 //////////////////////////////////////
	 // Destination Address Checker
	 //////////////////////////////////////

	 rxDAchecker  dachecker(.rxclk(rxclk), .reset(reset), .local_invalid(local_invalid), .broad_valid(broad_valid), .multi_valid(multi_valid), .MAC_Addr(MAC_Addr),
	                        .da_addr(da_addr));
	              defparam dachecker.Multicast = 48'h0180C2000001;
	              defparam dachecker.Broadcast = 48'hffffffffffff;

    /////////////////////////////////////
	 // Length/Type field checker
	 /////////////////////////////////////

	 rxLenTypChecker lenchecker(.rxclk(rxclk), .reset(reset), .get_terminator(get_terminator), .terminator_location(terminator_location), 
	                            .jumbo_enable(jumbo_enable), .tagged_frame(tagged_frame), .frame_cnt(frame_cnt), .vlan_enable(vlan_enable),
										 .length_error(length_error), .large_error(large_error),.small_error(small_error), .padded_frame(padded_frame),
					                .length_65_127(length_65_127), .length_128_255(length_128_255), .length_256_511(length_256_511), .length_512_1023(length_512_1023), 
					                .length_1024_max(length_1024_max), .jumbo_frame(jumbo_frame)
										 );		

	 /////////////////////////////////////
	 // Counters used in Receive Engine
	 /////////////////////////////////////

    rxNumCounter counters(.rxclk(rxclk), .reset(reset), .receiving(receiving), .frame_cnt(frame_cnt));
 
	 /////////////////////////////////////
	 // State Machine in Receive Process
	 /////////////////////////////////////

    rxStateMachine statemachine(.rxclk(rxclk), .reset(reset), .recv_enable(recv_enable), .get_sfd(get_sfd), .local_invalid(local_invalid), 
	                             .length_error(length_error), .crc_check_valid(crc_check_valid), .crc_check_invalid(crc_check_invalid), 
                                .start_da(start_da), .start_lt(start_lt), .receiving(receiving),.good_frame_get(good_frame_get),
										  .bad_frame_get(bad_frame_get), .get_error_code(get_error_code), .wait_crc_check(wait_crc_check), .get_terminator(get_terminator),
										  .receiving_d1(receiving_d1),.receiving_d2(receiving_d2),.check_reset(check_reset));

	 /////////////////////////////////////
	 // CRC Check module
	 /////////////////////////////////////
	 rxCRC crcmodule(.rxclk(rxclk), .reset(reset), .CRC_DATA(CRC_DATA), .get_terminator(get_terminator), .terminator_location(terminator_location),
	                 .crc_check_invalid(crc_check_invalid), .crc_check_valid(crc_check_valid),.receiving(receiving),.receiving_d1(receiving_d1),
						  .receiving_d2(receiving_d2), .get_terminator_d1(get_terminator_d1), .wait_crc_check(wait_crc_check));
    /////////////////////////////////////
	 // RS Layer
	 /////////////////////////////////////
    rxRSLayer rx_rs(.rxclk(rxclk), .rxclk_180(rxclk_180), .reset(reset), .link_fault(link_fault), .rxd64(rxd64), .rxc8(rxc8), .rxd_in(rxd_in), .rxc_in(rxc_in));
    
	 /////////////////////////////////////
	 // Statistic module
	 /////////////////////////////////////
	 rxStatModule rx_stat(.rxclk(rxclk),.reset(reset),.good_frame_get(good_frame_get), .large_error(large_error),.small_error(small_error), .crc_check_invalid(crc_check_invalid),
                 .receiving(receiving), .padded_frame(padded_frame), .pause_frame(pause_frame), .broad_valid(broad_valid), .multi_valid(multi_valid),
					  .length_65_127(length_65_127), .length_128_255(length_128_255), .length_256_511(length_256_511), .length_512_1023(length_512_1023), 
					  .length_1024_max(length_1024_max), .jumbo_frame(jumbo_frame),.get_error_code(get_error_code), .rxStatRegPlus(rxStatRegPlus));				   
endmodule
