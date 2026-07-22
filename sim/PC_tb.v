`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 15:52:13
// Design Name: 
// Module Name: PC_tb
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


module PC_tb ();
    reg            clk;
    reg            rst;
    reg            step;
    reg     [31:0] pc_next;
    wire    [31:0] pc;
    integer        fails = 0;

    Point_Counter dut (
        .clk    (clk),
        .rst    (rst),
        .step   (step),
        .pc_next(pc_next),
        .pc     (pc)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] expected;
        if (pc !== expected) begin
            $display("FAIL: pc 應該是 %0d, 實際 %0d", expected, pc);
            fails = fails + 1;
        end
        else begin
            $display("PASS: pc = %0d", pc);
        end
    endtask

    initial begin
        $dumpfile("pc.vcd");  // 波形檔
        $dumpvars(0, PC_tb);  // 記錄所有訊號

        rst     = 1;
        clk     = 0;
        pc_next = 32'd0;
        step    = 1;
        #12 rst = 0;

        pc_next = 32'd100;
        #10 check(100);
        pc_next = 32'd104;
        #10 check(104);
        pc_next = 32'd108;
        #10 check(108);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAILED: fails = %0d", fails);
        end

        #10 $finish;
    end
endmodule
