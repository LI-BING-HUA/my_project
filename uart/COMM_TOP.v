module COMM_TOP (
    input clk, rst,
    input [1:0] mode_sel, mc_btn,
    input start_btn,
    input [3:0] mul_A, mul_B,                              // ← 乘法器要的两个数
    output reg [3:0] status_led, behavior_led,             // 4颗普通LED (跑马灯/按钮)
    output reg led_r, led_g, led_b,                        // RGB LED (呼吸灯)
    output reg [6:0] seg,                                  // 七段 (乘法器)
    output reg [3:0] an
);
    wire signal, btn_deb1, start_deb;
    wire [1:0] rx_data;
    wire [3:0] marquee_led, mc_led, mul_an;
    wire [6:0] mul_seg;
    wire rb_r, rb_g, rb_b;
    wire clk_tx, clk_rx, locked;
    wire sys_rst = rst | ~locked;   // MMCM沒鎖定前保持reset

    clk_wiz_0 clkgen(
        .clk_in1(clk),
        .clk_out1(clk_tx),
        .clk_out2(clk_rx),
        .reset(rst),
        .locked(locked)
    );
    BTN_DEB btn1(.clk(clk_tx), .rst(sys_rst), .btn(start_btn), .btn_deb(btn_deb1));
    Pulse_GEN pulse_gen(.clk(clk_tx), .rst(sys_rst), .in(btn_deb1), .out(start_deb));
    TX tx(.clk(clk_tx), .rst(sys_rst), .start(start_deb), .data(mode_sel), .signal(signal));
    
    RX rx(.clk(clk_rx), .rst(sys_rst), .signal(signal), .data(rx_data), .led());
    Marquee m1(.clk(clk_rx), .reset(sys_rst), .led(marquee_led));
    MC_TOP mc_top(.clk(clk_rx), .rst(sys_rst), .btn(mc_btn), .led(mc_led));
    Rainbow_Breathing_LED rb(.clk(clk_rx), .rst(sys_rst), .led_r(rb_r), .led_g(rb_g), .led_b(rb_b));
    mul_seg mul(.clk(clk_rx), .A(mul_A), .B(mul_B), .seg(mul_seg), .an(mul_an));

    always @(*) begin
        case(rx_data)
            2'd0: status_led = 4'b0001;
            2'd1: status_led = 4'b0010;
            2'd2: status_led = 4'b0100;
            2'd3: status_led = 4'b1000;
            default: status_led = 4'b0000;
        endcase
    end

    always @(*) begin
        case(rx_data)
            2'd0: behavior_led = marquee_led;
            2'd1: behavior_led = mc_led;
            default: behavior_led = 4'b0000;
        endcase
    end

    always @(*) begin
        if (rx_data == 2'd2)
            {led_r, led_g, led_b} =  {rb_r, rb_g, rb_b};
        else
            {led_r, led_g, led_b} =  3'b000;
    end

    always @(*) begin
        if (rx_data == 2'd3) begin
            seg = mul_seg;
            an  = mul_an;
        end
        else begin
            seg = 7'b1111111;
            an = 4'b1111;
        end
    end
endmodule