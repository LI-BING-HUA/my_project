`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/23 18:48:12
// Design Name: 
// Module Name: Load_Unit
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


module Load_Unit (
    input      [ 1:0] addr,
    input      [ 2:0] funct3,
    input      [31:0] rd,
    output reg [31:0] ReadData
);
    always @(*) begin
        case (funct3)
            3'b000: begin
                case (addr)
                    2'b00: ReadData = {{24{rd[7]}}, rd[7:0]};
                    2'b01:   ReadData = {{24{rd[15]}}, rd[15:8]};
                    2'b10:   ReadData = {{24{rd[23]}}, rd[23:16]};
                    2'b11:   ReadData = {{24{rd[31]}}, rd[31:24]};
                    default: ReadData = 32'd0;
                endcase
            end
            3'b001: ReadData = addr[1] ? {{16{rd[31]}}, rd[31:16]} : {{16{rd[15]}}, rd[15:0]};
            3'b010: ReadData = rd;
            3'b100: begin
                case (addr)
                    2'b00: ReadData = {24'd0, rd[7:0]};
                    2'b01:   ReadData = {24'd0, rd[15:8]};
                    2'b10:   ReadData = {24'd0, rd[23:16]};
                    2'b11:   ReadData = {24'd0, rd[31:24]};
                    default: ReadData = 32'd0;
                endcase
            end
            3'b101: ReadData = addr[1] ? {16'd0, rd[31:16]} : {16'd0, rd[15:0]};
            default: ReadData = 32'd0;
        endcase
    end
endmodule
