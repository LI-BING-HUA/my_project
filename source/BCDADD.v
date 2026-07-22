`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/22 10:29:15
// Design Name: 
// Module Name: BCDADD
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


module BCDADD(
    input [7:0] A,
    input [7:0] B,
    output [7:0] S,
    output Cout
);

    wire [3:0] S1, S2, Dout1, Dout2;
    wire cla_cout1, cla_cout2, add_cout1, add_cout2;
    
    CLA4 cla_1(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .S(S1), .Cout(cla_cout1));
    ADD6 add6_1(.Din(S1), .Cin(cla_cout1), .Dout(Dout1), .Cout(add_cout1));
    assign S[3:0] = (cla_cout1 | add_cout1) ? Dout1 : S1;

    CLA4 cla_2(.A(A[7:4]), .B(B[7:4]), .Cin(cla_cout1 | add_cout1), .S(S2), .Cout(cla_cout2));
    ADD6 add6_2(.Din(S2), .Cin(cla_cout2), .Dout(Dout2), .Cout(add_cout2));
    assign S[7:4] = (cla_cout2 | add_cout2) ? Dout2 : S2;

    assign Cout = cla_cout2 | add_cout2;
endmodule
