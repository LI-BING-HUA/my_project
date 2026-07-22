`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 16:28:11
// Design Name: 
// Module Name: PCPlus4_tb
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


module PCPlus4_tb ();
    reg     [31:0] pc;
    wire    [31:0] pc_plus4;
    integer        fails = 0;

    PCPlus4 dut (
        .pc      (pc),
        .pc_plus4(pc_plus4)
    );

    task check;
        input [31:0] expected;
        if (pc_plus4 !== expected) begin
            $display("FAIL: pcplus4 = %0d, expected = %0d", pc_plus4, expected);
            fails = fails + 1;
        end
        else begin
            $display("PASS: pcplus4 = %0d, expected = %0d", pc_plus4, expected);
        end
    endtask

    initial begin
        $dumpfile("PCPlus4.vcd");
        $dumpvars(0, PCPlus4_tb);

        pc = 32'd16;
        #10 check(20);
        pc = 32'd20;
        #10 check(24);
        pc = 32'd24;
        #10 check(28);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAILED: fails = %0d", fails);
        end

        #10 $finish;
    end
endmodule
