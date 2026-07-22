`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 11:29:05
// Design Name: 
// Module Name: PCTarget
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


module PCTarget (
    input  [31:0] pc,
    input  [31:0] imm_ext,
    output [31:0] pc_target
);
    assign pc_target = pc + imm_ext;  // beq/jal → PC 相對
endmodule
