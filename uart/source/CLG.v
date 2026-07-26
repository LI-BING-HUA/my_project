`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/08 16:43:26
// Design Name: 
// Module Name: CLG
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


module CLG(Cin, G, P, C0, C1, C2, Cout);
input Cin;
input [3:0] G, P;
output C0, C1, C2, Cout;

assign C0 = G[0] | (P[0] & Cin);
assign C1 = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
assign C2 = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) |
    (P[2] & P[1] & P[0] & Cin);
assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) |
    (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

endmodule
