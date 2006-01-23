module byte_count_module(CLK, RESET, START, PARALLEL_CNT, BYTE_COUNTER);

// Ports declaration
input CLK;
input RESET;
input START;
input PARALLEL_CNT;


output [15:0] BYTE_COUNTER;

reg [15:0] BYTE_COUNTER;
reg [15:0] counter;

always @(posedge CLK or posedge RESET)
begin
   if (RESET == 1) begin
	counter = 16'h0000;
   end

   // the ack is delayed which starts the counter
   else if (START == 1) begin
       if (PARALLEL_CNT) begin
            counter = counter + 8;
       end
       
	 else begin
      	counter = counter + 1;
       end
   end
end

always @(counter) begin
  BYTE_COUNTER = counter;
end
endmodule // End of Module 

