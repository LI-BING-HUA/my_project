`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/21 17:42:47
// Design Name: 
// Module Name: FA_2
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


module FA_2(
input A, B, Cin,
output S, Cout
    );
    assign S = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin); 
endmodule
