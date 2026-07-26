`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/22 15:43:54
// Design Name: 
// Module Name: Main_FSM
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


module Main_FSM (
    input            clk,
    input            rst,
    input      [6:0] op,
    output reg       Branch,
    output reg       MemWrite,
    output reg       PCUpdate,
    output reg       AdrSrc,
    output reg       IRWrite,
    output reg       RegWrite,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ResultSrc,
    output reg [1:0] ALUOp
);

    parameter FETCH = 4'd0;
    parameter DECODE = 4'd1;
    parameter MEMADR = 4'd2;
    parameter MEMREAD = 4'd3;
    parameter MEMWB = 4'd4;
    parameter MEMWRITE = 4'd5;
    parameter EXECUTER = 4'd6;
    parameter ALUWB = 4'd7;
    parameter EXECUTEI = 4'd8;
    parameter BEQ = 4'd9;
    parameter JAL = 4'd10;
    parameter LUI = 4'd11;
    parameter JALR = 4'd12;

    reg [3:0] state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            state <= FETCH;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        Branch    = 1'b0;
        MemWrite  = 1'b0;
        PCUpdate  = 1'b0;
        AdrSrc    = 1'b0;
        IRWrite   = 1'b0;
        RegWrite  = 1'b0;
        ALUSrcA   = 2'd0;
        ALUSrcB   = 2'd0;
        ResultSrc = 2'd0;
        ALUOp     = 2'd0;
        case (state)
            FETCH: begin
                AdrSrc     = 1'b0;
                IRWrite    = 1'b1;
                ALUSrcA    = 2'd0;
                ALUSrcB    = 2'd2;
                ALUOp      = 2'd0;
                ResultSrc  = 2'd2;
                PCUpdate   = 1'b1;
                next_state = DECODE;
            end
            DECODE: begin
                ALUSrcA = (op == 7'd103) ? 2'd2 : 2'd1;
                ALUSrcB = 2'd1;
                ALUOp   = 2'd0;
                case (op)
                    7'd3: next_state = MEMADR;
                    7'd19: next_state = EXECUTEI;
                    7'd23: next_state = ALUWB;
                    7'd35: next_state = MEMADR;
                    7'd51: next_state = EXECUTER;
                    7'd55: next_state = LUI;
                    7'd99: next_state = BEQ;
                    7'd103: next_state = JALR;
                    7'd111: next_state = JAL;
                    default: next_state = MEMADR;
                endcase
            end
            MEMADR: begin
                ALUSrcA    = 2'd2;
                ALUSrcB    = 2'd1;
                ALUOp      = 2'd0;
                next_state = (op == 7'd3) ? MEMREAD : MEMWRITE;
            end
            MEMREAD: begin
                ResultSrc  = 2'd0;
                AdrSrc     = 1'b1;
                next_state = MEMWB;
            end
            MEMWB: begin
                ResultSrc  = 2'd1;
                RegWrite   = 1'b1;
                next_state = FETCH;
            end
            MEMWRITE: begin
                ResultSrc  = 2'd0;
                AdrSrc     = 1'b1;
                MemWrite   = 1'b1;
                next_state = FETCH;
            end
            EXECUTER: begin
                ALUSrcA    = 2'd2;
                ALUSrcB    = 2'd0;
                ALUOp      = 2'd2;
                next_state = ALUWB;
            end
            ALUWB: begin
                ResultSrc  = 2'd0;
                RegWrite   = 1'b1;
                next_state = FETCH;
            end
            EXECUTEI: begin
                ALUSrcA    = 2'd2;
                ALUSrcB    = 2'd1;
                ALUOp      = 2'd2;
                next_state = ALUWB;
            end
            BEQ: begin
                ResultSrc  = 2'd0;
                ALUSrcA    = 2'd2;
                ALUSrcB    = 2'd0;
                ALUOp      = 2'd1;
                Branch     = 1'b1;
                next_state = FETCH;
            end
            JAL: begin
                ResultSrc  = 2'd0;
                PCUpdate   = 1'b1;
                ALUSrcA    = 2'd1;
                ALUSrcB    = 2'd2;
                ALUOp      = 2'd0;
                next_state = ALUWB;
            end
            LUI: begin
                ALUSrcA    = 2'd3;
                ALUSrcB    = 2'd1;
                ALUOp      = 2'd0;
                next_state = ALUWB;
            end
            JALR: begin
                ALUSrcA    = 2'd2;
                ALUSrcB    = 2'd1;
                ALUOp      = 2'd0;
                next_state = JAL;
            end
            default: begin
                next_state = FETCH;
            end
        endcase
    end
endmodule
