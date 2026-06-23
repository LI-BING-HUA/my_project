`timescale 1ns / 1ps

module MC(
    input clk, rst, 
    input up_pulse, down_pulse,
    output reg [3:0] led
    );
always @(posedge clk) begin
    if (rst)
        led <= 4'd0;
    else if (up_pulse)
        led <= led + 4'd1;
    else if (down_pulse)
        led <= led - 4'd1;
end
endmodule
