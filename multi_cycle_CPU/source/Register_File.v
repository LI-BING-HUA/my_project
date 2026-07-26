`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/20 10:47:20
// Design Name: 
// Module Name: Register_File
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


module Register_File (
    input         clk,
    input         WE3,
    input  [ 4:0] A1,
    input  [ 4:0] A2,
    input  [ 4:0] A3,
    input  [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] mem[0:31];

    always @(posedge clk) begin
        if (WE3 && A3 != 5'd0) begin
            mem[A3] <= WD3;
        end
    end

    assign RD1 = A1 != 5'd0 ? mem[A1] : 32'd0;
    assign RD2 = A2 != 5'd0 ? mem[A2] : 32'd0;

endmodule
