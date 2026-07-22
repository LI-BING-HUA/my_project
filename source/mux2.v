`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/25 21:58:09
// Design Name: 
// Module Name: mux2
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


module mux2 (
    input  [31:0] d0,
    input  [31:0] d1,   // 兩個輸入
    input         sel,  // 1-bit 選擇
    output [31:0] y     // 輸出
);
    assign y = sel ? d1 : d0;
endmodule
