`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    19:45:58 12/13/05
// Design Name:    
// Module Name:    rxFrameDepart
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

`define START      8'hdf
`define TERMINATE  8'hbf 	
`define SFD        8'b11010101
`define SEQUENCE   8'h59
`define ERROR      8'h7f
`define ALLONES    8'hff
`define ALLZEROS   8'h00

`define TAG_SIGN   16'h0081//8100
`define PAUSE_SIGN 16'h1011//8808

module rxFrameDepart(rxclk, reset, rxd64, rxc8, start_da, start_lt, tagged_frame,pause_frame,
                     inband_fcs, da_addr, lt_data, get_sfd, get_error_code,
							rxc_fifo,rxd64_d1,rxd64_d2, get_terminator, terminator_location);
    input rxclk;
    input reset;
    input [63:0] rxd64;
	 input [63:0] rxd64_d1;
	 input [63:0] rxd64_d2;
    input [7:0] rxc8;

	 input start_da;
	 input start_lt;
	 input inband_fcs;																				  

	 output[7:0]  rxc_fifo;
	 output[47:0] da_addr; //destination address won't be changed until start_da was changed again
	 output[15:0] lt_data; //(Length/Type) field won't be changed until start_lt was changed again
	 output       tagged_frame;
	 output       pause_frame;
	 output       get_terminator;
	 output[2:0]  terminator_location;

	 output       get_sfd;
	 output       get_error_code;

	 parameter TP = 1;

	 //////////////////////////////////////////
	 // Get Control Characters
	 //////////////////////////////////////////
	 reg get_sfd;
	 reg get_terminator;
	 reg get_error_code;
	 reg[7:0] get_e_chk;

	 //1. SFD 
	 always@(posedge rxclk or posedge reset) begin
	       if (reset) 
			    get_sfd <=#TP 0; 
			 else
			    get_sfd <=#TP (rxd64[7:0] ==`START) & (rxd64[63:56]== `SFD) & (rxc8 == 8'h01);
	 end

 	 //2. EFD
	 
	 reg[7:0] rxc_end_data;
	 reg [2:0]terminator_location;
    always@(posedge rxclk or posedge reset) begin
	       if (reset)	begin
			    get_terminator <=#TP 0;
				 terminator_location <=#TP 0;				 
				 rxc_end_data <=#TP 0;
			 end
			 else begin
			    if (rxc8[0] & (rxd64[7:0]  ==`TERMINATE)) begin
				     get_terminator <=#TP 1'b1;
					  terminator_location <=#TP 4;			 
					  rxc_end_data <=#TP 8'b00001111;
			    end   
			    else if (rxc8[1] & (rxd64[15:8] ==`TERMINATE)) begin
				     get_terminator <=#TP 1'b1;
					  terminator_location <=#TP 5;
					  rxc_end_data <=#TP 8'b00011111;
				 end
				 else if (rxc8[2] & (rxd64[23:16]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 6;	
					  rxc_end_data <=#TP 8'b00111111;
				 end
				 else if (rxc8[3] & (rxd64[31:24]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;
					  terminator_location <=#TP 7;					  			
					  rxc_end_data <=#TP 8'b01111111;
				 end
             else if (rxc8[4] & (rxd64[39:32]==`TERMINATE)) begin
				     get_terminator <=#TP 1'b1; 
					  terminator_location <=#TP 0;					  			
					  rxc_end_data <=#TP 8'b11111111;
				 end
				 else if (rxc8[5] & (rxd64[47:40]==`TERMINATE)) begin		
                 get_terminator <=#TP 1'b1; 
					  terminator_location <=#TP 1;
					  rxc_end_data <=#TP 8'b00000001;
				 end
				 else if (rxc8[6] & (rxd64[55:48]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 2; 
					  rxc_end_data <=#TP 8'b00000011;
				 end
				 else if (rxc8[7] & (rxd64[63:56]==`TERMINATE))	begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 3;
					  rxc_end_data <=#TP 8'b00000111;
				 end
				 else	begin
				     get_terminator <=#TP 1'b0;
					  terminator_location <=#TP terminator_location; 
					  rxc_end_data <=#TP 0;
				 end
			 end
	 end
					         
	 //3. Error Character
    always@(posedge rxclk or posedge reset) begin
	       if (reset)
			    get_e_chk <=#TP 0;
			 else begin
				 get_e_chk[0] <=#TP rxc8[0] & (rxd64[7:0]  !=`TERMINATE); 
			    get_e_chk[1] <=#TP rxc8[1] & (rxd64[15:8] !=`TERMINATE);
             get_e_chk[2] <=#TP rxc8[2] & (rxd64[23:16]!=`TERMINATE);
             get_e_chk[3] <=#TP rxc8[3] & (rxd64[31:24]!=`TERMINATE);
             get_e_chk[4] <=#TP rxc8[4] & (rxd64[39:32]!=`TERMINATE);		
             get_e_chk[5] <=#TP rxc8[5] & (rxd64[47:40]!=`TERMINATE);
             get_e_chk[6] <=#TP rxc8[6] & (rxd64[55:48]!=`TERMINATE);
             get_e_chk[7] <=#TP rxc8[7] & (rxd64[63:56]!=`TERMINATE);
			 end
	 end
	 
	 always@(posedge rxclk or posedge reset) begin
	       if (reset) 
			    get_error_code <=#TP 0;
          else
			    get_error_code <=#TP (| get_e_chk);
	 end
    
	 //////////////////////////////////////
	 // Get Destination Address
	 //////////////////////////////////////

	 reg[47:0] da_addr; 
	 always@(posedge rxclk or posedge reset)begin
       if (reset) 
	       da_addr <=#TP 0;
   	 else if (start_da) 
	       da_addr <=#TP rxd64_d1[47:0];
		 else	
		    da_addr <=#TP da_addr;
    end

	//////////////////////////////////////
	// Get Length/Type Field
	//////////////////////////////////////

	 reg[15:0] lt_data; 
	 always@(posedge rxclk or posedge reset)begin
       if (reset) 
	       lt_data <=#TP 0;
   	 else if (start_lt) 
	       lt_data <=#TP rxd64_d1[47:32];
		 else
		    lt_data <=#TP lt_data;
    end

	 reg tagged_frame;
	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    tagged_frame <=#TP 1'b0;
       else	if (start_lt)
		    tagged_frame <=#TP (rxd64[47:32] == `TAG_SIGN); 
		 else								
		    tagged_frame <=#TP tagged_frame;
	 end
	 
	 reg pause_frame;
	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    pause_frame <=#TP 1'b0;
       else	if (start_lt)
		    pause_frame <=#TP (rxd64[47:32] == `PAUSE_SIGN); 
		 else 
		    pause_frame <=#TP pause_frame;
	 end

  ////////////////////////////////////////
  // Get FCS Field and Part of DATA
  ////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////
  //                       Generate proper rxc to FIFO									//
  /////////////////////////////////////////////////////////////////////////////////

	 wire [7:0]rxc_final;
	 wire [7:0]rxc_fifo; //rxc send to fifo


	 assign rxc_final = get_terminator? rxc_end_data: `ALLONES;
	 assign rxc_fifo = inband_fcs? ~rxc8:rxc_final;
        
endmodule