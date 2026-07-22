`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/27 16:54:55
// Design Name: 
// Module Name: top_basys3
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


module top_basys3 (
    input        clk,
    input        rst,
    input        btn,
    input  [4:0] SW,
    output [6:0] seg,
    output [3:0] an
);
    wire        step;
    wire        btn_deb;
    wire [ 3:0] bcd_0;
    wire [ 3:0] bcd_1;
    wire [ 3:0] bcd_2;
    wire [31:0] rd_dbg;

    BTN_DEB BD (
        .clk    (clk),
        .rst    (rst),
        .btn    (btn),
        .btn_deb(btn_deb)
    );

    Pulse_GEN PG (
        .clk(clk),
        .rst(rst),
        .in (btn_deb),
        .out(step)
    );

    single_cycle_CPU SC_CPU (
        .clk   (clk),
        .rst   (rst),
        .step  (step),
        .a_dbg (SW),
        .rd_dbg(rd_dbg)
    );

    BtoBCD b2b (
        .Binary(rd_dbg[7:0]),
        .BCD_0 (bcd_0),
        .BCD_1 (bcd_1),
        .BCD_2 (bcd_2)
    );

    seven_seg s7 (
        .clk(clk),
        .d0 (bcd_0),
        .d1 (bcd_1),
        .d2 (bcd_2),
        .d3 (4'd0),
        .seg(seg),
        .an (an)
    );
endmodule

