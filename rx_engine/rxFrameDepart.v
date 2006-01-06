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

module rxFrameDepart(rxclk, reset, rxclk_180, rxd64, rxc8, start_da, start_lt, tagged_frame,pause_frame,
                     bits_more, small_bits_more, tagged_len, small_frame, end_data_cnt,inband_fcs, 
							end_small_cnt, da_addr, lt_data, crc_code, end_fcs, crc_valid, length_error,
						   get_sfd, get_error_code,receiving, rxc_fifo, receiving_frame,rxd64_d1);
    input rxclk;
    input reset;
    input rxclk_180;
    input [63:0] rxd64;
	 input [63:0] rxd64_d1;
    input [7:0] rxc8;

	 input start_da;
	 input start_lt;
	 input [2:0] bits_more;
	 input [2:0] small_bits_more;
	 output small_frame;
	 input end_data_cnt;
	 input end_small_cnt;
	 input inband_fcs;
	 input receiving;
	 input receiving_frame;

	 output[7:0]  rxc_fifo;
	 output[47:0] da_addr; //destination address won't be changed until start_da was changed again
	 output[15:0] lt_data; //(Length/Type) field won't be changed until start_lt was changed again
	 output[15:0] tagged_len;
	 output[31:0] crc_code;
	 output       end_fcs;
	 output       tagged_frame;
	 output       pause_frame;
	 output[7:0]  crc_valid;
	 output       length_error;

	 output       get_sfd;
	 output       get_error_code;

	 parameter TP = 1;

	 //////////////////////////////////////////
	 // Get Control Characters
	 //////////////////////////////////////////
	 wire get_sfd;
	 wire[7:0] get_t_chk;
	 reg get_error_code;
	 reg[7:0] get_e_chk;

	 //1. SFD 
	 assign get_sfd = (rxd64[63:56] ==`START) & (rxd64[7:0]== `SFD) & (rxc8 == 8'h80);

 	 //2. EFD
	 assign get_t_chk[0] = rxc8[0] & (rxd64[7:0] == `TERMINATE );
	 assign get_t_chk[1] = rxc8[1] & (rxd64[15:8] == `TERMINATE );
	 assign get_t_chk[2] = rxc8[2] & (rxd64[23:16] == `TERMINATE );
	 assign get_t_chk[3] = rxc8[3] & (rxd64[31:24] == `TERMINATE );
	 assign get_t_chk[4] = rxc8[4] & (rxd64[39:32] == `TERMINATE );		
	 assign get_t_chk[5] = rxc8[5] & (rxd64[47:40] == `TERMINATE );
	 assign get_t_chk[6] = rxc8[6] & (rxd64[55:48] == `TERMINATE );
	 assign get_t_chk[7] = rxc8[7] & (rxd64[63:56] == `TERMINATE );

	 //3. Error Character
    always@(posedge rxclk_180 or posedge reset) begin
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
	 
	 always@(posedge rxclk_180 or posedge reset) begin
	       if (reset) 
			    get_error_code <=#TP 0;
          else
			    get_error_code <=#TP (| get_e_chk);
	 end
    
	 //////////////////////////////////////
	 // Get Destination Address
	 //////////////////////////////////////

	 reg[47:0] da_addr; 
	 always@(posedge rxclk_180 or posedge reset)begin
       if (reset) 
	       da_addr <=#TP 0;
   	 else if (start_da) 
	       da_addr <=#TP rxd64[63:16];
		 else	
		    da_addr <=#TP da_addr;
    end

	//////////////////////////////////////
	// Get Length/Type Field
	//////////////////////////////////////

	 reg[15:0] lt_data; 
	 always@(posedge rxclk_180 or posedge reset)begin
       if (reset) 
	       lt_data <=#TP 0;
   	 else if (start_lt) 
	       lt_data <=#TP rxd64[31:16] - 2;
       else if(~receiving_frame)
		    lt_data <=#TP 16'h0578;
		 else
		    lt_data <=#TP lt_data;
    end

	 reg tagged_frame;
	 always@(posedge rxclk_180 or posedge reset) begin
	    if (reset)
		    tagged_frame <=#TP 1'b0;
       else	if (start_lt)
		    tagged_frame <=#TP (rxd64[31:16] == `TAG_SIGN); 
		 else	if (~receiving_frame)			
		    tagged_frame <=#TP 1'b0;
		 else								
		    tagged_frame <=#TP tagged_frame;
	 end

	 reg small_frame;
	 always@(posedge rxclk_180 or posedge reset) begin
	    if (reset)
		    small_frame <=#TP 1'b0;
       else	if (start_lt)
		    small_frame <=#TP (rxd64[31:16] < 46);
		 else	if (~receiving_frame)			
		    small_frame <=#TP 1'b0;
		 else								
		    small_frame <=#TP small_frame;
	 end
	 
	 reg pause_frame;
	 always@(posedge rxclk_180 or posedge reset) begin
	    if (reset)
		    pause_frame <=#TP 1'b0;
       else	if (start_lt)
		    pause_frame <=#TP (rxd64[31:16] == `PAUSE_SIGN); 
		 else	if(~receiving_frame)
		    pause_frame <=#TP 1'b0;
		 else 
		    pause_frame <=#TP pause_frame;
	 end
	  
    
  ///////////////////////////////////////
  // Get Tagged Frame Length
  ///////////////////////////////////////

	 reg tagged_frame_d1;
	 always@(posedge rxclk_180) begin
	        tagged_frame_d1<=#TP tagged_frame;
	 end

	 reg[15:0] tagged_len;
	 always@(posedge rxclk_180 or posedge reset) begin
	        if (reset)
               tagged_len <=#TP 0;
			  else if(~tagged_frame_d1 & tagged_frame)
			      tagged_len <=#TP rxd64[63:48] + 2; 
           else if(~receiving_frame)
			      tagged_len <=#TP 16'h0578;
			  else
			      tagged_len <=#TP tagged_len;
	 end

  ////////////////////////////////////////
  // Get FCS Field and Part of DATA
  ////////////////////////////////////////
	 
	 wire [7:0]special;

    reg[31:0]  crc_code;	
	 wire       end_fcs;
	 wire[7:0]  crc_valid;
	 reg        length_error; 
	 reg        end_data_cnt_d1;

	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    end_data_cnt_d1<= #TP 0;
		 else 
		    end_data_cnt_d1<= #TP end_data_cnt;
 	 end

	 assign special = `ALLONES >> bits_more;			 
	 assign crc_valid = end_data_cnt? ~special: `ALLONES;
	 assign end_fcs = end_data_cnt_d1;
	 //timing constraint should be added here to make length_error be valid earlier than end_fcs
	 always@(posedge rxclk or posedge reset) begin
	       if (reset) begin
			    length_error <=#TP 0;
			 end
			 else begin
			    case (bits_more)
					 `BYTE_0: length_error <=#TP ~get_t_chk[3] & end_data_cnt;
					 `BYTE_1: length_error <=#TP ~get_t_chk[2] & end_data_cnt;
					 `BYTE_2: length_error <=#TP ~get_t_chk[1] & end_data_cnt;
					 `BYTE_3: length_error <=#TP ~get_t_chk[0] & end_data_cnt;
					 `BYTE_4: length_error <=#TP ~get_t_chk[7] & end_data_cnt_d1;
					 `BYTE_5: length_error <=#TP ~get_t_chk[6] & end_data_cnt_d1;
					 `BYTE_6: length_error <=#TP ~get_t_chk[5] & end_data_cnt_d1;
					 `BYTE_7: length_error <=#TP ~get_t_chk[4] & end_data_cnt_d1;
				 endcase
			 end
    end

	 always@(posedge rxclk or posedge reset) begin
	       if (reset)
			    crc_code <=#TP 0;
			 else
			    case (bits_more)
			       0: crc_code <=#TP rxd64[63:32];
				    1: crc_code <=#TP rxd64[55:24];
				    2: crc_code <=#TP rxd64[47:16];
				    3: crc_code <=#TP rxd64[39:8];
				    4: crc_code <=#TP rxd64[31:0];
				    5: crc_code <=#TP {rxd64_d1[23:0],rxd64[63:56]};
				    6: crc_code <=#TP {rxd64_d1[15:0],rxd64[55:40]};
				    6: crc_code <=#TP {rxd64_d1[7:0],rxd64[39:24]};
             endcase
	 end


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
	 wire [7:0]rxc_pad;
	 wire [7:0]rxc_end_data;
	 wire [7:0]rxc_final[2:0];
	 wire [7:0]rxc_fifo; //rxc send to fifo

	 assign rxc_pad = ~(`ALLONES >> small_bits_more);
	 assign rxc_end_data = ~special;

	 assign rxc_final[1] = receiving? (end_data_cnt? rxc_end_data: `ALLONES): `ALLZEROS;
	 assign rxc_final[2] = receiving? (end_small_cnt?rxc_pad: `ALLONES): `ALLZEROS;
    assign rxc_fifo = inband_fcs? ~rxc8: (small_frame? rxc_final[2]: rxc_final[1]);
                          
endmodule