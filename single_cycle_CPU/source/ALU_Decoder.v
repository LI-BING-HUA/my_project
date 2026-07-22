`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 14:17:58
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
    input      [1:0] alu_op,
    input      [2:0] funct3,
    input      [6:0] op,
    output reg [3:0] alu_control
);
    always @(*) begin
        case (alu_op)
            2'd0:    alu_control = 4'd0;  // 位置或+
            2'd1:    alu_control = 4'd1;  // -
            2'd2: begin  // 看funct3/7
                if (op == 7'd19) begin
                    case (funct3)
                        3'b000:  alu_control = 4'd0;
                        3'b001:  alu_control = 4'd7;
                        3'b010:  alu_control = 4'd5;
                        3'b011:  alu_control = 4'd6;
                        3'b100:  alu_control = 4'd4;
                        3'b101:  alu_control = funct7b5 ? 4'd9 : 4'd8;
                        3'b110:  alu_control = 4'd3;
                        3'b111:  alu_control = 4'd2;
                        default: alu_control = 4'd0;
                    endcase
                end
                else begin
                    case (funct3)
                        3'b000:  alu_control = funct7b5 ? 4'd1 : 4'd0;
                        3'b001:  alu_control = 4'd7;
                        3'b010:  alu_control = 4'd5;
                        3'b011:  alu_control = 4'd6;
                        3'b100:  alu_control = 4'd4;
                        3'b101:  alu_control = funct7b5 ? 4'd9 : 4'd8;
                        3'b110:  alu_control = 4'd3;
                        3'b111:  alu_control = 4'd2;
                        default: alu_control = 4'd0;
                    endcase
                end
            end
            2'd3: begin  // branch家族
                case (funct3)
                    3'b000:  alu_control = 4'd1;
                    3'b001:  alu_control = 4'd1;
                    3'b100:  alu_control = 4'd5;
                    3'b101:  alu_control = 4'd5;
                    3'b110:  alu_control = 4'd6;
                    3'b111:  alu_control = 4'd6;
                    default: alu_control = 4'd1;
                endcase
            end
            default: alu_control = 4'd0;
        endcase
    end
endmodule
