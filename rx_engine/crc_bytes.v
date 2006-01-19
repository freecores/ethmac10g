`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    14:20:44 01/16/06
// Design Name:    
// Module Name:    crc_bytes
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
`timescale 1ns/1ps
module crc_bytes(d,crc_in,crc_byte1,crc_byte2,crc_byte3,crc_byte4,crc_byte5,crc_byte6,crc_byte7);	
input[63:0] d;
input[31:0] crc_in;
output[31:0] crc_byte1;
output[31:0] crc_byte2;
output[31:0] crc_byte3;
output[31:0] crc_byte4;
output[31:0] crc_byte5;
output[31:0] crc_byte6;
output[31:0] crc_byte7;

wire[31:0] crc_byte[7:0];

assign crc_byte1 = crc_byte[0];
assign crc_byte2 = crc_byte[1];
assign crc_byte3 = crc_byte[2];
assign crc_byte4 = crc_byte[3];
assign crc_byte5 = crc_byte[4];
assign crc_byte6 = crc_byte[5];
assign crc_byte7 = crc_byte[6];


CRC32_D8 crc1(.DATA_IN(d[63:56]),.CRC_IN(crc_in), .CRC_OUT(crc_byte[0]));
CRC32_D8 crc2(.DATA_IN(d[55:48]),.CRC_IN(crc_byte[0]), .CRC_OUT(crc_byte[1]));
CRC32_D8 crc3(.DATA_IN(d[47:40]),.CRC_IN(crc_byte[1]), .CRC_OUT(crc_byte[2]));
CRC32_D8 crc4(.DATA_IN(d[39:32]),.CRC_IN(crc_byte[2]), .CRC_OUT(crc_byte[3]));
CRC32_D8 crc5(.DATA_IN(d[31:24]),.CRC_IN(crc_byte[3]), .CRC_OUT(crc_byte[4]));
CRC32_D8 crc6(.DATA_IN(d[23:16]),.CRC_IN(crc_byte[4]), .CRC_OUT(crc_byte[5]));
CRC32_D8 crc7(.DATA_IN(d[15:8]),.CRC_IN(crc_byte[5]), .CRC_OUT(crc_byte[6]));
CRC32_D8 crc8(.DATA_IN(d[7:0]),.CRC_IN(crc_byte[6]), .CRC_OUT(crc_byte[7]));

endmodule
