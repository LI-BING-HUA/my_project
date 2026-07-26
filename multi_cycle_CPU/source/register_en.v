`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/22 09:28:33
// Design Name: 
// Module Name: register_en
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


module register_en #(
    parameter width = 32
) (
    input                    clk,
    input                    rst,
    input                    en,
    input      [width - 1:0] in,
    output reg [width - 1:0] out
);
    always @(posedge clk) begin
        if (rst) begin
            out <= 32'd0;
        end
        else if (en) begin
            out <= in;
        end
    end
endmodule
