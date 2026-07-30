module RX (
    input            clk,
    input            rst,
    input            signal,
    output reg [1:0] data,
    output reg [3:0] led
);
    localparam START_HIGH = 3'd0;
    localparam START_LOW = 3'd1;
    localparam DATA_HIGH = 3'd2;
    localparam DATA_LOW = 3'd3;
    localparam END_HIGH = 3'd4;
    localparam END_LOW = 3'd5;

    reg [7:0] count;
    reg [2:0] state, next_state;
    reg bit_index, prev, s1, s2;

    always @(posedge clk) begin
        s1 <= signal;
        s2 <= s1;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= START_HIGH;
        end
        else begin
            state <= next_state;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            prev <= 0;
        end
        else begin
            prev <= s2;
        end
    end

    always @(*) begin
        case (state)
            START_HIGH: begin
                if (!s2 && prev && count > 8'd55 && count < 8'd78) begin
                    next_state = START_LOW;
                end
                else begin
                    next_state = START_HIGH;
                end
            end

            START_LOW: begin
                if (s2 && !prev && count > 8'd25 && count < 8'd42) begin
                    next_state = DATA_HIGH;
                end
                else begin
                    next_state = START_LOW;
                end
            end

            DATA_HIGH: begin
                if (!s2 && prev && count > 8'd13 && count < 8'd28) begin
                    next_state = DATA_LOW;
                end
                else begin
                    next_state = DATA_HIGH;
                end
            end

            DATA_LOW: begin
                if (bit_index) begin
                    next_state = DATA_HIGH;
                end
                else begin
                    next_state = END_HIGH;
                end
            end

            END_HIGH: begin
                if (!s2 && prev && count > 8'd13 && count < 8'd28) begin
                    next_state = END_LOW;
                end
                else begin
                    next_state = END_HIGH;
                end
            end

            END_LOW: begin
                next_state = (s2 && !prev) ? START_HIGH : END_LOW;
            end
            default: next_state = START_HIGH;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            data <= 2'b0;
        end
        else if (s2 && !prev && count > 8'd0 && count < 8'd13) begin
            data <= {data[0], 1'b0};
        end
        else if (s2 && !prev && count > 8'd13 && count < 8'd28) begin
            data <= {data[0], 1'b1};
        end
        else begin
            data <= data;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            count <= 8'd0;
        end
        else if (s2 && !prev || !s2 && prev) begin
            count <= 8'd0;
        end
        else if (s2 == prev) begin
            count <= count + 8'd1;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            bit_index <= 1'b1;
        end
        else if (state == DATA_LOW && next_state == DATA_HIGH) begin
            bit_index <= 1'b0;
        end
        else if (state == START_LOW) begin
            bit_index <= 1'b1;
        end
    end

    always @(*) begin
        case (data)
            2'b00: led = 4'b0001;
            2'b01: led = 4'b0010;
            2'b10: led = 4'b0100;
            2'b11: led = 4'b1000;
            default: led = 4'b0000;
        endcase
    end
endmodule
