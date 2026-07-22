`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 12:25:53
// Design Name: 
// Module Name: Main_Decoder
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

/*
op   type     RegW  ImmSrc  ALUSrc  MemW  ResSrc   Br  Jmp  ALUOp
---  -------  ----  ------  ------  ----  -------  --  ---  -----
3    load     1     0(I)    1       0     1(mem)   0   0    00
19   I-arith  1     0(I)    1       0     0(ALU)   0   0    10
35   store    0     1(S)    1       1     x        0   0    00
51   R-type   1     x       0       0     0(ALU)   0   0    10
99   branch   0     2(B)    0       0     x        1   0    01
111  jal      1     4(J)    x       0     2(PC+4)  0   1    x
103  jalr     1     0(I)    1       0     2(PC+4)  0   1    00
23   auipc    1     3(U)    1       0     0(ALU)   0   0    00
55   lui      1     3(U)    1       0     0(ALU)   0   0    00
*/

module Main_Decoder (
    input      [6:0] op,
    output reg       branch,      // branch
    output reg       jump,        // jump
    output reg       jalr,
    output reg       mem_write,   // store
    output reg       alu_src,     // ALU 的第二個運算元，要拿暫存器還是立即數
    output reg       reg_write,   // 有無 rd
    output reg [1:0] result_src,  // rd 從 ALU(0), 從 mem(1), PC + 4(2)
    output reg [1:0] alu_op,      // 位址或加法(00), 減法(==, <, >)(01), 看func(10)
    output reg [1:0] srca_src,
    output reg [2:0] imm_src      // type
);

    always @(*) begin
        case (op)
            7'd3: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd1;
                alu_op     = 2'd0;
                srca_src   = 2'd0;
                imm_src    = 3'd0;
            end
            7'd19: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd0;
                alu_op     = 2'd2;
                srca_src   = 2'd0;
                imm_src    = 3'd0;
            end
            7'd23: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd0;
                alu_op     = 2'd0;
                srca_src   = 2'd1;
                imm_src    = 3'd3;
            end
            7'd35: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                reg_write  = 1'b0;
                result_src = 2'd0;
                alu_op     = 2'd0;
                srca_src   = 2'd0;
                imm_src    = 3'd1;
            end
            7'd51: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b1;
                result_src = 2'd0;
                alu_op     = 2'd2;
                srca_src   = 2'd0;
                imm_src    = 3'd0;
            end
            7'd55: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd0;
                alu_op     = 2'd0;
                srca_src   = 2'd2;
                imm_src    = 3'd3;
            end
            7'd99: begin
                branch     = 1'b1;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                result_src = 2'd0;
                alu_op     = 2'd3;
                srca_src   = 2'd0;
                imm_src    = 3'd2;
            end
            7'd103: begin
                branch     = 1'b0;
                jump       = 1'b1;
                jalr       = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd2;
                alu_op     = 2'd0;
                srca_src   = 2'd0;
                imm_src    = 3'd0;
            end
            7'd111: begin
                branch     = 1'b0;
                jump       = 1'b1;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                result_src = 2'd2;
                alu_op     = 2'd0;
                srca_src   = 2'd0;
                imm_src    = 3'd4;
            end
            default: begin
                branch     = 1'b0;
                jump       = 1'b0;
                jalr       = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                result_src = 2'd0;
                alu_op     = 2'd0;
                srca_src   = 2'd0;
                imm_src    = 3'd0;
            end
        endcase
    end
endmodule
