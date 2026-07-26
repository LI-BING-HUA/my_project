`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/23 16:42:09
// Design Name: 
// Module Name: mux4
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


module mux4 (
    input      [ 1:0] sel,
    input      [31:0] in1,
    input      [31:0] in2,
    input      [31:0] in3,
    input      [31:0] in4,
    output reg [31:0] out
);
    always @(*) begin
        case (sel)
            2'b00: out = in1;
            2'b01: out = in2;
            2'b10: out = in3;
            2'b11: out = in4;
            default: out = in1;
        endcase
    end
endmodule
