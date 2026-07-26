`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/23 11:55:03
// Design Name: 
// Module Name: multi_cycle_CPU
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


module multi_cycle_CPU (
    input clk,
    input rst
);
    wire        Zero;
    wire        funct7b5;
    wire        MemWrite;
    wire        PCWrite;
    wire        AdrSrc;
    wire        IRWrite;
    wire        RegWrite;
    wire        branch_taken;
    wire [ 1:0] ALUSrcA;
    wire [ 1:0] ALUSrcB;
    wire [ 1:0] ResultSrc;
    wire [ 2:0] ImmSrc;
    wire [ 2:0] funct3;
    wire [ 3:0] ALUControl;
    wire [ 6:0] op;
    wire [31:0] ALUResult;

    Control_Unit cu (
        .clk         (clk),
        .rst         (rst),
        .Zero        (Zero),
        .funct7b5    (funct7b5),
        .funct3      (funct3),
        .op          (op),
        .MemWrite    (MemWrite),
        .PCWrite     (PCWrite),
        .AdrSrc      (AdrSrc),
        .IRWrite     (IRWrite),
        .RegWrite    (RegWrite),
        .ALUSrcA     (ALUSrcA),
        .ALUSrcB     (ALUSrcB),
        .ResultSrc   (ResultSrc),
        .ALUControl  (ALUControl),
        .ImmSrc      (ImmSrc),
        .branch_taken(branch_taken),
        .ALUResult   (ALUResult)
    );

    DataPath dp (
        .clk       (clk),
        .rst       (rst),
        .MemWrite  (MemWrite),
        .PCWrite   (PCWrite),
        .AdrSrc    (AdrSrc),
        .IRWrite   (IRWrite),
        .RegWrite  (RegWrite),
        .ALUSrcA   (ALUSrcA),
        .ALUSrcB   (ALUSrcB),
        .ResultSrc (ResultSrc),
        .ImmSrc    (ImmSrc),
        .ALUControl(ALUControl),
        .Zero      (Zero),
        .funct7b5  (funct7b5),
        .funct3    (funct3),
        .op        (op),
        .ALUResult (ALUResult)
    );
endmodule
