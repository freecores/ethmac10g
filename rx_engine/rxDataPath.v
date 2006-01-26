`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:13:57 01/25/2006 
// Design Name: 
// Module Name:    rxDataPath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define START      8'hdf
`define TERMINATE  8'hbf 	
`define SFD        8'b11010101
`define SEQUENCE   8'h59
`define ERROR      8'h7f
`define ALLONES    8'hff
`define ALLZEROS   8'h00

`define TAG_SIGN   16'h0081//8100
`define PAUSE_SIGN 16'h1011//8808

module rxDataPath(rxclk, reset, rxd64, rxc8, inband_fcs, receiving, start_da, start_lt, wait_crc_check, get_sfd, 
                  get_terminator, get_error_code, tagged_frame, pause_frame, da_addr, terminator_location, CRC_DATA, 
						rx_data_valid, rx_data);
    input rxclk;
    input reset;
    input [63:0] rxd64;
    input [7:0] rxc8;
	 input inband_fcs;
	 input receiving;
	 input start_da;
	 input start_lt;
	 input wait_crc_check;	 
	 output get_sfd;
	 output get_terminator; //get T indicator
	 output get_error_code; //get Error indicator
    output tagged_frame;
	 output pause_frame;
	 output[47:0] da_addr;
	 output[2:0] terminator_location;
    output[63:0] CRC_DATA;
	 output[7:0] rx_data_valid;
	 output[63:0] rx_data;
	 
	 parameter TP = 1;
	 
	 //////////////////////////////////////////////
	 // Pipe Line Stage
	 //////////////////////////////////////////////
	 reg [63:0] rxd64_d1,rxd64_d2,CRC_DATA;
	 reg receiving_d1, receiving_d2;
	 reg wait_crc_check_d1;
	 
	 always@(posedge rxclk or posedge reset) begin
	       if (reset)	begin		
				 rxd64_d1<=#TP 0;
				 rxd64_d2<=#TP 0;
		   	 CRC_DATA<=0;
       
			 end
			 else begin
				 rxd64_d1<=#TP rxd64;
				 rxd64_d2<=#TP rxd64_d1;
				 CRC_DATA <={rxd64_d2[7:0],rxd64_d2[15:8],rxd64_d2[23:16],rxd64_d2[31:24],
				            rxd64_d2[39:32],rxd64_d2[47:40],rxd64_d2[55:48],rxd64_d2[63:56]};
			 end
	 end
	 
	 always @(posedge rxclk or posedge reset)begin
	       if (reset) begin
			    receiving_d1 <=#TP 0;
				 receiving_d2 <=#TP 0;
				 wait_crc_check_d1 <=#TP 0;
			 end
			 else	begin
			    receiving_d1 <=#TP receiving;
				 receiving_d2 <=#TP receiving_d1;
				 wait_crc_check_d1 <=#TP wait_crc_check;
			 end
	 end
	 	 
	 ////////////////////////////////////////////
	 // Frame analysis
	 ////////////////////////////////////////////
	 reg get_sfd; //get sfd indicator
	 reg get_terminator; //get T indicator
	 reg get_error_code; //get Error indicator
	 reg[7:0] get_e_chk;
	 reg[7:0] rxc_end_data; //seperate DATA with FCS
	 reg [2:0]terminator_location; //for n*8bits(n<8), get n
	 reg[47:0] da_addr; //get Desetination Address
	 reg tagged_frame;  //Tagged frame indicator(type interpret)
	 reg pause_frame;   //Pause frame indicator(type interpret)
	 
	 //1. SFD 
	 always@(posedge rxclk or posedge reset) begin
	       if (reset) 
			    get_sfd <=#TP 0; 
			 else
			    get_sfd <=#TP (rxd64[7:0] ==`START) & (rxd64[63:56]== `SFD) & (rxc8 == 8'h01);
	 end

 	 //2. EFD
	 
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
					  rxc_end_data <=#TP 8'b00000000;
				 end
				 else if (rxc8[5] & (rxd64[47:40]==`TERMINATE)) begin		
                 get_terminator <=#TP 1'b1; 
					  terminator_location <=#TP 5;
					  rxc_end_data <=#TP 8'b00000001;
				 end
				 else if (rxc8[6] & (rxd64[55:48]==`TERMINATE)) begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 6; 
					  rxc_end_data <=#TP 8'b00000011;
				 end
				 else if (rxc8[7] & (rxd64[63:56]==`TERMINATE))	begin
                 get_terminator <=#TP 1'b1;	
					  terminator_location <=#TP 7;
					  rxc_end_data <=#TP 8'b00000111;
				 end
				 else	begin
				     get_terminator <=#TP 1'b0;
					  terminator_location <=#TP terminator_location; 
					  rxc_end_data <=#TP rxc_end_data;
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

//	 reg[15:0] lt_data; 
//	 always@(posedge rxclk or posedge reset)begin
//       if (reset) 
//	       lt_data <=#TP 0;
//   	 else if (start_lt) 
//	       lt_data <=#TP rxd64_d1[47:32];
//		 else
//		    lt_data <=#TP lt_data;
//    end

	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    tagged_frame <=#TP 1'b0;
       else	if (start_lt)
		    tagged_frame <=#TP (rxd64[47:32] == `TAG_SIGN); 
		 else								
		    tagged_frame <=#TP tagged_frame;
	 end
	 
	 always@(posedge rxclk or posedge reset) begin
	    if (reset)
		    pause_frame <=#TP 1'b0;
       else	if (start_lt)
		    pause_frame <=#TP (rxd64[47:32] == `PAUSE_SIGN); 
		 else 
		    pause_frame <=#TP pause_frame;
	 end

  /////////////////////////////////////////////
  // Generate proper rxc to FIFO						
  /////////////////////////////////////////////

	 reg [7:0]rxc_final;
	 wire [7:0]rxc_fifo; //rxc send to fifo
    
    always@(posedge rxclk or posedge reset) begin
	       if (reset)
			    rxc_final <=#TP 0;
			 else if (get_terminator)
             rxc_final <=#TP rxc_end_data;
          else
             rxc_final <=`ALLONES;
    end				 

//	 assign rxc_final = get_terminator_d1? rxc_end_data: `ALLONES;
	 assign rxc_fifo = inband_fcs? ~rxc8:rxc_final;
  
  /////////////////////////////////////////////
  // FIFO management
  /////////////////////////////////////////////
  	 wire rxfifo_full;
	 wire rxfifo_empty;
	 wire fifo_rd_en;
	 wire fifo_wr_en;

	 assign fifo_rd_en = ~(rxfifo_empty | wait_crc_check_d1);
	 assign fifo_wr_en = receiving_d1;
	 
	 rxdatafifo rxdatain(.clk(rxclk),
	                  .sinit(reset),
	                  .din(rxd64_d2),
	       				.wr_en(fifo_wr_en),
                   	.rd_en(fifo_rd_en),
	                  .dout(rx_data),
	                  .full(rxfifo_full),
	                  .empty(rxfifo_empty));

	 rxcntrlfifo rxcntrlin(.clk(rxclk),
	                  .sinit(reset),
	                  .din(rxc_fifo),
	       				.wr_en(fifo_wr_en),
                   	.rd_en(fifo_rd_en),
	                  .dout(rx_data_valid),
	                  .full(),
	                  .empty());

endmodule
