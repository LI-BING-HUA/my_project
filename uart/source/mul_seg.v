module mul_seg (
    input        clk,
    input  [3:0] A,
    input        B,
    output [6:0] seg,
    output [3:0] an
);
    wire [7:0] P;
    mul mul4 (
        .A(A),
        .B(B),
        .P(P)
    );
    seven_seg ss (
        .clk(clk),
        .d0 (P[3:0]),
        .d1 (P[7:4]),
        .d2 (4'd0),
        .d3 (4'd0),
        .seg(seg),
        .an (an)
    );
endmodule
