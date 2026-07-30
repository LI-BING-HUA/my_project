module BTN_DEB (
    input  clk,
    input  rst,
    input  btn,
    output btn_deb
);

    localparam Stable0 = 2'd0;
    localparam Stable1 = 2'd1;
    localparam Unstable = 2'd2;

    reg [1:0] state, next_state;
    reg [22:0] cnt;
    reg        prev;

    always @(posedge clk) begin
        if (rst) begin
            state <= Stable0;
            prev  <= 0;
        end
        else begin
            state <= next_state;
            prev  <= btn;
        end
    end

    always @(*) begin
        case (state)
            Stable0: begin
                if (btn) begin
                    next_state = Unstable;
                end
                else begin
                    next_state = Stable0;
                end
            end

            Unstable: begin
                if (cnt == 23'd4_999_999 && prev) begin
                    next_state = Stable1;
                end
                else if (cnt == 23'd4_999_999 && ~prev) begin
                    next_state = Stable0;
                end
                else begin
                    next_state = Unstable;
                end
            end

            Stable1: begin
                if (~btn) begin
                    next_state = Unstable;
                end
                else begin
                    next_state = Stable1;
                end
            end
            default: next_state = Stable0;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 23'd0;
        end
        else if (prev != btn) begin
            cnt <= 23'd0;
        end
        else if (state == Unstable) begin
            cnt <= cnt + 23'd1;
        end
        else begin
            cnt <= 23'd0;
        end
    end

    assign btn_deb = state == Stable1;
endmodule
