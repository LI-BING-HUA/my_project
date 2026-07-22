`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 15:21:34
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
    input         zero,
    input  [31:0] instr,
    input  [31:0] alu_result,
    output [ 1:0] PCSrc,
    output        mem_write,
    output        alu_src,
    output        reg_write,
    output [ 1:0] result_src,
    output [ 1:0] srca_src,
    output [ 2:0] imm_src,
    output [ 3:0] alu_control
);
    wire       branch;
    wire       jump;
    wire       jalr;
    wire [1:0] alu_op;
    reg        branch_taken;

    Main_Decoder MD (
        .op        (instr[6:0]),
        .branch    (branch),
        .jump      (jump),
        .jalr      (jalr),
        .mem_write (mem_write),
        .alu_src   (alu_src),
        .reg_write (reg_write),
        .result_src(result_src),
        .alu_op    (alu_op),
        .srca_src  (srca_src),
        .imm_src   (imm_src)
    );

    ALU_Decoder AD (
        .funct7b5   (instr[30]),
        .alu_op     (alu_op),
        .funct3     (instr[14:12]),
        .op         (instr[6:0]),
        .alu_control(alu_control)
    );

    always @(*) begin
        case (instr[14:12])
            3'b000:  branch_taken = zero;
            3'b001:  branch_taken = ~zero;
            3'b100:  branch_taken = alu_result[0];
            3'b101:  branch_taken = ~alu_result[0];
            3'b110:  branch_taken = alu_result[0];
            3'b111:  branch_taken = ~alu_result[0];
            default: branch_taken = 1'b0;
        endcase
    end
    assign PCSrc = jalr ? 2'b10 : (jump | (branch_taken & branch)) ? 2'b01 : 2'b00;

endmodule
