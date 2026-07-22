`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/28 14:56:44
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
            // ---- lb：讀 1 byte，符號延伸（補最高位）----
            3'b000: begin
                case (addr)
                    2'b00:   ReadData = {{24{rd[7]}}, rd[7:0]};
                    2'b01:   ReadData = {{24{rd[15]}}, rd[15:8]};
                    2'b10:   ReadData = {{24{rd[23]}}, rd[23:16]};
                    2'b11:   ReadData = {{24{rd[31]}}, rd[31:24]};
                    default: ReadData = 32'd0;
                endcase
            end

            // ---- lh：讀 2 bytes（半個 word），符號延伸 ----
            3'b001: ReadData = addr[1] ? {{16{rd[31]}}, rd[31:16]} : {{16{rd[15]}}, rd[15:0]};

            // ---- lw：讀整格 word，不用抽也不用延伸 ----
            3'b010: ReadData = rd;

            // ---- lbu：讀 1 byte，零延伸（高位補 0）----
            3'b100: begin
                case (addr)
                    2'b00:   ReadData = {{24{1'b0}}, rd[7:0]};
                    2'b01:   ReadData = {{24{1'b0}}, rd[15:8]};
                    2'b10:   ReadData = {{24{1'b0}}, rd[23:16]};
                    2'b11:   ReadData = {{24{1'b0}}, rd[31:24]};
                    default: ReadData = 32'd0;
                endcase
            end

            // ---- lhu：讀 2 bytes，零延伸 ----
            3'b101:  ReadData = addr[1] ? {{16{1'b0}}, rd[31:16]} : {{16{1'b0}}, rd[15:0]};
            default: ReadData = 32'd0;
        endcase
    end
endmodule
