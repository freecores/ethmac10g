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

`define START      8'hfb
`define TERMINATE  8'hfd  	
`define SFD        8'b10101011
`define SEQUENCE   8'h9c
`define ERROR      8'hfe
`define ALLONES    8'hff
`define ALLZEROS   8'h00
`define BYTE_0     3'b000
`define BYTE_1     3'b001
`define BYTE_2     3'b010
`define BYTE_3     3'b011
`define BYTE_4     3'b100
`define BYTE_5     3'b101
`define BYTE_6     3'b110
`define BYTE_7     3'b111

`define MINI_LENGTH 16h'002e

`define TAG_SIGN   16'h8100
`define PAUSE_SIGN 16'h8808

module rxFrameDepart(rxclk, reset, rxd64, rxc8, start_da, start_lt, tagged_frame,pause_frame,
                     inband_fcs, da_addr, lt_data, crc_code, get_sfd, get_error_code,
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
	 output[31:0] crc_code;
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
			    get_sfd <=#TP (rxd64[63:56] ==`START) & (rxd64[7:0]== `SFD) & (rxc8 == 8'h80);
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
					  terminator_location <=#TP 0;			 
					  rxc_end_data <=#TP 8'b00001111;
			    end   
			    else if (rxc8[1] & (rxd64[15:8] ==`TERMINATE)) begin
				     get_terminator <=#TP 1'b1;
					  terminator_location <=#TP 1;
					  rxc_end_data <=#TP 8'b00011111;
				 end
				 else if (rxc8[2] & (rxd64[23:16]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 2;	
					  rxc_end_data <=#TP 8'b00111111;
				 end
				 else if (rxc8[3] & (rxd64[31:24]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;
					  terminator_location <=#TP 3;					  			
					  rxc_end_data <=#TP 8'b01111111;
				 end
             else if (rxc8[4] & (rxd64[39:32]==`TERMINATE)) begin
				     get_terminator <=#TP 1'b1; 
					  terminator_location <=#TP 4;					  			
					  rxc_end_data <=#TP 8'b11111111;
				 end
				 else if (rxc8[5] & (rxd64[47:40]==`TERMINATE)) begin		
                 get_terminator <=#TP 1'b1; 
					  terminator_location <=#TP 5;
					  rxc_end_data <=#TP 8'b00000111;
				 end
				 else if (rxc8[6] & (rxd64[55:48]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 6; 
					  rxc_end_data <=#TP 8'b00000011;
				 end
				 else if (rxc8[7] & (rxd64[63:56]==`TERMINATE))	begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 7;
					  rxc_end_data <=#TP 8'b00000001;
				 end
				 else	begin
				     get_terminator <=#TP 1'b0;
					  terminator_location <=#TP terminator_location; 
					  rxc_end_data <=#TP 0;
				 end
			 end
	 end
	 always@(posedge rxclk or posedge reset) begin
	       if(reset) begin
				 crc_code <=#TP 0;
			 end
			 else
			    case (terminator_location)
				     3'h0: begin
								crc_code <=#TP rxd64_d2[63:32];
					  end
	   			  3'h1: begin	 
					         crc_code <=#TP {rxd64_d2[63:40],rxd64_d1[7:0]};	
					  end
					  3'h2: begin    
					         crc_code <=#TP {rxd64_d2[63:48],rxd64_d1[15:0]};
					  end	
					  3'h3: begin
								crc_code <=#TP {rxd64_d2[63:56],rxd64_d1[23:0]};
					  end
					  3'h4: begin					
								crc_code <=#TP {rxd64_d1[31:0]};						
					  end
					  3'h5: begin					
								crc_code <=#TP {rxd64_d1[39:8]};
					  end
					  3'h6: begin						
								crc_code <=#TP {rxd64_d1[47:16]};
					  end
					  3'h7: begin					
								crc_code <=#TP {rxd64_d1[55:24]};
					  end
				 endcase
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

	 reg small_frame;
	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    small_frame <=#TP 1'b0;
       else	if (start_lt)
		    small_frame <=#TP (rxd64[47:32] < 46);
		 else								
		    small_frame <=#TP small_frame;
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

    reg[31:0]  crc_code;

  /////////////////////////////////////////////////////////////////////////////////
  //                       Generate proper rxc to FIFO									//
  /////////////////////////////////////////////////////////////////////////////////

  // FCS is provided by client, inband_fcs is valid   
  //    receiving            end_data_cnt		            	end_fcs
  // frame: |<------ Data ------>|<-- bits_more -->|<-- FCS -->|<--------
  // rxc  :	|<------------------- all_one -------------------->|<--------all_zero
  //                             |<--- 8bits, with 1s & 0s --->|

  // FCS is provided by logic, inband_fcs is invalid
  //	  receiving            end_data_cnt                   end_fcs
  // frame: |<------ Data ------>|<-- bits_more -->|<-- FCS -->|
  // rxc  : |<-------------- all_one ------------->|<----- all_zero
  //										|<-- 8bits, with 1s & 0s --->|

  //    receiving          end_small_cnt													end_fcs
  // frame: |<------ Data ------>|<-- small_bits_more -->|<-- PAD -->|<-- FCS -->|
  // rxc  : |<----------------- all_one ---------------->|<----- all_zero
  //										|<-------- 1s --------->|<----- 0s 
	 wire [7:0]rxc_final;
	 wire [7:0]rxc_fifo; //rxc send to fifo


	 assign rxc_final = get_terminator? rxc_end_data: `ALLONES;
	 assign rxc_fifo = inband_fcs? ~rxc8:rxc_final;

//	 always@(posedge rxclk or posedge reset) begin
//	       if(reset)
//			   rxc_fifo <=#TP 0;
//			 else if (inband_fcs)
//				rxc_fifo <=#TP ~rxc8;
//          else if (~inband_fcs)
//			   rxc_fifo <=#TP rxc_final;
//	 end            
endmodule