`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/28 15:30:11
// Design Name: 
// Module Name: Load_Unit_tb
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


module Load_Unit_tb ();
    reg     [ 1:0] addr;
    reg     [ 2:0] funct3;
    reg     [31:0] rd;
    wire    [31:0] ReadData;
    integer        fails = 0;

    Load_Unit LU (
        .addr    (addr),
        .funct3  (funct3),
        .rd      (rd),
        .ReadData(ReadData)
    );

    task check;
        input [31:0] expected;
        if (ReadData !== expected) begin
            $display("FAIL: ReadData = %0h, expected = %0h", ReadData, expected);
            fails = fails + 1;
        end
        else begin
            $display("PASS: ReadData = %0h, expected = %0h", ReadData, expected);
        end
    endtask

    initial begin
        $dumpfile("Load_Unit.vcd");
        $dumpvars(0, Load_Unit_tb);

        addr   = 2'b00;
        funct3 = 3'b000;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b1111_1111_1111_1111_1111_1111_1001_0011);

        addr   = 2'b11;
        funct3 = 3'b000;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_0000_0000_0000_0000_0000_0000);

        addr   = 2'b11;
        funct3 = 3'b001;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_0000_0000_0000_0000_1010_0000);

        addr   = 2'b11;
        funct3 = 3'b010;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_1010_0000_0000_0000_1001_0011);

        addr   = 2'b00;
        funct3 = 3'b100;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_0000_0000_0000_0000_1001_0011);

        addr   = 2'b10;
        funct3 = 3'b100;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_0000_0000_0000_0000_1010_0000);

        addr   = 2'b00;
        funct3 = 3'b101;
        rd     = 32'b0000_0000_1010_0000_0000_0000_1001_0011;
        #1 check(32'b0000_0000_0000_0000_0000_0000_1001_0011);

        if (fails == 0) begin
            $display("ALL PASS");
        end
        else begin
            $display("FAIL: fails = %0d", fails);
        end

        #10 $finish;
    end
endmodule
