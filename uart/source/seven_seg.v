module seven_seg (
    input            clk,
    input      [3:0] d0,
    input      [3:0] d1,
    input      [3:0] d2,
    input      [3:0] d3,
    output reg [6:0] seg,
    output reg [3:0] an
);
    // 內部: 分頻 + 輪流 + seg 查表 + active-low
    reg [17:0] cnt = 18'd0;
    reg [ 1:0] sel = 2'd0;
    reg [ 3:0] cur_digit;

    always @(posedge clk) begin
        if (cnt == 18'd49999) begin
            cnt <= 18'd0;
            sel <= sel + 2'd1;
        end
        else begin
            cnt <= cnt + 18'd1;
        end
    end

    always @(*) begin
        case (sel)
            2'b00: cur_digit = d0;
            2'b01: cur_digit = d1;
            2'b10: cur_digit = d2;
            2'b11: cur_digit = d3;
            default: cur_digit = d0;
        endcase
    end

    always @(*) begin
        case (sel)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;
            default: an = 4'b1111;
        endcase
    end

    always @(*) begin
        case (cur_digit)
            4'd0  : seg = 7'b0000001;
            4'd1  : seg = 7'b1001111;
            4'd2  : seg = 7'b0010010;
            4'd3  : seg = 7'b0000110;
            4'd4  : seg = 7'b1001100;
            4'd5  : seg = 7'b0100100;
            4'd6  : seg = 7'b0100000;
            4'd7  : seg = 7'b0001111;
            4'd8  : seg = 7'b0000000;
            4'd9  : seg = 7'b0000100;
            4'd10 : seg = 7'b0001000;  // A
            4'd11 : seg = 7'b1100000;  // b
            4'd12 : seg = 7'b0110001;  // C
            4'd13 : seg = 7'b1000010;  // d
            4'd14 : seg = 7'b0110000;  // E
            4'd15 : seg = 7'b0111000;  // F
            default : seg = 7'b1111111;
        endcase
    end
endmodule
