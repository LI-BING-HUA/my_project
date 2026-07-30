module FA (
    input  A,
    input  B,
    input  Cin,
    output G,
    output P,
    output S
);

    xor (S, A, B, Cin);

    assign G = A & B;
    assign P = A | B;

endmodule
