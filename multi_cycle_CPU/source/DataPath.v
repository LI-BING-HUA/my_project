`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/22 11:08:02
// Design Name: 
// Module Name: DataPath
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


module DataPath (
    input         clk,
    input         rst,
    input         MemWrite,
    input         PCWrite,
    input         AdrSrc,
    input         IRWrite,
    input         RegWrite,
    input  [ 1:0] ALUSrcA,
    input  [ 1:0] ALUSrcB,
    input  [ 1:0] ResultSrc,
    input  [ 2:0] ImmSrc,
    input  [ 3:0] ALUControl,
    output        Zero,
    output        funct7b5,
    output [ 2:0] funct3,
    output [ 6:0] op,
    output [31:0] ALUResult
);
    wire [31:0] PC;
    wire [31:0] OldPC;
    wire [31:0] Adr;
    wire [31:0] Result;
    wire [31:0] WriteData;
    wire [31:0] RD;
    wire [31:0] ReadData;
    wire [31:0] Instr;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] ImmExt;
    wire [31:0] ALUOut;
    wire [31:0] Data;

    register_en pc (
        .clk(clk),
        .rst(rst),
        .en (PCWrite),
        .in (Result),
        .out(PC)
    );

    mux2 pc_mem (
        .sel(AdrSrc),
        .in1(PC),
        .in2(Result),
        .out(Adr)
    );

    Memory mem (
        .clk   (clk),
        .WE    (MemWrite),
        .funct3(funct3),
        .A     (Adr),
        .WD    (WriteData),
        .RD    (RD)
    );

    Load_Unit lu (
        .addr    (Adr[1:0]),
        .funct3  (funct3),
        .rd      (RD),
        .ReadData(ReadData)
    );

    register_en oldpc_reg (
        .clk(clk),
        .rst(rst),
        .en (IRWrite),
        .in (PC),
        .out(OldPC)
    );

    register_en ir_reg (
        .clk(clk),
        .rst(rst),
        .en (IRWrite),
        .in (RD),
        .out(Instr)
    );

    Register_File rf (
        .clk(clk),
        .WE3(RegWrite),
        .A1 (Instr[19:15]),
        .A2 (Instr[24:20]),
        .A3 (Instr[11:7]),
        .WD3(Result),
        .RD1(RD1),
        .RD2(RD2)
    );

    register_nen regA (
        .clk(clk),
        .rst(rst),
        .in (RD1),
        .out(A)
    );

    register_nen regB (
        .clk(clk),
        .rst(rst),
        .in (RD2),
        .out(WriteData)
    );

    mux4 rf_alu1 (
        .sel(ALUSrcA),
        .in1(PC),
        .in2(OldPC),
        .in3(A),
        .in4(32'd0),
        .out(SrcA)
    );

    mux3 rf_alu2 (
        .sel(ALUSrcB),
        .in1(WriteData),
        .in2(ImmExt),
        .in3(32'd4),
        .out(SrcB)
    );

    ALU alu (
        .ALUControl(ALUControl),
        .SrcA      (SrcA),
        .SrcB      (SrcB),
        .Zero      (Zero),
        .ALUResult (ALUResult)
    );

    register_nen alu_out (
        .clk(clk),
        .rst(rst),
        .in (ALUResult),
        .out(ALUOut)
    );

    mux3 alu_pc (
        .sel(ResultSrc),
        .in1(ALUOut),
        .in2(Data),
        .in3(ALUResult),
        .out(Result)
    );

    register_nen mdr (
        .clk(clk),
        .rst(rst),
        .in (ReadData),
        .out(Data)
    );

    Extend extend (
        .ImmSrc(ImmSrc),
        .Instr (Instr),
        .ImmExt(ImmExt)
    );

    assign op       = Instr[6:0];
    assign funct3   = Instr[14:12];
    assign funct7b5 = Instr[30];
endmodule
