`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 08:44:26
// Design Name: 
// Module Name: Extend
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


module Extend (
    input      [31:0] instr,
    input      [ 2:0] imm_src,
    output reg [31:0] imm_ext   // 立即數延長
);
    localparam I_TYPE = 3'd0;
    localparam S_TYPE = 3'd1;
    localparam B_TYPE = 3'd2;
    localparam U_TYPE = 3'd3;
    localparam J_TYPE = 3'd4;

    always @(*) begin
        case (imm_src)
            I_TYPE:  imm_ext = {{20{instr[31]}}, instr[31:20]};
            S_TYPE:  imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            B_TYPE:  imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            U_TYPE:  imm_ext = {instr[31:12], {12{1'b0}}};
            J_TYPE:  imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm_ext = 32'd0;
        endcase
    end
endmodule
