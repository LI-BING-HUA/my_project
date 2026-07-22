`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/27 11:54:35
// Design Name: 
// Module Name: Instruction_Memory_tb
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


module Instruction_Memory_tb ();
    reg     [31:0] addr;
    wire    [31:0] instr;
    integer        fails = 0;

    Instruction_Memory dut (
        .addr (addr),
        .instr(instr)
    );

    task check;
        input [31:0] expected;
        if (instr !== expected) begin
            $display("FAIL: mem[%0d] = %0b, expected = %0b", addr >> 2, instr, expected);
            fails = fails + 1;
        end
        else begin
            $display("PASS: mem[%0d] = %0b, expected = %0b", addr >> 2, instr, expected);
        end
    endtask

    initial begin
        $dumpfile("Instruction_Memory.vcd");
        $dumpvars(0, Instruction_Memory_tb);

        addr = 32'd0;
        #1 check(32'b000000001010_00000_000_00001_0010011);

        addr = 32'd4;
        #1 check(32'b000000000011_00000_000_00010_0010011);

        addr = 16;
        #1 check(32'b0000000_00010_00001_001_00101_0110011);

        addr = 24;
        #1 check(32'b0000000_00010_00001_011_00111_0110011);

        addr = 40;
        #1 check(32'b0000000_00010_00001_110_01011_0110011);

        addr = 56;
        #1 check(32'b000000010100_01010_010_01111_0010011);

        addr = 64;
        #1 check(32'b000000001100_01010_100_10001_0010011);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAILED: fails = %0d", fails);
        end

        #5 $finish;
    end
endmodule
