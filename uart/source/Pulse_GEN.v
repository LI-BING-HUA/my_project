module Pulse_GEN (
    input  clk,
    input  rst,
    input  in,
    output out
);
    reg prev;
    always @(posedge clk) begin
        if (rst) begin
            prev <= 0;
        end
        else begin
            prev <= in;
        end
    end
    assign out = ~prev && in;
endmodule
