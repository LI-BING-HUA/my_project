`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/22 15:44:23
// Design Name: 
// Module Name: Instr_Decoder
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


module Instr_Decoder (
    input      [6:0] op,
    output reg [2:0] ImmSrc
);
    always @(*) begin
        case (op)
            7'd3: ImmSrc = 3'b000;
            7'd19: ImmSrc = 3'b000;
            7'd23: ImmSrc = 3'b011;
            7'd35: ImmSrc = 3'b001;
            7'd55: ImmSrc = 3'b011;
            7'd99: ImmSrc = 3'b010;
            7'd103: ImmSrc = 3'b000;
            7'd111: ImmSrc = 3'b100;
            default: ImmSrc = 3'b000;
        endcase
    end
endmodule
