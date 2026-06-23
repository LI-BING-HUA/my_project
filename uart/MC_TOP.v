module MC_TOP (
    input clk, rst, 
    input [1:0] btn, 
    output [3:0] led);
    
    wire btn_deb_0, btn_deb_1, out0, out1;

    BTN_DEB btn_deb0(.clk(clk), 
        .rst(rst), 
        .btn(btn[0]), 
        .btn_deb(btn_deb_0)
    );

    BTN_DEB btn_deb1(.clk(clk), 
        .rst(rst), 
        .btn(btn[1]), 
        .btn_deb(btn_deb_1)
    );

    Pulse_GEN pulse_gen0(.clk(clk), 
        .rst(rst), 
        .in(btn_deb_0), 
        .out(out0)
    );

    Pulse_GEN pulse_gen1(.clk(clk), 
        .rst(rst), 
        .in(btn_deb_1), 
        .out(out1)
    );

    MC mc(.clk(clk), 
        .rst(rst), 
        .up_pulse(out1), 
        .down_pulse(out0), 
        .led(led)
    );
endmodule