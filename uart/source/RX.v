module RX (
    input clk, rst,
    input signal,            // 收到的波形 (从TX来,先不管CDC,之后再加)
    output reg [1:0] data,    // 解出来的资料
    output reg [3:0] led
);
    localparam START_HIGH = 3'd0;
    localparam START_LOW  = 3'd1;
    localparam DATA_HIGH  = 3'd2;
    localparam DATA_LOW   = 3'd3;
    localparam END_HIGH   = 3'd4;
    localparam END_LOW    = 3'd5;

    reg [7:0] count;
    reg [2:0] state, next_state;
    reg bit_index, prev, s1, s2;

    always @(posedge clk) begin
        s1 <= signal;
        s2 <= s1;
    end

    always @(posedge clk) begin
        if (rst)
            state <= START_HIGH; 
        else
            state <= next_state;
    end

    always @(posedge clk) begin
        if (rst)
            prev <= 0;
        else
            prev <= s2; 
    end

    always @(*) begin
        case(state)
            START_HIGH: begin
                if (!s2 && prev && count > 8'd55 && count < 8'd78)
                    next_state = START_LOW;
                else
                    next_state = START_HIGH; 
            end

            START_LOW: begin
                if (s2 && !prev && count > 8'd25 && count < 8'd42)
                    next_state = DATA_HIGH;
                else
                    next_state = START_LOW;
            end

            DATA_HIGH: begin
                if (!s2 && prev && count > 8'd13 && count < 8'd28)
                    next_state = DATA_LOW;
                else
                    next_state = DATA_HIGH;
            end

            DATA_LOW: begin
                if (bit_index)
                    next_state = DATA_HIGH;
                else
                    next_state = END_HIGH;
            end

            END_HIGH: begin
                if (!s2 && prev && count > 8'd13 && count < 8'd28)
                    next_state =  END_LOW;
                else
                    next_state = END_HIGH;
            end

            END_LOW: begin
                next_state = (s2 && !prev) ? START_HIGH : END_LOW;
            end
            default: next_state = START_HIGH;
        endcase
    end

    always @(posedge clk) begin
        if (rst)
            data <= 2'b0;
        else if (s2 && !prev && count > 8'd0 && count < 8'd13)
            data <= {data[0], 1'b0};
        else if (s2 && !prev && count > 8'd13 && count < 8'd28)
            data <= {data[0], 1'b1};
        else
            data <= data;
    end

    always @(posedge clk) begin
        if (rst)
            count <= 8'd0;
        else if (s2 && !prev || !s2 && prev)
            count <= 8'd0;
        else if (s2 == prev)
            count <= count + 8'd1;
    end

    always @(posedge clk) begin
        if (rst)
            bit_index <= 1'b1;
        else if (state == DATA_LOW && next_state == DATA_HIGH)
            bit_index <= 1'b0;
        else if (state == START_LOW)
            bit_index <= 1'b1;
    end

    always @(*) begin
        case(data)
            2'b00: led = 4'b0001;
            2'b01: led = 4'b0010;
            2'b10: led = 4'b0100;
            2'b11: led = 4'b1000;
            default: led = 4'b0000;
        endcase
    end
endmodule