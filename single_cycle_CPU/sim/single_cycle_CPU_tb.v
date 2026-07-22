`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/27 14:16:33
// Design Name: 
// Module Name: single_cycle_CPU_tb
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


module single_cycle_CPU_tb ();
    reg         clk;
    reg         rst;
    reg         step;
    reg  [ 4:0] a_dbg;
    wire [31:0] rd_dbg;

    single_cycle_CPU dut (
        .clk   (clk),
        .rst   (rst),
        .step  (step),
        .a_dbg (a_dbg),
        .rd_dbg(rd_dbg)
    );
    always #5 clk = ~clk;

    initial begin
        $dumpfile("single_cycle_CPU.vcd");
        $dumpvars(0, single_cycle_CPU_tb);

        rst   = 1;
        clk   = 0;
        step  = 1;
        a_dbg = 0;
        #12 rst = 0;
        #5000;
        a_dbg = 5'd3;
        #10 $display("x3  = %0d (expect 13)", rd_dbg);
        a_dbg = 5'd22;
        #10 $display("x22 = %0d (expect 100)", rd_dbg);
        #100;  // 等程式跑完
        a_dbg = 5'd9;
        #10 $display("x9  = %0d", rd_dbg);
        a_dbg = 5'd11;
        #10 $display("x11 = %0d", rd_dbg);
        a_dbg = 5'd12;
        #10 $display("x12 = %0d", rd_dbg);
        a_dbg = 5'd14;
        #10 $display("x14 = %0d", rd_dbg);
        a_dbg = 5'd15;
        #10 $display("x15 = %0d", rd_dbg);
        a_dbg = 5'd16;
        #10 $display("x16 = %0d", rd_dbg);
        #5000 $finish;
    end
endmodule
