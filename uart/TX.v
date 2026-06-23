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
    input clk, rst,
    input start,            // 给一个脉冲,叫 TX 开始传
    input [1:0] data,       // 要传的资料 (先用 2-bit,你可改宽)
    output signal           // 输出的波形 (接到线上)
);
    localparam IDLE       = 3'd0;
    localparam START_HIGH = 3'd1;
    localparam START_LOW  = 3'd2;
    localparam DATA_HIGH  = 3'd3;
    localparam DATA_LOW   = 3'd4;
    localparam END_HIGH   = 3'd5;

    reg bit_index;
    reg [2:0] state, next_state;
    reg [7:0] count;

    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if (start)
                    next_state = START_HIGH;
                else
                    next_state = IDLE;
            end

            START_HIGH: begin
                if (count == 8'd99)
                    next_state = START_LOW;
                else
                    next_state = START_HIGH; 
            end

            START_LOW: begin
                if (count == 8'd49)
                    next_state = DATA_HIGH;
                else
                    next_state = START_LOW;
            end

            DATA_HIGH: begin
                if (count == 8'd9)
                    next_state = DATA_LOW;
                else
                    next_state = DATA_HIGH; 
            end

            DATA_LOW: begin
                if (bit_index) begin
                    if (data[bit_index]) begin
                        if (count == 8'd29) begin
                            next_state = DATA_HIGH;
                        end
                        else
                            next_state = DATA_LOW;
                    end
                    else begin
                        if (count == 8'd9) begin
                            next_state = DATA_HIGH;
                        end
                        else
                            next_state = DATA_LOW; 
                    end
                end
                else begin
                    if (data[bit_index]) begin
                        if (count == 8'd29) begin
                            next_state = END_HIGH;
                        end
                        else
                            next_state = DATA_LOW;
                    end
                    else begin
                        if (count == 8'd9) begin
                            next_state = END_HIGH;
                        end
                        else
                            next_state = DATA_LOW; 
                    end
                end
            end

            END_HIGH: begin
                if (count == 8'd9)
                    next_state = IDLE;
                else
                    next_state = END_HIGH; 
            end
            default: next_state = IDLE;
        endcase
    end 

    always @(posedge clk) begin
        if (rst)
            count <= 8'd0;
        else if (state != next_state)
            count <= 8'd0;
        else
            count <= count + 8'd1;
    end

    always @(posedge clk) begin
        if (rst)
            bit_index <= 1'b1;
        else if (state == DATA_LOW && next_state == DATA_HIGH)
            bit_index <= 1'b0;
        else if (state == IDLE)
            bit_index <= 1'b1;
    end

assign signal = state == START_HIGH || state == DATA_HIGH || state == END_HIGH;

endmodule
