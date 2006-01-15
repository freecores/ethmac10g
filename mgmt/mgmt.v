//////////////////////////////////////////////////////////////////////
//// 																					////
//// MODULE NAME: mgmt															////
//// 																					////
//// DESCRIPTION: Managment module for the 10 Gigabit             ////
////     Ethernet MAC.															////
////																					////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/						////
////																					////
//// AUTHOR(S):																	////
//// Mike Pratt			m v p r a t t AT 		                     ////
////							                 g m a i l DOT c o m		////
//////////////////////////////////////////////////////////////////////
////																					////
//// Copyright (c) 2005 AUTHORS.  All rights reserved.			   ////
////																					////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml   						////
////																					////
//////////////////////////////////////////////////////////////////////
//
// CVS REVISION HISTORY:
//
// $Log: not supported by cvs2svn $ 
//
//////////////////////////////////////////////////////////////////////

/*==== Declarations ================================================*/ 

module mgmt (

	// Global Signals
	gtx_clk,
	reset,
	
	// Host Management Interface
   host_clk,
	host_opcode,
	host_addr,
	host_wr_data,
	host_rd_data,
	host_miim_sel,
	host_req,
	host_miim_rdy,

	// Tx Engine Interface
	tx_stats_vector,
	tx_stats_vld,
	tx_cfg,	

	// Rx Engine Interface
	rx_stats_vector,
	rx_stats_vld,
	
	// PHY Management Interface
	mdc,
	mdio_in,
	mdio_out,
	mdio_tri
); 

/*---- Parameters --------------------------------------------------*/

parameter     MAX_VAL = 16'hFFFF; // counter resets to zero at max value

/*---- Inputs/Outputs ----------------------------------------------*/ 

// Global Signals
input		     gtx_clk; // Transmit clock
input 	     reset;   //  reset (active high, active low, etc.)

// Host management interface
input         host_clk;			// Mgmt clock (10 to 133 MHz)
input [1:0]   host_opcode;
input [9:0]   host_addr;
input [31:0]  host_wr_data;
output [31:0] host_rd_data;
input         host_miim_sel;	// Asserted to access the MDIO interface
input         host_req;			//
output        host_miim_rdy;

// PHY management interface
output        mdc;			
input         mdio_in;
output        mdio_out;
output        mdio_tri;

// Statistics interface
output [24:0] tx_stats_vector;
output 		  tx_stats_vld;
output [24:0] rx_stats_vector;
output 		  rx_stats_vld;

/*---- Registers and Nets ------------------------------------------*/ 

// Output Registers

// Host management interface
reg [31:0] host_rd_data ,   next_host_rd_data;
reg        host_miim_rdy,   next_host_miim_rdy;

// PHY management interface
reg        mdc,             next_mdc;
reg        mdio_out,        next_mdio_out;
reg        mdio_tri,        next_mdio_tri;

// Statistics interface
reg [24:0] tx_stats_vector, next_tx_stats_vector;
reg 		  tx_stats_vld,    next_tx_stats_vld;
reg [24:0] rx_stats_vector, next_rx_stats_vector;
reg 		  rx_stats_vld,	 next_rx_stats_vld;

// Configuration Registers
reg [31:0] rx_cfg_word0,       next_rx_cfg_word0;
reg [20:0] rx_cfg_word1,	    next_rx_cfg_word1;
reg [7:0]  tx_cfg,				 next_tx_cfg;
reg [1:0]  flow_contrl_cfg,	 next_flow_control_cfg;
reg [4:0]  recon_sublayer_cfg, next_recon_sublayer,cfg;
reg [5:0]  mgmt_cfg,			    next_mgmt_cfg;

// Statistic Counters


/*==== Operation ===================================================*/

// Module Registers (flip-flops)
always@(posedge clock or negedge reset)
begin
	
	if (!reset)
		o_val		<= 16'h0;
	else
		o_val		<= next_val;		
end

always@(o_val or
		i_inc or
		i_clr	) 

begin

	if (i_clr == 1'b1)
		next_val = 16'h0;

	else if (i_inc == 1'b1 && o_val == MAX_VAL)
		next_val = 16'h0;

	else if (i_inc == 1'b1)
		next_val = o_val + 1'b1;
	
	else
		next_val = o_val;	
end

/*---- Submodules --------------------------------------------------*/

// Submodule Instantiation
submodule submodule(

	// Global Signals
	.clock             ( clock ),		// Description of clock
	.reset             ( reset ),		// Description of reset
	
   // Inputs
   .i_inputA          ( inputA ), // Description of inputA
	.i_inputB          ( inputB ), // Description of inputB
	
	// Outputs
	.o_outputA         ( outputA ), // Description of outputA
	.o_outputB         ( outputB ), // Description of outputB
); 

endmodule // mgmt ----------------------------------------------------
