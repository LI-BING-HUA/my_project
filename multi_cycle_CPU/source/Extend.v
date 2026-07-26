`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/20 11:19:36
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
    input      [ 2:0] ImmSrc,
    input      [31:0] Instr,
    output reg [31:0] ImmExt
);
    parameter I_TYPE = 3'b000;
    parameter S_TYPE = 3'b001;
    parameter B_TYPE = 3'b010;
    parameter U_TYPE = 3'b011;
    parameter J_TYPE = 3'b100;

    always @(*) begin
        case (ImmSrc)
            I_TYPE:  ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            S_TYPE:  ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            B_TYPE:  ImmExt = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            U_TYPE:  ImmExt = {Instr[31:12], 12'b0};
            J_TYPE:  ImmExt = {{11{Instr[31]}}, Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            default: ImmExt = 32'd0;
        endcase
    end
endmodule
