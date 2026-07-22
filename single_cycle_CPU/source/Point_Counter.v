`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/25 21:52:16
// Design Name: 
// Module Name: Point_Counter
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


module Point_Counter (
    input             clk,
    input             rst,
    input             step,
    input      [31:0] pc_next,  // 下一個位址(外面算好給它)
    output reg [31:0] pc        // 當前位址(給 Instruction Memory)
);
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'd0;
        end
        else if (step) begin
            pc <= pc_next;
        end
    end
endmodule
