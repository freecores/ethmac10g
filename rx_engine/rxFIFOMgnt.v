`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    16:23:08 11/24/05
// Design Name:    
// Module Name:    rxFIFOMgnt
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
module rxFIFOMgnt(rxclk, reset, rxd64, rxc_fifo, receiving_frame, recv_end, rx_data_valid, rx_data,
                  wait_crc_check);
    input rxclk;
    input reset;
    input [63:0] rxd64;
	 input [7:0] rxc_fifo;
	 input receiving_frame;
	 input recv_end;
	 input wait_crc_check;

	 output[7:0] rx_data_valid;
	 output[63:0] rx_data;

	 parameter TP =1;

	 wire rxfifo_full;
	 wire rxfifo_empty;
	 wire fifo_rd_en;
	 wire fifo_wr_en;

	 reg receiving_frame_d1, wait_crc_check_d1;
	 reg [7:0] rxc_fifo_d1;

	 assign fifo_rd_en = ~(rxfifo_empty | wait_crc_check_d1);
	 assign fifo_wr_en = receiving_frame_d1;
	 
	 always @(posedge rxclk or posedge reset)begin
	       if (reset) begin
			    receiving_frame_d1 <=#TP 0;
				 rxc_fifo_d1 <=#TP 0;
				 wait_crc_check_d1 <=#TP 0;
			 end
			 else	begin
			    receiving_frame_d1 <=#TP receiving_frame;
				 rxc_fifo_d1 <=#TP rxc_fifo;
				 wait_crc_check_d1 <=#TP wait_crc_check;
			 end
	 end
	 
	 rxdatafifo rxdatain(.clk(rxclk),
	                  .sinit(reset),
	                  .din(rxd64),
	       				.wr_en(fifo_wr_en),
                   	.rd_en(fifo_rd_en),
	                  .dout(rx_data),
	                  .full(rxfifo_full),
	                  .empty(rxfifo_empty));

	 rxcntrlfifo rxcntrlin(.clk(rxclk),
	                  .sinit(reset),
	                  .din(rxc_fifo_d1),
	       				.wr_en(fifo_wr_en),
                   	.rd_en(fifo_rd_en),
	                  .dout(rx_data_valid),
	                  .full(),
	                  .empty());
	                  


endmodule
