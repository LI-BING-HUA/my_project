`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/22 10:23:55
// Design Name: 
// Module Name: ADD6
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


module ADD6(
    input [3:0] Din,
    input Cin,
    output reg [3:0] Dout,
    output reg Cout
);
    always @(*) begin
        if (Din > 4'd9 || Cin) begin
            Dout = Din + 4'd6;
            Cout = 1'b1;
        end 
        else begin
            Dout = Din;
            Cout = 1'b0;
        end
    end
endmodule
