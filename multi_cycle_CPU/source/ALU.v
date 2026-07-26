`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/14 17:45:24
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
    input      [ 3:0] ALUControl,
    input      [31:0] SrcA,
    input      [31:0] SrcB,
    output            Zero,
    output reg [31:0] ALUResult
);
    wire        overflow;
    wire [31:0] result;

    localparam ADD = 4'd0;
    localparam SUB = 4'd1;
    localparam SLL = 4'd2;
    localparam SLT = 4'd3;
    localparam SLTU = 4'd4;
    localparam XOR = 4'd5;
    localparam SRL = 4'd6;
    localparam SRA = 4'd7;
    localparam OR = 4'd8;
    localparam AND = 4'd9;

    assign result   = SrcA - SrcB;
    assign overflow = (SrcA[31] != SrcB[31]) && (SrcA[31] != result[31]);

    always @(*) begin
        case (ALUControl)
            ADD:     ALUResult = SrcA + SrcB;
            SUB:     ALUResult = result;
            SLL:     ALUResult = SrcA << SrcB[4:0];
            SLT:     ALUResult = {31'd0, (result[31] ^ overflow)};
            SLTU:    ALUResult = {31'd0, (SrcA < SrcB)};
            XOR:     ALUResult = SrcA ^ SrcB;
            SRL:     ALUResult = SrcA >> SrcB[4:0];
            SRA:     ALUResult = $signed(SrcA) >>> SrcB[4:0];
            OR:      ALUResult = SrcA | SrcB;
            AND:     ALUResult = SrcA & SrcB;
            default: ALUResult = SrcA + SrcB;
        endcase
    end

    assign Zero = ALUResult == 32'd0;
endmodule
