module Marquee (
    input        clk,
    input        reset,
    output [3:0] led
);
    localparam A = 0, B = 1, C = 2, D = 3;
    reg [25:0] cnt;
    reg [1:0] state, next_state;
    wire pass;

    assign pass = cnt == 26'd25000000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= A;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            A: begin
                if (pass) begin
                    next_state = B;
                end
                else begin
                    next_state = A;
                end
            end
            B: begin
                if (pass) begin
                    next_state = C;
                end
                else begin
                    next_state = B;
                end
            end
            C: begin
                if (pass) begin
                    next_state = D;
                end
                else begin
                    next_state = C;
                end
            end
            D: begin
                if (pass) begin
                    next_state = A;
                end
                else begin
                    next_state = D;
                end
            end
            default next_state = A;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= 1'b0;
        end
        else if (pass) begin
            cnt <= 1'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end

    assign led[0] = state == A;
    assign led[1] = state == B;
    assign led[2] = state == C;
    assign led[3] = state == D;
endmodule
