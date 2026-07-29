`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/19 20:00:47
// Design Name: 
// Module Name: TX
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

module TX (
    input        clk,
    input        rst,
    input        start,
    input  [1:0] data,
    output       signal
);
    localparam IDLE = 3'd0;
    localparam START_HIGH = 3'd1;
    localparam START_LOW = 3'd2;
    localparam DATA_HIGH = 3'd3;
    localparam DATA_LOW = 3'd4;
    localparam END_HIGH = 3'd5;

    reg bit_index;
    reg [2:0] state, next_state;
    reg [7:0] count;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = START_HIGH;
                end
                else begin
                    next_state = IDLE;
                end
            end

            START_HIGH: begin
                if (count == 8'd99) begin
                    next_state = START_LOW;
                end
                else begin
                    next_state = START_HIGH;
                end
            end

            START_LOW: begin
                if (count == 8'd49) begin
                    next_state = DATA_HIGH;
                end
                else begin
                    next_state = START_LOW;
                end
            end

            DATA_HIGH: begin
                if (count == 8'd9) begin
                    next_state = DATA_LOW;
                end
                else begin
                    next_state = DATA_HIGH;
                end
            end

            DATA_LOW: begin
                if (bit_index) begin
                    if (data[bit_index]) begin
                        if (count == 8'd29) begin
                            next_state = DATA_HIGH;
                        end
                        else begin
                            next_state = DATA_LOW;
                        end
                    end
                    else begin
                        if (count == 8'd9) begin
                            next_state = DATA_HIGH;
                        end
                        else begin
                            next_state = DATA_LOW;
                        end
                    end
                end
                else begin
                    if (data[bit_index]) begin
                        if (count == 8'd29) begin
                            next_state = END_HIGH;
                        end
                        else begin
                            next_state = DATA_LOW;
                        end
                    end
                    else begin
                        if (count == 8'd9) begin
                            next_state = END_HIGH;
                        end
                        else begin
                            next_state = DATA_LOW;
                        end
                    end
                end
            end

            END_HIGH: begin
                if (count == 8'd9) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = END_HIGH;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            count <= 8'd0;
        end
        else if (state != next_state) begin
            count <= 8'd0;
        end
        else begin
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
        else if (state == IDLE) begin
            bit_index <= 1'b1;
        end
    end

    assign signal = state == START_HIGH || state == DATA_HIGH || state == END_HIGH;

endmodule
