module CLG (
    input        Cin,
    input  [3:0] G,
    input  [3:0] P,
    output       C0,
    output       C1,
    output       C2,
    output       Cout
);

    assign C0   = G[0] | (P[0] & Cin);
    assign C1   = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    assign C2   = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

endmodule
