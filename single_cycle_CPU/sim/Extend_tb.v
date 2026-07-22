`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 20:03:57
// Design Name: 
// Module Name: Extend_tb
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


module Extend_tb ();
    reg     [31:0] instr;
    reg     [ 2:0] imm_src;
    wire    [31:0] imm_ext;
    integer        fails = 0;

    Extend dut (
        .instr  (instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    task check;
        input [31:0] expected;
        if (imm_ext !== expected) begin
            $display("FAIL: imm_src = %0d, imm_ext = %0h, expected = %0h", imm_src, imm_ext, expected);
            fails = fails + 1;
        end
        else begin
            $display("PASS: imm_src = %0d, imm_ext = %0h, expected = %0h", imm_src, imm_ext, expected);
        end
    endtask

    initial begin
        $dumpfile("Extend.vcd");
        $dumpvars(0, Extend_tb);

        instr   = 32'hFFF00000;
        imm_src = 3'd0;
        #1 check(32'hFFFFFFFF);

        instr   = 32'hFE000AA3;
        imm_src = 3'd1;
        #1 check(32'hFFFFFFF5);

        instr   = 32'h80000080;
        imm_src = 3'd2;
        #1 check(32'hFFFFF800);

        instr   = 32'hAAAAA000;
        imm_src = 3'd3;
        #1 check(32'hAAAAA000);

        instr   = 32'h80000000;
        imm_src = 3'd4;
        #1 check(32'hFFF00000);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAILED");
        end

        #10 $finish;
    end
endmodule
