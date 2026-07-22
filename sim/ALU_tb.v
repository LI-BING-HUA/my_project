`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/26 16:56:02
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb ();
    reg     [31:0] Srca;
    reg     [31:0] Srcb;
    reg     [ 3:0] alu_control;
    wire    [31:0] alu_result;
    wire           zero;
    integer        fails = 0;

    ALU dut (
        .Srca       (Srca),
        .Srcb       (Srcb),
        .alu_control(alu_control),
        .alu_result (alu_result),
        .zero       (zero)
    );

    function [31:0] expected;
        input [31:0] a, b;
        input [3:0] ctrl;
        case (ctrl)
            4'd0:    expected = a + b;
            4'd1:    expected = a - b;
            4'd2:    expected = a & b;
            4'd3:    expected = a | b;
            4'd4:    expected = a ^ b;
            4'd5:    expected = $signed(a) < $signed(b) ? 1 : 0;
            4'd6:    expected = a < b ? 1 : 0;
            4'd7:    expected = a << b[4:0];
            4'd8:    expected = a >> b[4:0];
            4'd9:    expected = $signed(a) >>> b[4:0];
            default: expected = a + b;
        endcase
    endfunction

    task check;
        input [31:0] exp;
        input exp_zero;
        if (alu_result !== exp) begin
            $display("FAIL: ctrl=%0d -> result=%0d(exp %0d) zero=%b(exp %b)", alu_control, alu_result, exp, zero, exp_zero);
            fails = fails + 1;
        end
        else begin
            $display("PASS: ctrl=%0d -> result=%0d zero=%b", alu_control, alu_result, zero);
        end
    endtask

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd0;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd1;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd2;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd3;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd4;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd5;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd6;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd7;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd8;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = 10;
        Srcb        = 20;
        alu_control = 4'd9;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);

        Srca        = -5;
        Srcb        = 3;
        alu_control = 4'd5;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);  // SLT 負數

        Srca        = -5;
        Srcb        = 3;
        alu_control = 4'd6;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);  // SLTU 負數

        Srca        = -16;
        Srcb        = 2;
        alu_control = 4'd9;
        #1 check(expected(Srca, Srcb, alu_control), expected(Srca, Srcb, alu_control) == 0);  // SRA 負數

        if (fails == 0) begin
            $display("PASS");
        end
        else begin
            $display("FAILED");
        end

        #10 $finish;
    end
endmodule
