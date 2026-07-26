`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/23 11:42:47
// Design Name: 
// Module Name: Control_Unit
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


module Control_Unit (
    input             clk,
    input             rst,
    input             Zero,
    input             funct7b5,
    input      [ 2:0] funct3,
    input      [ 6:0] op,
    input      [31:0] ALUResult,
    output            MemWrite,
    output            PCWrite,
    output            AdrSrc,
    output            IRWrite,
    output            RegWrite,
    output reg        branch_taken,
    output     [ 1:0] ALUSrcA,
    output     [ 1:0] ALUSrcB,
    output     [ 1:0] ResultSrc,
    output     [ 2:0] ImmSrc,
    output     [ 3:0] ALUControl
);
    wire       Branch;
    wire       PCUpdate;
    wire [1:0] ALUOp;

    Main_FSM mf (
        .clk      (clk),
        .rst      (rst),
        .op       (op),
        .Branch   (Branch),
        .MemWrite (MemWrite),
        .PCUpdate (PCUpdate),
        .AdrSrc   (AdrSrc),
        .IRWrite  (IRWrite),
        .RegWrite (RegWrite),
        .ALUSrcA  (ALUSrcA),
        .ALUSrcB  (ALUSrcB),
        .ResultSrc(ResultSrc),
        .ALUOp    (ALUOp)
    );

    ALU_Decoder ad (
        .funct7b5  (funct7b5),
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .op        (op),
        .ALUControl(ALUControl)
    );

    Instr_Decoder id (
        .op    (op),
        .ImmSrc(ImmSrc)
    );

    always @(*) begin
        case (funct3)
            3'b000: branch_taken = Zero;
            3'b001: branch_taken = ~Zero;
            3'b100: branch_taken = ALUResult[0];
            3'b101: branch_taken = ~ALUResult[0];
            3'b110: branch_taken = ALUResult[0];
            3'b111: branch_taken = ~ALUResult[0];
            default: branch_taken = 1'b0;
        endcase
    end
    assign PCWrite = PCUpdate || (Branch && branch_taken);
endmodule
