`timescale 1ns / 1ps

module Pulse_GEN(
    input clk, rst, 
    input in,
    output out
    );
    reg prev;
always @(posedge clk) begin
    if (rst) begin
        prev <= 0;
    end
    else
        prev <= in;
end
assign out = ~prev && in;
endmodule
