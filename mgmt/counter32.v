//////////////////////////////////////////////////////////////////////
//// 																					////
//// MODULE NAME: counter32													////
//// 																					////
//// DESCRIPTION: 32-bit counter                                  ////
////																					////
//// This file is part of the 10 Gigabit Ethernet IP core project ////
////  http://www.opencores.org/projects/ethmac10g/						////
////																					////
//// AUTHOR(S):																	////
//// Mike Pratt			m v p r a t t AT 		                     ////
////							                 opencores DOT o r g		////
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
//
//////////////////////////////////////////////////////////////////////


/*==== Declarations ==================================================*/ 

module counter32 (

	// global signals
	clock,
	reset,
	
	// inputs
	i_inc,
	i_clr,
	
	// output
	o_val
); 

/*---- Parameters ----------------------------------------------------*/

parameter MAX_VAL = 32'hFFFFFFFF; // counter resets to zero at max value

/*---- Inputs/Outputs ------------------------------------------------*/ 

// global signals
input 	clock;
input 	reset; // active low

// inputs
input		i_inc;
input		i_clr;

// outputs
output 	[31:0]	o_val;

/*---- Registers and Nets --------------------------------------------*/ 

// output registers
reg [31:0] 	o_val, 	next_val;

/*==== Operation =====================================================*/

// module registers (flip-flops)
always@(posedge clock or negedge reset)
begin
	
	if (!reset)
		o_val		<= 32'h0;
	else
		o_val		<= next_val;		
end

always@(o_val or
		i_inc or
		i_clr	) 

begin

	if (i_clr == 1'b1)
		next_val = 32'h0;

	else if (i_inc == 1'b1 && o_val == MAX_VAL)
		next_val = 32'h0;

	else if (i_inc == 1'b1)
		next_val = o_val + 1'b1;
	
	else
		next_val = o_val;	
end

endmodule // counter32 ---------------------------------------------------
