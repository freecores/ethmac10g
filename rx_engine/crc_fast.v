`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    01:15:03 01/15/06
// Design Name:    
// Module Name:    crc_fast
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
module crc_fast(clk, reset, init, calc, d_valid, data, crc_reg, bits_more_reg,part_crc);
input clk;
input reset;
input init;
input calc;
input d_valid;
input[63:0] data;
input[2:0] bits_more_reg;
output[31:0] crc_reg;
output[31:0] part_crc; 



reg[31:0] crc_reg;//,crc_reg_tmp;

always @ (posedge clk or posedge reset)
begin
   if (reset) begin
      crc_reg <= 32'hFFFFFFFF;
   end
   
   else if (init) begin
      crc_reg <= 32'hFFFFFFFF;
   end

   else if (calc & d_valid) begin
      crc_reg <=full_crc(crc_reg, data);
   end
   
   else if (~calc & d_valid) begin
      crc_reg <=  {crc_reg[23:0], 8'hFF};				
   end
end

reg [31:0] part_crc;
always @ (posedge clk or posedge reset)
begin
   if (reset) begin
      part_crc <= 32'hFFFFFFFF;
   end
   
   else if (init) begin
      part_crc <= 32'hFFFFFFFF;
   end

   else if (calc & d_valid) begin
	   case (bits_more_reg)
         3'b001: part_crc <= next_crc32_data64(32'h00000000,{24'h00, (crc_reg^{data[63: 56], 24'h00}),8'h00});
         3'b010: part_crc <= next_crc32_data64(32'h00000000,{16'h00, (crc_reg^{data[63: 48], 16'h00}),16'h0000});
         3'b011: part_crc <= next_crc32_data64(32'h00000000,{8'h00, (crc_reg^{data[63: 40], 8'h00}), 24'h000000});
			3'b100: part_crc <= next_crc32_data64(32'h00000000,{crc_reg^data[63: 32],32'h00000000});
			3'b101: part_crc <= five_crc(crc_reg, data);
			3'b110: part_crc <= six_crc(crc_reg, data);
			3'b111: part_crc <= seven_crc(crc_reg, data);
			3'b000: part_crc <= 32'hffffffff;
		endcase
   end

end


//
function[31:0] full_crc;
input[31:0] crc;
input[63:0] data;
reg[31:0] crc_reg_tmp;
begin
  crc_reg_tmp = 32'hffffffff;
  crc_reg_tmp = next_crc32_data64(32'h00000000,{crc^data[63:32], 32'h00000000});
  full_crc = next_crc32_data64(32'h00000000,{crc_reg_tmp^data[31:0], 32'h00000000});
end
endfunction

function[31:0] five_crc;
input[31:0] crc;
input[63:0] data;
reg[31:0] crc_reg_tmp;
begin
  crc_reg_tmp = 32'hffffffff;
  crc_reg_tmp = next_crc32_data64(32'h00000000,{crc^data[63:32], 32'h00000000});
  five_crc = next_crc32_data64(32'h00000000,{24'h00, (crc_reg_tmp^{data[31: 24], 24'h00}),8'h00});
end
endfunction

function[31:0] six_crc;
input[31:0] crc;
input[63:0] data;
reg[31:0] crc_reg_tmp;
begin
  crc_reg_tmp = 32'hffffffff;
  crc_reg_tmp = next_crc32_data64(32'h00000000,{crc^data[63:32], 32'h00000000});
  six_crc = next_crc32_data64(32'h00000000,{16'h00, (crc_reg_tmp^{data[31: 16], 16'h00}),16'h0000});
end
endfunction

function[31:0] seven_crc;
input[31:0] crc;
input[63:0] data;
reg[31:0] crc_reg_tmp;
begin
  crc_reg_tmp = 32'hffffffff;
  crc_reg_tmp = next_crc32_data64(32'h00000000,{crc^data[63:32], 32'h00000000});
  seven_crc = next_crc32_data64(32'h00000000,{8'h00, (crc_reg_tmp^{data[31: 8], 8'h00}), 24'h000000});
end
endfunction



function [31:0] next_crc32_data64;
input [31:0] crc;
input [63:0] inp;
integer i;
begin
next_crc32_data64 = crc;
for(i=0; i<64; i=i+1)
next_crc32_data64 = next_div32_data1(next_crc32_data64, inp[63-i]);
end
endfunction
//
function [31:0] next_div32_data1; // remainder of M(x)/P(x)
input [31:0] crc; // previous CRC value
input B; // input data bit (MSB first)
begin
next_div32_data1 ={crc[30:0],B}^({32{crc[31]}} & 32'b00000100110000010001110110110111);
// ^26 ^23^22 ^16 ^12 ^11 ^10 ^8 ^7 ^5 ^4 ^2 ^1 ^0
end
endfunction

endmodule
