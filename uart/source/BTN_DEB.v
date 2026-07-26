module BTN_DEB (
    input clk, rst, 
    input btn, 
    output btn_deb);
    
    localparam Stable0 = 2'd0, Stable1 = 2'd1, Unstable = 2'd2;
    reg [1:0] state, next_state;
    reg [22:0] cnt;
    reg prev;

    always @(posedge clk) begin
        if (rst) begin
            state <= Stable0;
            prev <= 0;
        end
        else begin
            state <= next_state;
            prev <= btn;
        end
    end 

    always @(*) begin
        case(state)
            Stable0: begin
                if (btn)
                    next_state = Unstable;
                else
                    next_state = Stable0;
            end

            Unstable: begin
                if (cnt == 23'd4_999_999 && prev)
                    next_state = Stable1;
                else if (cnt == 23'd4_999_999 && ~prev)
                    next_state = Stable0;
                else
                    next_state = Unstable;
            end

            Stable1: begin
                if (~btn)
                    next_state = Unstable;
                else
                    next_state = Stable1;
            end
            default: next_state = Stable0;
        endcase
    end

    always @(posedge clk) begin
        if (rst)
            cnt <= 23'd0;
        else if (prev != btn)
            cnt <= 23'd0;
        else if (state == Unstable)
            cnt <= cnt + 23'd1;
        else
            cnt <= 23'd0;
    end

    assign btn_deb = state == Stable1;
endmodule