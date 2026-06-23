`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/08 22:30:48
// Design Name: 
// Module Name: mul_seg
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


module mul_seg(
input clk, 
input [3:0] A, B,
output [6:0] seg,
output [3:0] an
    );
    wire [7:0] P;
    mul mul4(.A(A), .B(B), .P(P));
    seven_seg ss(.clk(clk), .d0(P[3:0]), .d1(P[7:4]), .d2(4'd0), .d3(4'd0), .seg(seg), .an(an));
endmodule
