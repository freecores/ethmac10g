`timescale 100ps / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    09:59:01 11/21/05
// Design Name:    
// Module Name:    rxStateMachine
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
module rxStateMachine(rxclk, reset, recv_enable, get_sfd, local_invalid, len_invalid, end_data_cnt, end_tagged_cnt,
       tagged_frame, length_error, end_fcs, crc_check_valid, crc_check_invalid, start_da, start_lt, inband_fcs,
		 start_data_cnt, start_tagged_cnt, receiving, recv_end, good_frame_get, bad_frame_get, get_error_code, small_frame
		 , end_small_cnt,receiving_frame, wait_crc_check);
   
	 input rxclk;
    input reset;
   
	 input recv_enable;
	 input inband_fcs;
	 
	 //PRE & SFD
	 input get_sfd; // SFD has been received;
	
	 //DA field 
	 input local_invalid;// The Frame's DA field is not Local MAC;
	
	 //Length/Type field
	 input len_invalid;// Indicate if Length field is valid;
    input end_data_cnt;// Indicate end of receiving DATA field(not jumbo frame);
	 input end_tagged_cnt;// Indicate end of receiving DATA field of tagged Frame;
	 input end_small_cnt; // Indicate end of receiving small data field
	 input tagged_frame;// Indicate current frame is a jumbo_frame;
	 input small_frame; // Indicate current frame is a small frame;
	 input length_error;//Indicate Length received is not equal to the Length in LT field;
	 
	 //FCS field
	 input end_fcs;//Indicate end of receiving FCS field;
	 input crc_check_valid;//Indicate the frame passed CRC Check;
	 input crc_check_invalid;//Indicate the frame failed in CRC Check;
	 input get_error_code;
	
	 //DA field
	 output start_da;// Start to receive Destination Address;
   
	 //Length/Type field
	 output start_lt;// Start to receive Length/Type field;
	
	 //DATA field
    output start_data_cnt;// Start to receive DATA field;
	 output start_tagged_cnt;// Start to receive DATA field, but the frame is a tagged frame.
    //Receive process control
	 output receiving;// Rx Engine is receiving valid part of frame;
	 output receiving_frame; //Rx Engine is working, not in IDLE state and Check state.
	 output recv_end; // Receive process ends, either because formal ending or faults happen;
	 output good_frame_get;// A good frame has been received;
	 output bad_frame_get; // A bad frame has been received; 
	 output wait_crc_check;// 
	 
	 parameter IDLE = 0, rxReceiveDA = 1, rxReceiveLT = 2, rxReceiveData = 4;
	 parameter rxReceiveFCS = 8, rxGetError = 16;
	 parameter TP =1;

	 wire    start_da;
	 wire    start_lt;
	 wire 	start_data_cnt;
	 wire    start_tagged_cnt;
	 wire    receiving_data;
	 wire    receiving_frame;
	 wire    receiving;
	 wire    recv_end;
	 reg    good_frame_get;
	 reg    bad_frame_get;
	 
	 reg[4:0] rxstate, rxstate_next;

	 always@(rxstate, get_sfd, local_invalid, len_invalid, recv_enable,
	         end_data_cnt, end_tagged_cnt, get_error_code,
				end_fcs, length_error, reset)begin
	      if (reset) begin
			   rxstate_next <=#TP IDLE;
			end
			else begin	 
			    case (rxstate)
			      IDLE: begin 
			       		if (get_sfd && recv_enable)
				       		rxstate_next <=#TP rxReceiveDA;
							else
							   rxstate_next <=#TP IDLE;
					end
           		rxReceiveDA: begin	  
				   		rxstate_next <=#TP rxReceiveLT;
					end
            	rxReceiveLT: begin			 
					 		rxstate_next <=#TP rxReceiveData;
            	end
					rxReceiveData: begin
					 		if (local_invalid | len_invalid | get_error_code) 
					     		rxstate_next <=#TP rxGetError;
					 		else if (end_data_cnt | end_tagged_cnt) 
					     		rxstate_next <=#TP rxReceiveFCS;
							else
							   rxstate_next <=#TP rxReceiveData;
					end
					rxReceiveFCS: begin	 //length_error should have high priority to end_fcs
				   		if (length_error)
							   rxstate_next <=#TP rxGetError;
							else if (end_fcs)
    					  		rxstate_next <=#TP IDLE;
							else
							   rxstate_next <=#TP rxReceiveFCS;
				 	end
					rxGetError: begin
					      rxstate_next <=#TP IDLE;
					end
			   endcase
		   end
  	   end

	 always@(posedge rxclk or posedge reset) begin
	       if (reset)
			    rxstate <=#TP IDLE;
          else
			    rxstate <=#TP rxstate_next;
	 end

	 reg end_small_cnt_d1;
	 reg end_small_cnt_d2;
	 always@(posedge rxclk or posedge reset) begin
	       if (reset)begin
			    end_small_cnt_d1 <= 0;
				 end_small_cnt_d2 <= 0;
			 end
			 else begin
				 end_small_cnt_d1 <=end_small_cnt;
             if (end_small_cnt_d1)
				    end_small_cnt_d2 <= 1'b1;
             else
				    end_small_cnt_d2 <= #TP end_small_cnt_d2;
			 end
	 end

	 assign start_da = rxstate[0];
	 assign start_lt = rxstate[1];
	 assign start_data_cnt = rxstate[2] & (~tagged_frame);
	 assign start_tagged_cnt = rxstate[2] & tagged_frame;
	 assign receiving_data = rxstate[2] | rxstate[1] | rxstate[0]; // in DA,LT,DATA status
	 assign receiving_frame = rxstate[2] | rxstate[1] | rxstate[0] | rxstate[3]; //in DA,LT,Data,FCS status
	 assign receiving_small = start_da | start_lt | (rxstate[2] & ~end_small_cnt_d2);
//	 assign receiving = inband_fcs? receiving_frame:(small_frame? receiving_small:receiving_data);
    wire recv_tmp;
	 MUXCY recv1(.O(recv_tmp), .DI(receiving_data), .CI(receiving_small), .S(small_frame));
	 MUXCY recv2(.O(receiving),.DI(recv_tmp), .CI(receiving_frame),.S(inband_fcs));
    assign recv_end = ~receiving_frame;
//	 assign bad_frame_get =((rxstate[2]|rxstate[3]) &(local_invalid | len_invalid | get_error_code | length_error)) || crc_check_invalid;
//	 assign good_frame_get = crc_check_valid;
	 
	 reg  wait_crc_check;							  	
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   wait_crc_check <=#TP 0;
			else if (rxstate[3] && end_fcs)
			   wait_crc_check <=#TP 1'b1;
		   else if (crc_check_valid || crc_check_invalid)
			   wait_crc_check <=#TP 1'b0;
			else
			   wait_crc_check <=#TP wait_crc_check;
	 end

	 always@(posedge rxclk or posedge reset)begin
	       if (reset)	begin
			    bad_frame_get <=#TP 0;
				 good_frame_get <=#TP 0;
			 end
			 else begin
			    bad_frame_get <=#TP rxstate[4] || crc_check_invalid;
				 good_frame_get <=#TP crc_check_valid;
			 end
	 end
endmodule
