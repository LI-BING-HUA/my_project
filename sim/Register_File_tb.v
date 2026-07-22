`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/27 12:13:59
// Design Name: 
// Module Name: Register_File_tb
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


module Register_File_tb ();
    reg            clk;
    reg            step;
    reg            we3;
    reg     [ 4:0] a_dbg;
    reg     [ 4:0] a1;
    reg     [ 4:0] a2;
    reg     [ 4:0] a3;
    reg     [31:0] wd3;
    wire    [31:0] rd1;
    wire    [31:0] rd2;
    wire    [31:0] rd_dbg;
    integer        fails = 0;

    Register_File dut (
        .clk   (clk),
        .step  (step),
        .we3   (we3),
        .a_dbg (a_dbg),
        .a1    (a1),
        .a2    (a2),
        .a3    (a3),
        .wd3   (wd3),
        .rd1   (rd1),
        .rd2   (rd2),
        .rd_dbg(rd_dbg)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] exp_rd1, exp_rd2;
        if (rd1 !== exp_rd1 || rd2 !== exp_rd2) begin
            $display("FAIL: rd1 = %0d, exp_rd1 = %0d, rd2 = %0d, exp_rd2 = %0d", rd1, exp_rd1, rd2, exp_rd2);
            fails = fails + 1;
        end
        else begin
            $display("PASS: rd1 = %0d, exp_rd1 = %0d, rd2 = %0d, exp_rd2 = %0d", rd1, exp_rd1, rd2, exp_rd2);
        end
    endtask

    initial begin
        $dumpfile("Register_File.vcd");
        $dumpvars(0, Register_File_tb);

        clk   = 0;
        a_dbg = 5'd0;
        step  = 1;

        @(negedge clk);
        a2  = 0;
        we3 = 1;
        a3  = 5'd5;
        wd3 = 32'd10;
        @(negedge clk);
        a1 = 5'd5;
        #1 check(32'd10, 32'd0);

        @(negedge clk);
        a2  = 0;
        we3 = 1;
        a3  = 5'd0;
        wd3 = 32'd99;
        @(negedge clk);
        a1 = 5'd0;
        #1 check(32'd0, 32'd0);

        @(negedge clk);
        a2  = 0;
        we3 = 1;
        a3  = 5'd5;
        wd3 = 32'd0;
        @(negedge clk);
        a1 = 5'd5;
        #1 check(32'd0, 32'd0);

        @(negedge clk);
        a2  = 0;
        we3 = 1;
        a3  = 5'd1;
        wd3 = 32'd10;
        @(negedge clk);
        a1  = 5'd1;
        we3 = 1;
        wd3 = 32'd99;
        a3  = 5'd1;
        #1 check(32'd10, 32'd0);
        @(negedge clk);
        #1 check(32'd99, 32'd0);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAILED, fails = %0d", fails);
        end
        #1 $finish;
    end
endmodule
