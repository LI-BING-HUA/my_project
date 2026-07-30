module MC (
    input            clk,
    input            rst,
    input            up_pulse,
    input            down_pulse,
    output reg [3:0] led
);
    always @(posedge clk) begin
        if (rst) begin
            led <= 4'd0;
        end
        else if (up_pulse) begin
            led <= led + 4'd1;
        end
        else if (down_pulse) begin
            led <= led - 4'd1;
        end
    end
endmodule
