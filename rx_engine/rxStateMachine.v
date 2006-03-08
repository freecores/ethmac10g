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
module rxStateMachine(rxclk, reset, recv_enable, get_sfd, local_invalid, length_error, crc_check_valid, crc_check_invalid, 
       start_da, start_lt, receiving, receiving_d1, receiving_d2,good_frame_get, bad_frame_get, get_error_code, wait_crc_check,
		 get_terminator,check_reset);
   
	 input rxclk;
    input reset;
   
	 input recv_enable;
	 
	 //PRE & SFD
	 input get_sfd; // SFD has been received;
	
	 //DA field 
	 input local_invalid;// The Frame's DA field is not Local MAC;
	
	 //Length/Type field
	 input length_error;//
	 
	 //FCS field
	 input get_terminator;//Indicate end of receiving FCS field;
	 input crc_check_valid;//Indicate the frame passed CRC Check;
	 input crc_check_invalid;//Indicate the frame failed in CRC Check;
	 input get_error_code;
	 
	 input check_reset;
	
	 //DA field
	 output start_da;// Start to receive Destination Address;
   
	 //Length/Type field
	 output start_lt;// Start to receive Length/Type field;
	
    //Receive process control
	 output receiving; //Rx Engine is working, not in IDLE state and Check state.
	 output receiving_d1, receiving_d2;
	 output good_frame_get;// A good frame has been received;
	 output bad_frame_get; // A bad frame has been received; 
	 output wait_crc_check;// 
	 
	 parameter IDLE = 0, rxReceiveDA = 1, rxReceiveLT = 2, rxReceiveData = 4;
	 parameter rxGetError = 8,	rxIFGWait = 16;
	 parameter TP =1;

	 wire    start_da;
	 wire    start_lt;
	 wire    receiving;
	 reg     good_frame_get;
	 reg     bad_frame_get;
	 
	 reg[4:0] rxstate, rxstate_next;

	 always@(rxstate, get_sfd, local_invalid, recv_enable,
	         get_error_code, length_error, get_terminator, reset)begin
	      if (reset) begin
			   rxstate_next <=#TP IDLE;
			end
			else begin	 
			    case (rxstate)
			      IDLE: begin //5'b00000;
			       		if (get_sfd && recv_enable)
				       		rxstate_next <=#TP rxReceiveDA;
							else
							   rxstate_next <=#TP IDLE;
					end
           		rxReceiveDA: begin	//5'b00001  
				   		rxstate_next <=#TP rxReceiveLT;
					end
            	rxReceiveLT: begin	//5'b00010		 
					 		rxstate_next <=#TP rxReceiveData;
            	end
					rxReceiveData: begin //5'b00100
					 		if (local_invalid |length_error| get_error_code) 
					     		rxstate_next <=#TP rxGetError;
							else if (get_terminator)
							   rxstate_next <=#TP rxIFGWait;
							else
							   rxstate_next <=#TP rxReceiveData;
					end
					rxGetError: begin //5'b01000
						if (get_sfd && recv_enable)
				       	rxstate_next <=#TP rxReceiveDA;
						else
					      rxstate_next <=#TP IDLE;
					end
					rxIFGWait : begin //5'b10000;
						if (get_sfd && recv_enable)
				       		rxstate_next <=#TP rxReceiveDA;
						else
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

	 assign start_da = rxstate[0];
	 assign start_lt = rxstate[1];
	 assign receiving = rxstate[2] | rxstate[1] | rxstate[0]; // in DA,LT,DATA status
	 
	 reg receiving_d1, receiving_d2;
	 always@(posedge rxclk or posedge reset) begin
	      if (reset) begin
			   receiving_d1<=#TP 0;
			   receiving_d2<=#TP 0;
         end
         else begin
            receiving_d1<=#TP receiving;
            receiving_d2<=#TP receiving_d1;
			end
    end
	 
	 reg  wait_crc_check;							  	
	 always@(posedge rxclk or posedge reset) begin
	      if (reset)
			   wait_crc_check <=#TP 0;
			else if (rxstate[4])
			   wait_crc_check <=#TP 1'b1;
		   else if (crc_check_valid || crc_check_invalid||length_error)
			   wait_crc_check <=#TP 1'b0;
			else
			   wait_crc_check <=#TP wait_crc_check;
	 end

	 always@(posedge rxclk or posedge reset)begin
	       if (reset)	begin
			    bad_frame_get <=#TP 0;
				 good_frame_get <=#TP 0;
			 end
			 else if(rxstate[3] || crc_check_invalid || length_error)begin
			    bad_frame_get <=#TP 1'b1;
			    good_frame_get <=#TP 1'b0;
			 end
          else if (crc_check_valid)begin			 
				 good_frame_get <=#TP 1'b1;
				 bad_frame_get <=#TP 1'b0;
			 end	
			 else if (check_reset)begin
			    good_frame_get <=#TP 1'b0;
				 bad_frame_get <=#TP 1'b0;
			 end	 
	 end
endmodule
