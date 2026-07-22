`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/25 22:13:29
// Design Name: 
// Module Name: Register_File
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


module Register_File (
    input         clk,
    input         step,
    input         we3,    // 寫致能
    input  [ 4:0] a_dbg,
    input  [ 4:0] a1,     // 讀位址 1
    input  [ 4:0] a2,     // 讀位址 2
    input  [ 4:0] a3,     // 寫位址
    input  [31:0] wd3,    // 寫入資料
    output [31:0] rd1,    // 讀出 1
    output [31:0] rd2,    // 讀出 2
    output [31:0] rd_dbg
);
    reg [31:0] mem[0:31];  // 32 個 32 bits 的暫存器
    always @(posedge clk) begin
        if (we3 && a3 != 5'd0 && step) begin  // x0 恆為 0, 不可寫入
            mem[a3] <= wd3;
        end
    end

    assign rd1    = a1 ? mem[a1] : 32'd0;  // 寫入擋掉 0, 所以 mem[0] 沒被初始化過, 直接寫 rd1 = mem[a1] 會出現 x
    assign rd2    = a2 ? mem[a2] : 32'd0;  // 寫入擋掉 0, 所以 mem[0] 沒被初始化過, 直接寫 rd2 = mem[a2] 會出現 x
    assign rd_dbg = a_dbg ? mem[a_dbg] : 32'd0;
endmodule
