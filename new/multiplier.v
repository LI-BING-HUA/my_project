`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/08 21:44:32
// Design Name: 
// Module Name: multiplier
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


module multiplier(
input [3:0] A, 
input B,
output [3:0] PI
    );
    assign PI[0] = A[0] & B;
    assign PI[1] = A[1] & B;
    assign PI[2] = A[2] & B;
    assign PI[3] = A[3] & B;
endmodule
