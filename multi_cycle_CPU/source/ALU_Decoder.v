`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/22 15:44:07
// Design Name: 
// Module Name: ALU_Decoder
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


module ALU_Decoder (
    input            funct7b5,
    input      [1:0] ALUOp,
    input      [2:0] funct3,
    input      [6:0] op,
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'd0;
            2'b01: begin
                case (funct3)
                    3'b000: ALUControl = 4'd1;
                    3'b001: ALUControl = 4'd1;
                    3'b100: ALUControl = 4'd3;
                    3'b101: ALUControl = 4'd3;
                    3'b110: ALUControl = 4'd4;
                    3'b111: ALUControl = 4'd4;
                    default: ALUControl = 4'd1;
                endcase
            end
            2'b10: begin
                case (op)
                    7'd19: begin
                        case (funct3)
                            3'b000: ALUControl = 4'd0;
                            3'b001: ALUControl = 4'd2;
                            3'b010: ALUControl = 4'd3;
                            3'b011: ALUControl = 4'd4;
                            3'b100: ALUControl = 4'd5;
                            3'b101: ALUControl = funct7b5 ? 4'd7 : 4'd6;
                            3'b110: ALUControl = 4'd8;
                            3'b111: ALUControl = 4'd9;
                            default: ALUControl = 4'd0;
                        endcase
                    end

                    7'd51: begin
                        case (funct3)
                            3'b000: ALUControl = funct7b5 ? 4'd1 : 4'd0;
                            3'b001: ALUControl = 4'd2;
                            3'b010: ALUControl = 4'd3;
                            3'b011: ALUControl = 4'd4;
                            3'b100: ALUControl = 4'd5;
                            3'b101: ALUControl = funct7b5 ? 4'd7 : 4'd6;
                            3'b110: ALUControl = 4'd8;
                            3'b111: ALUControl = 4'd9;
                            default: ALUControl = 4'd0;
                        endcase
                    end
                    default: ALUControl = 4'd0;
                endcase
            end
            default: ALUControl = 4'd0;
        endcase
    end
endmodule
