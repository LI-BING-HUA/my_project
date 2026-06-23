`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/08 22:02:20
// Design Name: 
// Module Name: mul
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


module mul(
input [3:0] A, B,
output [7:0] P
    );
    
    wire [3:0] MUout1, MUout2, MUout3, MUout4;
    wire [3:0] S1, S2;
    wire C1, C2;
    
    multiplier mul1(.A(A), .B(B[0]), .PI(MUout1));
    multiplier mul2(.A(A), .B(B[1]), .PI(MUout2));
    multiplier mul3(.A(A), .B(B[2]), .PI(MUout3));
    multiplier mul4(.A(A), .B(B[3]), .PI(MUout4));
    
    CLA4 CLA1(.A({1'b0, MUout1[3:1]}), .B(MUout2), .Cin(1'b0), .S({S1[3:1], P[1]}), .Cout(C1));
    CLA4 CLA2(.A({C1, S1[3:1]}), .B(MUout3), .Cin(1'b0), .S({S2[3:1], P[2]}), .Cout(C2));
    CLA4 CLA3(.A({C2, S2[3:1]}), .B(MUout4), .Cin(1'b0), .S(P[6:3]), .Cout(P[7]));
    
    assign P[0] = MUout1[0];
endmodule
