`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 10:05:58
// Design Name: 
// Module Name: ALU
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


module ALU (
    input      [31:0] Srca,
    input      [31:0] Srcb,         // 兩個數
    input      [ 3:0] alu_control,  // 要做哪種運算(加?減?AND?...)
    output reg [31:0] alu_result,   // 運算結果
    output            zero          // 結果是不是 0(beq 用)
);

    localparam ADD = 4'd0;
    localparam SUB = 4'd1;
    localparam AND = 4'd2;
    localparam OR = 4'd3;
    localparam XOR = 4'd4;
    localparam SLT = 4'd5;
    localparam SLTU = 4'd6;
    localparam SLL = 4'd7;
    localparam SRL = 4'd8;
    localparam SRA = 4'd9;

    always @(*) begin
        case (alu_control)
            ADD:     alu_result = Srca + Srcb;
            SUB:     alu_result = Srca - Srcb;
            AND:     alu_result = Srca & Srcb;
            OR:      alu_result = Srca | Srcb;
            XOR:     alu_result = Srca ^ Srcb;
            SLT:     alu_result = $signed(Srca) < $signed(Srcb) ? 1 : 0;
            SLTU:    alu_result = Srca < Srcb ? 1 : 0;
            SLL:     alu_result = Srca << Srcb[4:0];  // 最多移32bits
            SRL:     alu_result = Srca >> Srcb[4:0];  // 最多移32bits
            SRA:     alu_result = $signed(Srca) >>> Srcb[4:0];  // 最多移32bits
            default: alu_result = Srca + Srcb;
        endcase
    end

    assign zero = alu_result == 0;
endmodule
