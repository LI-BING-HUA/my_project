`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/22 11:16:39
// Design Name: 
// Module Name: BtoBCD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BtoBCD(
    input  [7:0] Binary,      // 要轉換的 8-bit 二進位 (0~255)
    output [3:0] BCD_0,       // 個位 (0~9)
    output [3:0] BCD_1,       // 十位 (0~9)
    output [3:0] BCD_2        // 百位 (0~2,因為最大 255)
);
wire [7:0] add_all_out, mux_out2, mux_out3, mux_out4, mux_out5;
wire [7:0] S1, S2, S3, S4;
wire [3:0] add_Dout, mux_out1;
wire add_Cout, cout1, cout2, B;

ADD6 add6(.Din(Binary[3:0]), .Dout(add_Dout), .Cout(add_Cout));
assign mux_out1 = add_Cout ? add_Dout : Binary[3:0];
assign add_all_out = {3'b000, add_Cout, mux_out1};

assign mux_out2 = Binary[4] ? 8'h16 : 8'h00;
assign mux_out3 = Binary[5] ? 8'h32 : 8'h00;
assign mux_out4 = Binary[6] ? 8'h64 : 8'h00;
assign mux_out5 = Binary[7] ? 8'h28 : 8'h00;
BCDADD bcdadd1(.A(add_all_out), .B(mux_out2), .S(S1), .Cout());
BCDADD bcdadd2(.A(S1), .B(mux_out3), .S(S2), .Cout());
BCDADD bcdadd3(.A(S2), .B(mux_out4), .S(S3), .Cout(cout1));
BCDADD bcdadd4(.A(S3), .B(mux_out5), .S(S4), .Cout(cout2));
assign B = cout1 | cout2;
assign BCD_0 = S4[3:0];
assign BCD_1 = S4[7:4];

FA_2 fa(.A(Binary[7]), .B(B), .Cin(1'b0), .S(BCD_2[0]), .Cout(BCD_2[1]));
assign BCD_2[3:2] = 2'b00;

endmodule
