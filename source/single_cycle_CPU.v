`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/27 13:18:27
// Design Name: 
// Module Name: single_cycle_CPU
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


module single_cycle_CPU (
    input         clk,
    input         rst,
    input         step,
    input  [ 4:0] a_dbg,
    output [31:0] rd_dbg
);
    wire        reg_write;
    wire        alu_src;
    wire        zero;
    wire        mem_write;
    wire [ 1:0] srca_src;
    wire [ 1:0] PCSrc;
    wire [ 1:0] result_src;
    wire [ 2:0] imm_src;
    wire [ 2:0] funct3;
    wire [ 3:0] alu_control;
    wire [31:0] pc_next;
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] rd;
    wire [31:0] result;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] ReadData;
    wire [31:0] SrcB;
    wire [31:0] imm_ext;
    wire [31:0] alu_result;
    wire [31:0] pc_plus4;
    wire [31:0] pc_target;
    wire [31:0] SrcA;

    Point_Counter PC (
        .clk    (clk),
        .rst    (rst),
        .step   (step),
        .pc_next(pc_next),
        .pc     (pc)
    );

    Instruction_Memory IM (
        .addr (pc),
        .instr(instr)
    );

    Register_File RF (
        .clk   (clk),
        .step  (step),
        .we3   (reg_write),
        .a_dbg (a_dbg),
        .a1    (instr[19:15]),
        .a2    (instr[24:20]),
        .a3    (instr[11:7]),
        .wd3   (result),
        .rd1   (rd1),
        .rd2   (rd2),
        .rd_dbg(rd_dbg)
    );

    Extend extend (
        .instr  (instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    PCPlus4 pcp4 (
        .pc      (pc),
        .pc_plus4(pc_plus4)
    );

    mux2 RF_ALU_B (
        .d0 (rd2),
        .d1 (imm_ext),
        .sel(alu_src),
        .y  (SrcB)
    );

    mux3 RF_ALU_A (
        .d0 (rd1),
        .d1 (pc),
        .d2 (32'd0),
        .sel(srca_src),
        .y  (SrcA)
    );

    ALU alu (
        .Srca       (SrcA),
        .Srcb       (SrcB),
        .alu_control(alu_control),
        .alu_result (alu_result),
        .zero       (zero)
    );

    Data_Memory DM (
        .clk   (clk),
        .step  (step),
        .we    (mem_write),
        .funct3(instr[14:12]),
        .addr  (alu_result),
        .wd    (rd2),
        .rd    (rd)
    );

    Load_Unit LU (
        .addr    (alu_result[1:0]),
        .funct3  (instr[14:12]),
        .rd      (rd),
        .ReadData(ReadData)
    );

    mux3 m3 (
        .d0 (alu_result),
        .d1 (ReadData),
        .d2 (pc_plus4),
        .sel(result_src),
        .y  (result)
    );

    PCTarget PCT (
        .pc       (pc),
        .imm_ext  (imm_ext),
        .pc_target(pc_target)
    );

    mux3 PCT_PC (
        .d0 (pc_plus4),
        .d1 (pc_target),
        .d2 (alu_result),
        .sel(PCSrc),
        .y  (pc_next)
    );

    Control_Unit CU (
        .zero       (zero),
        .instr      (instr),
        .alu_result (alu_result),
        .PCSrc      (PCSrc),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .reg_write  (reg_write),
        .result_src (result_src),
        .srca_src   (srca_src),
        .imm_src    (imm_src),
        .alu_control(alu_control)
    );
endmodule
