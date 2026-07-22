`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 09:51:46
// Design Name: 
// Module Name: Data_Memory
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


module Data_Memory (
    input         clk,
    input         step,
    input         we,      // 寫致能(寫記憶體)
    input  [ 2:0] funct3,  // 選寬度
    input  [31:0] addr,    // 位址(ALU 算出來的)
    input  [31:0] wd,      // 寫入資料
    output [31:0] rd       // 讀出資料
);

    // =========================================================================
    // 記憶體佈局：一格 = 1 word (32 bits) = 4 bytes
    //
    //   規格上記憶體是 byte-addressable（每個 byte 一個位址），
    //   但這裡實作成 word 陣列（4 個 byte 打包成一格），
    //   因為 CPU 資料通道是 32 位，lw/sw 一次讀寫一整格比較方便。
    //   代價：lb/sb 要自己算「byte 在 word 裡的位置」。
    //
    //   位址拆解：
    //     addr >> 2   → 選哪一格 word
    //     addr[1:0]   → 選格子裡的第幾個 byte
    //
    //   一格 mem[i] 的內部（Little Endian：低位址放低位）：
    //
    //     bit  31    24 23    16 15     8 7      0
    //         +--------+--------+--------+--------+
    //         | byte 3 | byte 2 | byte 1 | byte 0 |
    //         +--------+--------+--------+--------+
    //   addr[1:0]=  11       10       01       00
    //   實際位址   4i+3     4i+2     4i+1     4i+0
    //
    //   例：addr = 102
    //     102 >> 2   = 25    → mem[25]
    //     102 & 0b11 = 10    → byte 2 → mem[25][23:16]
    // =========================================================================

    reg [31:0] mem[0:255];
    always @(posedge clk) begin
        if (we && step) begin
            case (funct3)
                3'b000: begin  // sb (store byte)
                    case (addr[1:0])
                        2'b00:   mem[addr>>2][7:0] <= wd[7:0];
                        2'b01:   mem[addr>>2][15:8] <= wd[7:0];
                        2'b10:   mem[addr>>2][23:16] <= wd[7:0];
                        2'b11:   mem[addr>>2][31:24] <= wd[7:0];
                        default: ;
                    endcase
                end
                3'b001: begin  // sh (store half)
                    case (addr[1])
                        1'b0:    mem[addr>>2][15:0] <= wd[15:0];
                        1'b1:    mem[addr>>2][31:16] <= wd[15:0];
                        default: ;
                    endcase
                end
                3'b010:  mem[addr>>2] <= wd;  // sw (store word)
                default: ;
            endcase
        end
    end
    assign rd = mem[addr>>2];
endmodule
